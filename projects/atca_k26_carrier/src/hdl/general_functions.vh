///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company: INSTITUTO DE PLASMAS E FUSAO NUCLEAR
// Engineer: BBC
//
// Create Date:   13:45:00 15/04/2016
// Project Name:
// Design Name:
// Module Name:
// Target Devices:
// Tool versions:  Vivado 2022.1
//
// Description:
// Verilog Header
//
//
// Copyright 2015 - 2022 IPFN-Instituto Superior Tecnico, Portugal
// Creation Date  2017-11-09
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
`ifndef _general_functions_vh_
`define _general_functions_vh_

function signed [ADC_DATA_WIDTH + 1:0] adc_eorec_f;
    input [ADC_DATA_WIDTH-1:0] adc_data;      // AXI streaming port
    input [ADC_DATA_WIDTH-1:0] eo_offset;
    reg signed [ADC_DATA_WIDTH + 1:0] adc_ext;// Make headroom for minus operation
    reg signed [ADC_DATA_WIDTH + 1:0] eo_ext;// Make headroom for minus operation
  begin
    adc_ext = $signed({{2{adc_data[ADC_DATA_WIDTH-1]}}, adc_data}); //  extend sign
    eo_ext = $signed({{2{eo_offset[ADC_DATA_WIDTH-1]}}, eo_offset});
    adc_eorec_f = adc_ext - eo_ext;
  end
endfunction


    function  [ADC_DATA_WIDTH -3:0] adc_16_msb_f;
        input [ADC_DATA_WIDTH -1:0] adc_data;
        adc_16_msb_f = adc_data[ADC_DATA_WIDTH-1:2];
    endfunction


    // 20 bit  dechopp output result

    function signed [ADC_DATA_WIDTH + 1:0] adc_dechop_f;
        input [ADC_DATA_WIDTH + 1:0] adc_data;
        input  chop_phase;
        //input  chop_rec;
        reg signed [ADC_DATA_WIDTH + 1:0]  eo_ext;// Make headroom for minus operation
        begin
            //adc_dechop_f = chop_phase ? (adc_data - eo_ext):(eo_ext- adc_data);
            //Some dechopping as project
            // bcar/ipfn-atca/-/blob/master/virtex4/w7x-interlock-fp
            adc_dechop_f = chop_phase ? (eo_ext - adc_data):(adc_data - eo_ext);
        end
    endfunction


    function  [63:0] big_endian_64_f;
        input [63:0] data_in;
        input big_endian;
        big_endian_64_f = (big_endian)?     // Select Endianess
                             {data_in[39:32], data_in[47:40], data_in[55:48], data_in[63:56],
                                      data_in[7:0], data_in[15:8], data_in[23:16], data_in[31:24]} :
                             data_in;
      endfunction

    function  [127:0] big_endian_128_f;
        input [127:0] data_in;
        input big_endian;
        big_endian_128_f = (big_endian)?     // Select Endianess
                             {data_in[103:96], data_in[111:104], data_in[119:112], data_in[127:120],
                                      data_in[71:64], data_in[79:72], data_in[87:80], data_in[95:88],
                             data_in[39:32], data_in[47:40], data_in[55:48], data_in[63:56],
                                      data_in[7:0], data_in[15:8], data_in[23:16], data_in[31:24]} :
                             data_in;
      endfunction

/*  End function Declarations */

`endif // _general_functions_vh_
