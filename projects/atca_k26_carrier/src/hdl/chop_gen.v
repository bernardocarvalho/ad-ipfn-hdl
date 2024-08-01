//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company: INSTITUTO DOS PLASMAS E FUSAO NUCLEAR
// Engineer:  BBC
//
// Project Name:   atca-k26-carrier 
// Design Name:   
// Module Name: chop_gen
// Target Devices: xck26-sfvc784-2LV-c
// Create Date: 31/07/2024 05:02:48 PM

//
//Description:
//
// Copyright 2023 - 2024 IPFN-Instituto Superior Tecnico, Portugal
// Create Date: 31/07/2024 05:02:48 PM

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
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps
`include "atca_k26_config.vh"
module chop_gen #(
    parameter CHOP_DEFAULT = 1'b0,        // default for "Normal" modules
    parameter CHOP_DLAY    = `CHOP_DLAY,      // Delay N data samples for phase reconstruction
    parameter HOLD_SAMPLES = `HOLD_SAMPLES, // Suppress N data samples and hold last good values during dechopping algorithm
    parameter TCQ        = 1	
)(
    input adc_data_clk,  // ADC data  clock domain (80MHz)
    input [5:0] adc_clk_cnt, // counts 0->39 in each adc period for channel mux

    //input adc_word_sync_n,
    //input reset_n,
    input chop_en,
    input [15:0] max_count,     // 16'd2000 -> 1kHz
    input [15:0] change_count,  // max_count / 2 -> 50 % d.c.
    output chop_o,
    output chop_dly_o,
    output data_hold_o
);

    reg chop_r;
    assign chop_o = chop_r;

    reg hold_r;
    reg [CHOP_DLAY-1:0] hold_dly;
    assign data_hold_o = hold_dly[CHOP_DLAY-1];

    reg [CHOP_DLAY-1:0] chop_dly = 0;
    assign chop_dly_o = chop_dly[CHOP_DLAY-1];


    reg [15:0] chop_counter_r = 0;
    always @(posedge adc_data_clk or negedge chop_en)
        if(!chop_en) begin
            chop_counter_r <= 0;
            chop_r <= CHOP_DEFAULT;
            hold_r <= 0;
            chop_dly <= 0;
            hold_dly <= 0;
        end
        else begin
            if(adc_clk_cnt == 6'd0) begin
                chop_counter_r <=  #TCQ chop_counter_r + 1;
                chop_dly <= #TCQ {chop_dly[CHOP_DLAY-2:0], chop_r};
                hold_dly <= #TCQ {hold_dly[CHOP_DLAY-2:0], hold_r};
                // case(chop_counter_r)
                if ( chop_counter_r == (HOLD_SAMPLES-1) )
                    hold_r <= #TCQ 1'b0;
                else if ( chop_counter_r == (change_count-1) ) begin
                    chop_r <= #TCQ !CHOP_DEFAULT;
                    hold_r <= #TCQ  1'b1;
                end
                else if ( chop_counter_r == (change_count + HOLD_SAMPLES-1) )
                    hold_r <= #TCQ  1'b0;
                else if ( chop_counter_r == (max_count-1) ) begin
                    chop_counter_r <= #TCQ 'h00;
                    chop_r         <= #TCQ CHOP_DEFAULT;
                    hold_r         <= #TCQ 1'b1;
                end
            end
        end

endmodule //chop_gen
