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


module si53xx_spi_interface(
    input  clk,
    input  reset,
    input  read,
    input  write,
    input  [7:0] rw_addr,
    input  [7:0] write_data,
    output [7:0] read_data,
    output nCS,
    input  sdi,
    output sdo,
    output reg in_en,
    output sclk,
    output reg [9:0] rom_addr,
    input  [15:0] rom_data,
    output done
    );
    
    reg [7:0] sdo_reg;
    reg [3:0] spi_bit;
    reg [1:0] spi_byte;
    reg [6:0] spi_clk_gen;
    
    assign read_data = sdo_reg;
    
    parameter RESET=3'd0,
              AUTO=3'd1,
              READ=3'd2,
              WRITE=3'd3,
              DONE=3'd4;
    
    reg [2:0] state,next_state;
    
    initial in_en=1'b1;
    
    parameter write_command = 8'b01001010,
              read_command  = 8'b10010101, 
              set_addr      = 8'b00010101;
    
    always @(*) begin //set state of sdo (follows timing as long as spi bit changes at correct time)
        case(state)
            RESET:    next_state = reset ? RESET :( read ? READ : (write ? WRITE : AUTO));
            AUTO:     next_state = reset ? RESET :( rom_addr == 10'd614 ? DONE : AUTO);
            READ:     next_state = reset ? RESET :( spi_byte == 2'd0 && spi_bit == 4'd0 && spi_clk_gen==7'h7f ? DONE : READ);
            WRITE:    next_state = reset ? RESET :( spi_byte == 2'd0 && spi_bit == 4'd0 && spi_clk_gen==7'h7f ? DONE : WRITE);
            DONE:     next_state = reset ? RESET : DONE;
            default : next_state = DONE;
        endcase
    end
    
    
    always @(posedge clk) begin
        case (state)
        RESET: begin
            spi_clk_gen<=0;
            rom_addr <= 10'h000;
            spi_bit <= 4'h8;
            spi_byte <= 2'h3;
        end 
        AUTO:begin
        spi_clk_gen<= spi_clk_gen+1'b1;
            if (spi_clk_gen==7'h7f) begin  // change data @falling edge of clock
                if(spi_bit==4'd8) begin
                    case(spi_byte)
                        2'h3: sdo_reg <= set_addr;
                        2'h2: sdo_reg <= rom_data[15:8];
                        2'h1: sdo_reg <= write_command;
                        2'h0: sdo_reg <= rom_data[7:0];
                    endcase
                    spi_bit<=spi_bit-1;
                end else if(spi_bit<9 && spi_bit>0) begin
                    spi_bit<=spi_bit-1;
                    in_en<=1'b0;
                    sdo_reg<={sdo_reg[6:0],1'b0};
                end else begin
                    spi_bit<=4'h8;
                    if (spi_byte==2'b0) begin
                        rom_addr<=rom_addr+1;
                        spi_byte<=2'h3;
                    end else
                        spi_byte<=spi_byte-1;
                end
            end
        end

        READ:begin
            spi_clk_gen<= spi_clk_gen+1'b1;
            if (spi_clk_gen==7'h7f) begin
                if(spi_bit==4'd8) begin
                    case(spi_byte)
                        2'h3: sdo_reg <= set_addr;
                        2'h2: sdo_reg <= rw_addr;
                        2'h1: sdo_reg <= read_command;
                        2'h0: sdo_reg <= 8'h00;
                    endcase
                    spi_bit<=spi_bit-1;
                end else if(spi_bit<9 && spi_bit>0) begin
                    spi_bit<=spi_bit-1;
                    if(spi_byte==2'h0) begin
                        in_en<=1'b1;
                        sdo_reg<={sdi,sdo_reg[7:1]};
                    end else begin
                        in_en<=1'b0;
                        sdo_reg<={sdo_reg[6:0],1'b0};
                    end
                end else begin
                    spi_bit<=4'h8;
                    spi_byte<=spi_byte-1;
                end
            end
        end
        WRITE:begin
            spi_clk_gen<= spi_clk_gen+1'b1;
            if (spi_clk_gen==7'h7f) begin
                if(spi_bit==4'd8) begin
                    case(spi_byte)
                        2'h3: sdo_reg <= set_addr;
                        2'h2: sdo_reg <= rw_addr;
                        2'h1: sdo_reg <= write_command;
                        2'h0: sdo_reg <= write_data;
                    endcase
                    spi_bit<=spi_bit-1;
                end else if(spi_bit<9 && spi_bit>0) begin
                    spi_bit<=spi_bit-1;
                    in_en<=1'b0;
                    sdo_reg<={sdo_reg[6:0],1'b0};
                end else begin
                    spi_bit<=4'h8;
                    spi_byte<=spi_byte-1;
                end
            end
        end
        DONE:begin
            spi_bit<=4'h8;
            spi_clk_gen<=0;
        end 
        default: begin
            spi_bit<=4'h8;
            spi_clk_gen<=0;
        end
        endcase
        state <= next_state;
    end
    
    assign sclk = spi_clk_gen[6];
    assign nCS = (spi_bit==4'h8 ? 1:0);
    assign sdo = sdo_reg[7];
    assign done = state==DONE ? 1'b1:1'b0;
    
endmodule
