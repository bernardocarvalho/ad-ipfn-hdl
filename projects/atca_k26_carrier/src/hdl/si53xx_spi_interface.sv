`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/27/2023 02:46:40 PM
// Design Name: 
// Module Name: si5396a_spi_interface
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: implements part of the si53xx pll spi communication protocol, 
//              can source config data from a ROM and flash it all at once
//              refer to  Si5397/96 Reference Manual
//              
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module 
   si53xx_spi_interface(
      
                        input            clk,
                        input            reset,
                        input            read,
                        input            write,

                        input [7:0]      rw_addr,
                        input [7:0]      write_data,
                        output reg [7:0] read_data,

                        input            sdi,
                        output           sdo,
                        output           in_en,

                        output           nCS,
                        output           sclk,

                        output reg [9:0] rom_addr,
                        input [15:0]     rom_data
                        );
   
   reg [15:0]                            sdo_reg;
   reg [4:0]                             spi_clk_gen;

   reg [9:0]                             config_length;
   reg [7:0]                             preamble_length;
   reg [24:0]                            reset_timeout;
   
   parameter timeout_ctr_init=25'd300;
   
   parameter 
     RESET=        9'b000000000,
     RESET_WAIT=   9'b000001000,
     SEND_PREAMB=  9'b001000000,
     LOAD_PARM_AD= 9'b010000000,
     LOAD_PARM_RD= 9'b100000000,
     READ=         9'b000000001,
     WRITE=        9'b000000010,
     WAIT_PREAMB=  9'b000010000,
     WRITE_CONFIG= 9'b000100000,
     DONE=         9'b000000100,
              
     //RESET=      4'b0000,
     //READ=       4'b0001,
     //WRITE=      4'b0010,
     //DONE=       7'b0100,       
     SET_ADDR=     4'b1000,
 
     //RESET=      3'b000,  
     LOAD=         3'b001,
     SHIFT=        3'b010;
     //DONE=       3'b100;
   
   reg [8:0]                             top_state,next_top_state;       
   reg [3:0]                             state,next_state;
   reg [3:0]                             shift_state,next_shift_state;
   reg [4:0]                             shift_ctr;
   
   parameter 
     write_command = 8'b01001010,
     read_command  = 8'b10001010, 
     set_addr      = 8'b00001010;
   
   wire                                  shift_done;
   reg                                   shift;
   reg                                   go;
   
   
   always @* begin
      case(top_state)
        RESET:        next_top_state = reset ? RESET : LOAD_PARM_AD;
        LOAD_PARM_AD: next_top_state = reset ? RESET : LOAD_PARM_RD;
        LOAD_PARM_RD: next_top_state = reset ? RESET : RESET_WAIT;      
        RESET_WAIT:   next_top_state = reset ? RESET : reset_timeout==25'd0 ? 
                                       read ? READ : write ? WRITE : SEND_PREAMB : RESET_WAIT;
        SEND_PREAMB:  next_top_state = reset ? RESET : !go && state==DONE ?
                                       WAIT_PREAMB : SEND_PREAMB; 
        WAIT_PREAMB:  next_top_state = reset ? RESET : reset_timeout==25'd0 ?
                                       WRITE_CONFIG : RESET_WAIT;
        READ:         next_top_state = reset ? RESET : state == DONE ? DONE : READ;
        WRITE:        next_top_state = reset ? RESET : state == DONE ? DONE : WRITE;
        WRITE_CONFIG: next_top_state = reset ? RESET : !go && state==DONE ?
                                       DONE : WRITE_CONFIG; 
        DONE:         next_top_state = reset ? RESET : DONE;
        default:      next_top_state = reset ? RESET : RESET_WAIT;
      endcase
      
      case(state)
        RESET:      next_state = reset ? RESET : go ? SET_ADDR : RESET;
        SET_ADDR:   next_state = reset ? RESET : shift_done ? 
                                 (top_state==READ ? READ : WRITE) : SET_ADDR;
        READ:       next_state = reset ? RESET : shift_done ? DONE : READ;
        WRITE:      next_state = reset ? RESET : shift_done? DONE : WRITE;
        DONE:       next_state = reset ? RESET : go ? SET_ADDR : DONE;
        default:    next_state = DONE;
      endcase // case (state)
      
      case(shift_state)
        RESET:    next_shift_state = reset ? RESET : LOAD;
        LOAD:     next_shift_state = reset ? RESET : shift ? SHIFT : LOAD;
        SHIFT:    next_shift_state = reset ? RESET : shift_ctr == 5'd18 ? DONE : SHIFT;
        DONE:     next_shift_state = reset ? RESET : LOAD;
        default:  next_shift_state = LOAD;
      endcase
   end // always @ *
   
   assign shift_done = shift_state == DONE;
   
   always @(posedge clk) begin
      top_state <= next_top_state;
      state <= next_state;
      shift_state <= next_shift_state;
      case(top_state)
        RESET: begin
           reset_timeout <= timeout_ctr_init;
           go <= 1'b0;
        end
        RESET_WAIT: begin
           reset_timeout <= reset_timeout - 25'd1;
        end
        LOAD_PARM_AD: begin
           rom_addr <= 9'd0;
        end
        LOAD_PARM_RD: begin
           config_length <= rom_data[9:0];
           preamble_length <= rom_data[15:10];
           rom_addr <= 9'd1;
        end
        SEND_PREAMB: begin
           go <= rom_addr<preamble_length;
           reset_timeout <= timeout_ctr_init;
        end
        WAIT_PREAMB: begin
           reset_timeout <= reset_timeout - 25'd1;
        end
        WRITE_CONFIG: begin
           go <= rom_addr<preamble_length;
        end   
        default: begin
        end
      endcase // case (top_state)
      
      case(state)
        RESET: begin
           rom_addr <= 10'd0;
           spi_clk_gen <= 5'd0;
           shift <= 1'b0;
        end
        SET_ADDR: begin
           spi_clk_gen <= spi_clk_gen+5'd1;
           if (shift_state==LOAD && spi_clk_gen == 5'h1f) begin
              shift <= 1'b1;
              if (read || write) begin
                 sdo_reg <= {set_addr,rw_addr};
              end else begin
                 sdo_reg <= {set_addr,rom_data[15:8]};
              end        
           end       
        end
        READ: begin
           spi_clk_gen <= spi_clk_gen+5'd1;
           if (shift_state==LOAD && spi_clk_gen == 5'h1f) begin
              shift <= 1'b1;
              sdo_reg <= {read_command,8'hff};
           end
        end
        WRITE: begin
           spi_clk_gen <= spi_clk_gen+5'd1;
           if (shift_state==LOAD && spi_clk_gen == 5'h1f) begin
              shift <= 1'b1;
              if (write) begin
                 sdo_reg <= {write_command,write_data};
              end else begin
                 sdo_reg <= {set_addr,rom_data[7:0]};
                 rom_addr <= rom_addr+10'd1;
              end        
           end
        end
        DONE: begin
           
        end
        default: begin
        end
      endcase
      case(shift_state)
        RESET: begin
           shift_ctr <= 5'd0;
        end
        LOAD: begin
           shift_ctr <= 5'd0;
        end
        SHIFT: begin
           if(spi_clk_gen == 5'h1f) begin
              sdo_reg <= {sdo_reg[14:0],1'b1};
              shift_ctr <= shift_ctr+5'd1;   
           end else if(state==READ && shift_ctr > 5'd7 && shift_ctr < 5'd16 && spi_clk_gen == 5'h0f)
             read_data <= {read_data[6:0],sdi};
        end
        DONE: begin
           shift <= 1'd0;
        end
        default: begin
           shift_ctr <= 5'd0;
        end
      endcase
   end
   assign sdo   =  sdo_reg[15];  
   assign sclk  =  spi_clk_gen[4];
   assign nCS   = !(shift && shift_ctr < 5'd16);
   assign in_en = !(shift && ((state==WRITE ||state==SET_ADDR) && shift_ctr < 5'd16 || state==READ && shift_ctr < 5'd8));
   
endmodule