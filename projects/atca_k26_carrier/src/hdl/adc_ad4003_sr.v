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
// ***************************************************************************
`timescale 1ns/1ps

module adc_ad4003_sr  #( 
		parameter ADC_DATA_WIDTH = 18		
    ) 
    (
    input rst,
    input adc_read_clk, // 80Mhz but delayed for 47nsec
    input reader_en_sync,
    input adc_sdo_cha,
    input adc_sdo_chb,
    
    output [ADC_DATA_WIDTH-1 :0] adc_data_a,
    output [ADC_DATA_WIDTH-1 :0] adc_data_b
    //output reg [863:0] adc_data
);

    reg [ADC_DATA_WIDTH-1 :0] adc_data_a_sr, adc_data_b_sr; 
    assign adc_data_a = adc_data_a_sr; 
    assign adc_data_b = adc_data_b_sr; 

    always @(posedge adc_read_clk)
        if(reader_en_sync) begin
            adc_data_a_sr <= {adc_data_a_sr[ADC_DATA_WIDTH-1 :1], adc_sdo_cha};
            adc_data_b_sr <= {adc_data_b_sr[ADC_DATA_WIDTH-1 :1], adc_sdo_chb};
        end


endmodule
