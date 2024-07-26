//////////////////////////////////////////////////////////////////////////////////
// Company: INSTITUTO DOS PLASMAS E FUSAO NUCLEAR
// Engineer:  BBC
//
// Project Name:   atca-k26-carrier 
// Design Name:   ad4003_deserializer
// Module Name: ad4003_deserializer
// Target Devices: xck26-sfvc784-2LV-c
// Create Date: 03/15/2024 05:02:48 PM
//
// Description:
// Dependencies:
//
// Revision 2 - File Created
// Additional Comments:
//
// Copyright 2020 - 2024 IPFN-Instituto Superior Tecnico, Portugal
// Creation Date Mon Jul  1 12:29:13 PM WEST 2024
//
// Licensed under the EUPL, Version 1.2 or - as soon they
// will be approved by the European Commission - subsequent
// versions of the EUPL (the "Licence");
// You may not use this work except in compliance with the
// Licence.
// You may obtain a copy of the Licence at:
//
// https://joinup.ec.europa.eu/software/page/eupl
//
// Unless required by applicable law or agreed to in
// writing, software distributed under the Licence is
// distributed on an "AS IS" basis,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied.
// See the Licence for the specific language governing
// permissions and limitations under the Licence.
//
// ***************************************************************************

`timescale 1ns/1ps

module ad4003_deserializer #(parameter TCQ = 1)  
(
    input rst,
    input adc_spi_clk, // 80Mhz
    input adc_read_clk, // 80Mhz but delayed for 47nsec
    // input [24:1]adc_sdo_cha,
    // input [24:1]adc_sdo_chb,
    input force_read,
    input force_write,

    output [5:0] adc_spi_clk_count,
    output reader_en_sync,
    output cnvst,
    output sdi,
    output sck
    //output reg [863:0] adc_data
);

localparam   RESET = 4'd0, 
    TURBO_QUIET1   = 4'd1, 
    TURBO_DATA     = 4'd2, 
    TURBO_QUIET2   = 4'd3,
    RW_CNVH        = 4'd4,
    DATA_R         = 4'd5,
    DATA_W         = 4'd6,
    IDLE           = 4'd7,
    IDLE_CNVH      = 4'd8,
    RESET_CNVH     = 4'd9;

reg [5:0] cyc_cntr;
initial cyc_cntr=5'd0;
assign adc_spi_clk_count = cyc_cntr; 
reg [3:0] cyc_state, next_state;
    initial cyc_state=RESET;
reg [15:0] sdi_reg;
initial sdi_reg = 16'hffff;
reg data_written;
initial data_written = 1'b0;

wire reader_en;

always @(*) begin

    case(cyc_state) // state transition table
        RESET:          next_state = cyc_cntr==6'd0  ? (rst==1) ? RESET_CNVH : RW_CNVH : RESET;
        RESET_CNVH :    next_state = cyc_cntr==6'd16 ? RESET: RESET_CNVH;
        TURBO_QUIET1:   next_state = (rst==1)? RESET: cyc_cntr==6'd16 ? TURBO_DATA : TURBO_QUIET1;
        TURBO_DATA:     next_state = (rst==1)? RESET: cyc_cntr==6'd34 ? TURBO_QUIET2 : TURBO_DATA;
        TURBO_QUIET2:   next_state = (rst==1)? RESET: cyc_cntr==6'd0  ? TURBO_QUIET1 : TURBO_QUIET2;
        RW_CNVH:        next_state = (rst==1)? RESET: cyc_cntr==6'd16 ? force_read ? DATA_R : force_write ? DATA_W : data_written ? DATA_R : DATA_W : RW_CNVH;
        DATA_R:         next_state = (rst==1)? RESET: cyc_cntr==6'd0  ? force_read || force_write ? RW_CNVH : TURBO_QUIET1 : DATA_R;
        DATA_W:         next_state = (rst==1)? RESET: cyc_cntr==6'd0  ? force_read || force_write ? IDLE_CNVH : RW_CNVH : DATA_W;
        IDLE_CNVH:      next_state = (rst==1)? RESET: cyc_cntr==6'd16 ? IDLE: IDLE_CNVH;
        IDLE:           next_state = (rst==1)? RESET: cyc_cntr==6'd0  ? IDLE_CNVH: IDLE;
        default:        next_state = RESET; 
    endcase

end

assign cnvst = (cyc_state==TURBO_QUIET1 || cyc_state==RW_CNVH || cyc_state==IDLE_CNVH || cyc_state==RESET_CNVH)? 1'b1:1'b0;
assign sdi = sdi_reg[15];
assign sck = (cyc_cntr>6'd17 && cyc_cntr<6'd36) && cyc_state!=IDLE && cyc_state!=RESET ? adc_spi_clk : 0;


always @(negedge adc_spi_clk) begin
    if(cyc_cntr == 6'd17)
        case (cyc_state)
            RESET:
                data_written <= #TCQ 1'b0;
            DATA_R: 
                sdi_reg      <= #TCQ 16'h54ff;
            DATA_W: begin 
                 sdi_reg      <= #TCQ 16'h1402; 
                 data_written <= #TCQ 1'b1; 
               end
        default: 
            sdi_reg <= #TCQ 16'hffff;
    endcase
    if(cyc_cntr > 6'd17 && cyc_cntr < 6'd34)
        sdi_reg <= #TCQ {sdi_reg[14:0], 1'b1};
end

always @(posedge adc_spi_clk) begin //clk and cnvst generation
    if (cyc_cntr == 6'd39)
        cyc_cntr <= #TCQ 6'd0;
    else
        cyc_cntr <= #TCQ cyc_cntr + 1'b1;
    cyc_state <= #TCQ next_state;
end

// synchronizer adds 2 cycles of latency
assign reader_en = (cyc_cntr >= 6'd18 && cyc_cntr < 6'd36 && cyc_state != IDLE && cyc_state != RESET)? 1'b1: 1'b0;

// required for crossing clock domains between the acqusition clock and the read clock.
xpm_cdc_single #(
    .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
    .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
    .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
    .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
 )
    reader_en_syncro (
        .dest_out(reader_en_sync), // 1-bit output: src_in synchronized to the destination clock domain. This output is
        // registered.
        .dest_clk(adc_read_clk),   // 1-bit input: Clock signal for the destination clock domain.
        .src_clk(adc_spi_clk),     // 1-bit input: optional; required when SRC_INPUT_REG = 1
        .src_in(reader_en)         // 1-bit input: Input signal to be synchronized to dest_clk domain.
    );

    //warning this crosses clock domains, read clk delay is set in mmcm IP



endmodule
