`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/23/2024 03:13:31 PM
// Design Name: 
// Module Name: pll_spi_tester
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module pll_spi_tester(
        input axi_reset,
        input clk,
        input axi_clk,
        output reg if_read,
        output reg if_write,
        input  [7:0] if_rdata,
        output reg [7:0]if_wdata,
        output reg [7:0]if_addr,
        output reg if_reset,
        input if_done,
        output pll_reset,
        output reg [23:0] pll_regs     
    );
    
    parameter RESET=2'd0,SENDCOMMAND=2'd1,WAITFORDONE=2'd2,TESTCOMPLETE=2'd3;
    parameter RESET_WAIT=32'd100000000;
    
    reg [3:0] sequence;
    reg [1:0] state;
    reg [31:0] reset_timeout;
        
    reg [1:0] next_state;
    
    
    
    always @(*) begin //set state of sdo (follows timing as long as spi bit changes at correct time)
        case(state)
            RESET:         next_state = reset ? RESET :( reset_timeout==32'd0 ? SENDCOMMAND:RESET);
            SENDCOMMAND:   next_state = reset ? RESET : if_done ? SENDCOMMAND : WAITFORDONE;
            WAITFORDONE:   next_state = reset ? RESET : if_done ? sequence==4'd7 ? TESTCOMPLETE :SENDCOMMAND :WAITFORDONE;
            TESTCOMPLETE:  next_state = reset ? RESET : TESTCOMPLETE;
            default : next_state = TESTCOMPLETE;
        endcase
    end
    
    always @(posedge clk) begin
        case(state)
            RESET: begin
                sequence <= 4'd0;
                if_reset <= 1'b1;
                if (reset)
                    reset_timeout <= RESET_WAIT;
                else
                    reset_timeout <= reset_timeout-1;
            end
            SENDCOMMAND: begin
                if_reset <= 1'b1;
                case(sequence)
                    4'd0: begin                    
                        if_read <=1'b0;
                        if_write<=1'b1;
                        if_addr <=8'h01;
                        if_wdata<=8'h09;
                        end                      
                    4'd1: begin
                        if_read <=1'b0;
                        if_write<=1'b1;
                        if_addr <=8'h43;
                        if_wdata<=8'h01; 
                        end 
                    4'd2: begin
                        if_read <=1'b0;
                        if_write<=1'b1;
                        if_addr <=8'h01;
                        if_wdata<=8'h00;
                        end 
                    4'd3: begin
                        if_read <=1'b0;
                        if_write<=1'b1;
                        if_addr <=8'h2B;
                        if_wdata<=8'h0A; // clock builder pro just does this, should read modify write really, 
                                         // but I can't really read yet (to be corrected in rev 1.1) in theory 0x08 should also work, 
                                         // but that bit 1 might be doing something
                        end 
                    4'd4: begin
                        if_read <=1'b1;
                        if_write<=1'b0;
                        if_addr <=8'h02;
                        end 
                    4'd5: begin
                        if_read <=1'b1;
                        if_write<=1'b0;
                        if_addr <=8'h03;
                        pll_regs [7:0] <= if_rdata;
                        end 
                    4'd6: begin
                        if_read <=1'b1;
                        if_write<=1'b0;
                        if_addr <=8'h0C;
                        pll_regs [15:8] <= if_rdata;
                        end
                    4'd7: begin
                        if_read <=1'b1;
                        if_write<=1'b0;
                        if_addr <=8'h0C;
                        pll_regs [23:16] <= if_rdata;
                        end                       
                endcase
                end
                WAITFORDONE: begin
                    if_reset <= 0;
                    if(if_done)
                        sequence <= sequence+3'd1;
                end
        endcase         
        state <= next_state;
    end
    
    assign pll_reset= !(reset);
    
   xpm_cdc_single #(
      .DEST_SYNC_FF(4),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
   )
   reset_sync (
      .dest_out(reset), // 1-bit output: src_in synchronized to the destination clock domain. This output is
                           // registered.

      .dest_clk(clk), // 1-bit input: Clock signal for the destination clock domain.
      .src_clk(axi_clk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
      .src_in(axi_reset)      // 1-bit input: Input signal to be synchronized to dest_clk domain.
   );
   
endmodule
