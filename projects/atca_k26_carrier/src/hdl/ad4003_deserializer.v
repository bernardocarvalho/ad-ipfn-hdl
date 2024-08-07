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

module ad4003_deserializer #(
    parameter ADC_CHANNELS = 8,           // Maximum 48, Must be even 
    // Do not override parameters below this line
    parameter ADC_MODULES =  ADC_CHANNELS / 2,     
    parameter ADC_DATA_WIDTH = 18,
    parameter TCQ        = 1		)  
(
    input rst,
    input ila_clk,
    input adc_spi_clk, // 80Mhz
    input adc_read_clk, // 80Mhz but delayed for 47nsec
    // input [24:1]adc_sdo_cha,
    // input [24:1]adc_sdo_chb,
    
    input [ADC_MODULES-1 :0] adc_sdo_cha_p,
    input [ADC_MODULES-1 :0] adc_sdo_cha_n,
    input [ADC_MODULES-1 :0] adc_sdo_chb_p,
    input [ADC_MODULES-1 :0] adc_sdo_chb_n,

    output [5:0] adc_spi_clk_count,
    output cnvst,
    output sdi,
    output sck,
    //output reg [863:0] adc_data
    
    output  [ADC_DATA_WIDTH*ADC_CHANNELS-1 :0] adc_data_arr,
    
    output reg [ADC_CHANNELS*8-1:0] cfg_readback
);

    localparam  RESET          = 3'b000, 
                TURBO_DATA     = 3'b001, 
                DATA_R         = 3'b010,
                DATA_W         = 3'b100;
    
    reg [5:0] cyc_cntr;
    initial cyc_cntr=5'd0;
    assign adc_spi_clk_count = cyc_cntr;
    
    reg [2:0] state, next_state;
     initial state=RESET;
    reg [15:0] sdi_reg;
     initial sdi_reg = 16'hffff;
    reg data_written;
     initial data_written = 1'b0;
    
    wire reader_en,reader_en_sync;
    wire cfg_store_done_sync,cfg_store_req_sync;
    reg cfg_store_req,cfg_store_done;
    
    wire forceread,viorst;
    
    always @* begin
    
        case(state) // state transition table
            RESET:          next_state = rst || viorst ? RESET: DATA_W;
            TURBO_DATA:     next_state = rst || viorst ? RESET: TURBO_DATA;
            DATA_R:         next_state = rst || viorst ? RESET: cyc_cntr==6'd39  ? (forceread ? DATA_R : TURBO_DATA ) :DATA_R;
            DATA_W:         next_state = rst || viorst ? RESET: cyc_cntr==6'd39  ? DATA_R     : DATA_W;
            default:        next_state = RESET; 
        endcase
    
    end
    
    assign cnvst = cyc_cntr<6'd17;
                    
    assign sdi = sdi_reg[15];
    assign sck = (cyc_cntr>6'd17 && cyc_cntr<6'd36) && state!=RESET ? adc_spi_clk : 0;
    
    // sdi is sampled by adc at pos edge of sck(same phase as adc_spi_clk) 
    // so its best to update it at the negative edge of the clock
    always @(negedge adc_spi_clk) begin
        if(cyc_cntr == 6'd17)
            case (state)
                RESET:
                    data_written <= #TCQ  1'b0;
                DATA_R: 
                    sdi_reg      <= #TCQ 16'h54ff;
                DATA_W: begin 
                    sdi_reg      <= #TCQ 16'h1402; 
                    data_written <= #TCQ  1'b1; 
                end
                default: 
                    sdi_reg <= #TCQ 16'hffff;
            endcase
        if(cyc_cntr > 6'd17 && cyc_cntr < 6'd34)
            sdi_reg <= #TCQ {sdi_reg[14:0], 1'b1};
    end
    
    always @(posedge adc_spi_clk) begin //clk and cnvst generation
        case (state)
            RESET: begin
                cfg_store_req <=1'b0;
            end
            DATA_R:begin
                if(cyc_cntr==6'd39)
                    cfg_store_req<=1'b1;
            end
            default: begin
                if(cfg_store_done_sync)
                    cfg_store_req<=1'b0;
            end
        endcase
        if (cyc_cntr == 6'd39)
            cyc_cntr <= #TCQ 6'd0;
        else
            cyc_cntr <= #TCQ cyc_cntr + 1'b1;
        state <= #TCQ next_state;
    end
    
    // synchronizer adds 2 cycles of latency
    // adc_read_clk is 90o delayed phase, at 12.5nsec per clock period total delay is ... 
    assign reader_en = (cyc_cntr >= 6'd18 && cyc_cntr < 6'd36 && state != RESET)? 1'b1: 1'b0;
    
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
    
    

    // required for crossing clock domains between the acqusition clock and the read clock.
    xpm_cdc_single #(
        .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
        .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
        .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
        .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
    )
    cfg_store_req_syncro (
        .dest_out(cfg_store_req_sync), // 1-bit output: src_in synchronized to the destination clock domain. This output is
        // registered.
        .dest_clk(adc_read_clk),   // 1-bit input: Clock signal for the destination clock domain.
        .src_clk(adc_spi_clk),     // 1-bit input: optional; required when SRC_INPUT_REG = 1
        .src_in(cfg_store_req)         // 1-bit input: Input signal to be synchronized to dest_clk domain.
    );
    
    xpm_cdc_single #(
        .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
        .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
        .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
        .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
    )
    cfg_store_done_syncro (
        .dest_out(cfg_store_done_sync), // 1-bit output: src_in synchronized to the destination clock domain. This output is
        // registered.
        .dest_clk(adc_spi_clk),   // 1-bit input: Clock signal for the destination clock domain.
        .src_clk(adc_read_clk),     // 1-bit input: optional; required when SRC_INPUT_REG = 1
        .src_in(cfg_store_done)         // 1-bit input: Input signal to be synchronized to dest_clk domain.
    );
    
    // IBUFDS for adc sdo
    wire [ADC_MODULES-1:0] adc_sdo_cha, adc_sdo_chb;
    genvar k;	
	generate
		for (k = 0; k < ADC_MODULES; k = k + 1)
		begin: ADCs
            IBUFDS IBUFDS_cha (
              .O(adc_sdo_cha[k]),   // 1-bit output: Buffer output
              .I(adc_sdo_cha_p[k]),   // 1-bit input: Diff_p buffer input (connect directly to top-level port)
              .IB(adc_sdo_cha_n[k])  // 1-bit input: Diff_n buffer input (connect directly to top-level port)
            );
            IBUFDS IBUFDS_chb (
              .O(adc_sdo_chb[k]),   // 1-bit output: Buffer output
              .I(adc_sdo_chb_p[k]),   // 1-bit input: Diff_p buffer input (connect directly to top-level port)
              .IB(adc_sdo_chb_n[k])  // 1-bit input: Diff_n buffer input (connect directly to top-level port)
            );
        end
    endgenerate
    
    reg [ADC_DATA_WIDTH-1 :0] adc_a_data[ADC_MODULES-1 :0];
    reg [ADC_DATA_WIDTH-1 :0] adc_b_data[ADC_MODULES-1 :0];
    
    //shift register for data deserialization
    
    always @(posedge adc_read_clk) begin: adc_sd0_sr
        integer i;
        for (i = 0; i < ADC_MODULES; i = i + 1) begin
            if(reader_en_sync) begin
                adc_a_data[i] <= #TCQ {adc_a_data[i][ADC_DATA_WIDTH-2 :0], adc_sdo_cha[i]};
                adc_b_data[i] <= #TCQ {adc_b_data[i][ADC_DATA_WIDTH-2 :0], adc_sdo_chb[i]};
            end
        end
        for (i = 0; i < ADC_MODULES; i = i + 1) begin
            if(cfg_store_req_sync) begin
                cfg_readback[ 2*i   *8+:8]<=adc_a_data[i][9:2];
                cfg_readback[(2*i+1)*8+:8]<=adc_b_data[i][9:2];
                cfg_store_done <= 1'b1;
            end else begin
                cfg_store_done <= 1'b0;
            end
        end         
    end
    
    // adc data mapping from shift registers to data output
    
    generate 
        for (k = 0; k < ADC_MODULES; k = k + 1) begin
            assign adc_data_arr[ADC_DATA_WIDTH *  2 * k       +: ADC_DATA_WIDTH] = adc_a_data[k];
            assign adc_data_arr[ADC_DATA_WIDTH * (2 * k + 1)  +: ADC_DATA_WIDTH] = adc_b_data[k];
        end
    endgenerate
    
/*    
    ila_0 adc_ila (
       .clk(ila_clk), // input wire clk
    
    
       .probe0(rst), // input wire [0:0]  probe0  
       .probe1(adc_spi_clk), // input wire [0:0]  probe1 
       .probe2(adc_read_clk), // input wire [0:0]  probe2 
       .probe3(sck), // input wire [0:0]  probe3 
       .probe4(cnvst), // input wire [0:0]  probe4 
       .probe5(sdi), // input wire [0:0]  probe5 
       .probe6(cyc_state), // input wire [3:0]  probe6 
       .probe7(cyc_cntr), // input wire [5:0]  probe7 
       .probe8(reader_en_sync), // input wire [0:0]  probe8 
       .probe9(adc_sdo_cha), // input wire [3:0]  probe9 
       .probe10(adc_sdo_chb), // input wire [3:0]  probe10 
       .probe11(adc_a_data[0]), // input wire [17:0]  probe11 
       .probe12(adc_b_data[0]), // input wire [17:0]  probe12 
   	 .probe13(adc_a_data[1]), // input wire [17:0]  probe13 
	    .probe14(adc_b_data[1]) // input wire [17:0]  probe14
    );
*/    
    
endmodule
