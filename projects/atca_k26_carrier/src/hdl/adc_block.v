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

module adc_block #( 
		parameter ADC_CHANNELS = 4,           // Maximum 24, Must be even 
    // Do not override parameters below this line
		parameter ADC_DATA_WIDTH = 18,
		parameter TCQ        = 1		
    ) 
    (
    input rst,
    //input adc_spi_clk, // 80Mhz
    input adc_read_clk, // 80Mhz but delayed for 47nsec
    input [ADC_CHANNELS-1 :0] adc_sdo_cha,
    input [ADC_CHANNELS-1 :0] adc_sdo_chb,
    // input [24:1]adc_sdo_chb,
    // input force_read,
    // input force_write,
    input reader_en_sync,
    //output cnvst,
    // output sdi,
    // output sck,
    output  [ADC_DATA_WIDTH*ADC_CHANNELS-1 :0] adc_a_data_arr,
    output  [ADC_DATA_WIDTH*ADC_CHANNELS-1 :0] adc_b_data_arr
);


	genvar k;
    wire [ADC_DATA_WIDTH-1:0] adc_a_data[ADC_CHANNELS-1:0];	
    wire [ADC_DATA_WIDTH-1:0] adc_b_data[ADC_CHANNELS-1:0];	
	generate
		for (k = 0; k < ADC_CHANNELS; k = k + 1)
		begin: ADCs
        adc_chan_i 
			adc_ad4003_sr (	
                .rst(rst), // i
                .adc_read_clk(adc_read_clk),   // i			
                .reader_en_sync(reader_en_sync),    // i

                .adc_sdo_cha(adc_sdo_cha[k]),  // i
                .adc_sdo_chb(adc_sdo_chb[k]),  // i

                .adc_data_a(adc_a_data[k]),  // o
                .adc_data_b(adc_b_data[k])  // o
                            
			);
			// indexed part-select     [<start_bit -: ] // part-select decrements from start-bit
            // logic [31: 0] a_vect;
            // a_vect[15 -: 8] // == a_vect[15 : 8]
            //[<start_bit +: ] // part-select increments from start-bit
            // a_vect[ 0 +: 8] // == a_vect[ 7 : 0]

			assign adc_a_data_arr[(ADC_DATA_WIDTH*(k + 1) - 1) -: ADC_DATA_WIDTH] = adc_a_data[k];
			assign adc_b_data_arr[ADC_DATA_WIDTH*k  +: ADC_DATA_WIDTH] = adc_b_data[k];
//			assign adc_all_data_i[(`ADC_DATA_WIDTH * (k + 1) - 1):(`ADC_DATA_WIDTH * k) ] = adc_p_data[k];
		end
	endgenerate


endmodule
