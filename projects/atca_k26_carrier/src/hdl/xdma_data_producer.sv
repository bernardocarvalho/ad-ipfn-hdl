//////////////////////////////////////////////////////////////////////////////////
// Company: INSTITUTO DOS PLASMAS E FUSAO NUCLEAR
// Engineer:  BBC
//
// Project Name:   atca-k26-carrier 
// Design Name:   
// Module Name: xdma_data_producer
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
`timescale 1ns / 1ps
`include "atca_k26_config.vh"
`include "control_word_bits.vh"


module xdma_data_producer #(
    //parameter PKT_SAMPLES_WIDTH = 12,
    parameter DMA_FIFO_DEPTH = 32768, // 32768,   // Max Value 32768

    //    parameter RT_PKT_DECIM = 200,
    parameter C_S_AXI_DATA_WIDTH    = 32,    // AXI Lite Master  data width
    parameter C_STREAM_DATA_WIDTH    = 128,         // Streaming DMA C2H  data width
    parameter KEEP_WIDTH = C_STREAM_DATA_WIDTH / 8,              // TSTRB width

    //parameter FLOAT_WIDTH      = `FLOAT_WIDTH,

    //parameter N_ADC_CHANNELS   = `N_ADC_MAX_CHANNELS,

	parameter ADC_CHANNELS = 8,           // Maximum 48, Must be even 
    // Do not override parameters below this line
    parameter FIFO_PROG_FULL_THRESH = DMA_FIFO_DEPTH - 32,        // DECIMAL 8- 32763 32736

    parameter ADC_MODULES =  ADC_CHANNELS / 2,     
	parameter ADC_DATA_WIDTH = 18,
    parameter TCQ        = 1
)(
    input axi_aclk,
    input axi_aresetn,

    // ADC data clk (50Mhz)
    input adc_data_clk,
    input [5:0] adc_clk_cnt, // counts 0->24 in each adc period for channel mux

    //ADC module input data/clk
    // input [N_ADC_CHANNELS-1:0] adc_clk_p,
    // input [N_ADC_CHANNELS-1:0] adc_clk_n,
    // input [N_ADC_CHANNELS-1:0] adc_data_p,
    // input [N_ADC_CHANNELS-1:0] adc_data_n,
    input  [ADC_DATA_WIDTH*ADC_CHANNELS-1 :0] adc_a_data_arr,
    input  [ADC_DATA_WIDTH*ADC_CHANNELS-1 :0] adc_b_data_arr,

    // input word_sync_n,

    //input adc_chop_phase_dly,

    //input adc_data_hold,   // Suppress  data samples and hold for chopping spike removal

    // input [EO_VECT_WIDTH-1:0] eo_offset,
    //input [WO_VECT_WIDTH-1:0] wo_offset,

    input [C_S_AXI_DATA_WIDTH-1 :0]  control_reg,
    output [14:10] fifos_status,  // Status of the FIFO and Accumulators

    // input [N_ADC_CHANNELS-1:0]  channel_mask,

// Control interface
    input  acq_on,       // start on trigger

  // One AXI C2H xdma streaming ports
    output m_axis_tvalid_0,
    input  m_axis_tready_0,
    output [C_STREAM_DATA_WIDTH-1:0] m_axis_tdata_0,
    output [KEEP_WIDTH-1:0]   m_axis_tkeep_0,
    output m_axis_tlast_0,

    output m_axis_tvalid_1,
    input  m_axis_tready_1,
    output [C_STREAM_DATA_WIDTH-1:0] m_axis_tdata_1,
    output [KEEP_WIDTH-1:0]   m_axis_tkeep_1,
    output m_axis_tlast_1
);
   `include "general_functions.vh"
   
    assign m_axis_tvalid_1 = m_axis_tready_1; // NO second C2H channel for now
    assign m_axis_tdata_1 = {C_STREAM_DATA_WIDTH{1'b0}};
    assign m_axis_tlast_1 = 1'b0;
    
    reg  data_vld_c2h_0_r = 1'b0;
    reg [63:0] cnt_sample_c2h0_r;
    reg [15:0] cnt_pckt_c2h0_r;
    reg [C_STREAM_DATA_WIDTH-1:0] data_c2h_0_end_r; //, data_c2h_1_end_r; //registered. Used to correct BIG/Little Endian Data
    

    //wire [C_DATA_WIDTH-1 : 0] data_c2h_1;
    reg  [C_STREAM_DATA_WIDTH-1 : 0] data_c2h_0_r;
    wire fifo_prog_full_c2h_0, fifo_prog_full_c2h1_i;
    reg [KEEP_WIDTH-1:0] s_axis_tkeep_c = {KEEP_WIDTH{1'b1}};
    reg [KEEP_WIDTH-1:0] s_axis_tstrb_c = {KEEP_WIDTH{1'b0}};

    reg s_axis_tlast_r, s_axis_tlast_c2h1_r = 0;
    reg [4:0] status_data_r = 5'b00000;
    assign fifos_status = status_data_r;
    wire [14:0] wr_data_count, rd_data_count;
    reg [C_S_AXI_DATA_WIDTH-1 :0] cdc_control_reg;
    wire big_endian = cdc_control_reg[`ENDIAN_DMA_BIT];
    
   xpm_cdc_array_single #(
      .DEST_SYNC_FF(4),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(0),  // DECIMAL; 0=do not register input, 1=register input
      .WIDTH(C_S_AXI_DATA_WIDTH)           // DECIMAL; range: 1-1024
   )
   xpm_cdc_array_single_ (
      .dest_out(cdc_control_reg), // WIDTH-bit output: src_in synchronized to the destination clock domain. This
                            // output is registered.

      .dest_clk(adc_data_clk), // 1-bit input: Clock signal for the destination clock domain.
      .src_clk(axi_aclk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
      .src_in(control_reg)  // WIDTH-bit input: Input single-bit array to be synchronized to destination clock
                            // domain. It is assumed that each bit of the array is unrelated to the others. This
                            // is reflected in the constraints applied to this macro. To transfer a binary value
                            // losslessly across the two clock domains, use the XPM_CDC_GRAY macro instead.

   );
    
    wire [ADC_DATA_WIDTH-1 : 0] adc_18_data[0: ADC_CHANNELS-1];

    genvar k;
	generate
		for (k = 0; k < ADC_MODULES; k = k + 1)
        begin
            assign adc_18_data[2*k] = adc_a_data_arr[(ADC_DATA_WIDTH*(k + 1) - 1) -: ADC_DATA_WIDTH];
            assign adc_18_data[2*k + 1] = adc_b_data_arr[(ADC_DATA_WIDTH*(k + 1) - 1) -: ADC_DATA_WIDTH];
           //  (channel_mask_aclk[k])? adc_par_data[k] : {(ADC_DATA_WIDTH+2){1'b0}};
           //                                                  16'h0000;
        end
    endgenerate


    always @ (posedge adc_data_clk or negedge acq_on)
        if (!acq_on) begin
            data_vld_c2h_0_r   <= #TCQ 'h00; // check this async
            data_c2h_0_end_r   <= #TCQ 'h00;
            cnt_sample_c2h0_r  <= #TCQ 'h00;
            status_data_r      <= #TCQ 'h00;
            cnt_pckt_c2h0_r    <= #TCQ 'h00;//{PKT_SAMPLES_WIDTH {1'b0}}; // Counts sample num in each packet
            s_axis_tlast_r     <= #TCQ 0;
        end
        else begin
            data_c2h_0_end_r <= #TCQ big_endian_128_f(data_c2h_0_r, big_endian);
            case (adc_clk_cnt) // one cycle per sample. This case may start at clk_80_cnt != 0!
                6'h01: begin
                // if (data_32bit) begin 
                    // Send 4 channels per word + count data
                            data_c2h_0_r <= #TCQ {adc_18_data[3], 6'h0, cnt_sample_c2h0_r[31:24],
                                adc_18_data[2], 6'h0, cnt_sample_c2h0_r[23:16],
                                adc_18_data[1], 6'h0, cnt_sample_c2h0_r[15:8],
                                adc_18_data[0], 6'h0, cnt_sample_c2h0_r[7:0]};

            end 
                6'h02: begin
                      if( fifo_ready_c2h_0 && !fifo_prog_full_c2h_0)
                              data_vld_c2h_0_r      <= #TCQ 1'b1; //Start fifo writing samples
                      data_c2h_0_r <= #TCQ {adc_18_data[7], 6'h0, cnt_sample_c2h0_r[63:56],
                                adc_18_data[6], 6'h0, cnt_sample_c2h0_r[55:48],
                                adc_18_data[5], 6'h0, cnt_sample_c2h0_r[47:40],
                                adc_18_data[4], 6'h0, cnt_sample_c2h0_r[39:32]};                              
                    //data_c2h_0_r <= #TCQ 128'h00;

                end
                6'h03: begin
                if(data_vld_c2h_0_r)  // only if fifo writing is ON
                    cnt_pckt_c2h0_r     <= #TCQ cnt_pckt_c2h0_r + 1;
                    if (&cnt_pckt_c2h0_r[9:0]) // 128kB packet (Does xdma really cares about it?)
                        s_axis_tlast_r      <= #TCQ 1'b1;
                end
                6'h04: begin
                    data_vld_c2h_0_r  <= #TCQ 1'b0;
                    s_axis_tlast_r    <= #TCQ 1'b0;
                    cnt_sample_c2h0_r <= #TCQ cnt_sample_c2h0_r + 1;

                    // data_c2h_0_r <= #TCQ { 64'h00, 32'h00, integral_single_decim};
                end
                default: begin
                    data_vld_c2h_0_r <= #TCQ 1'b0;
                    s_axis_tlast_r   <= #TCQ 1'b0;
                end
            
        endcase
    end // always


   //cross fifo signals
   wire fifo_axis_tlast,fifo_axis_tready,fifo_axis_tvalid;
   wire [C_STREAM_DATA_WIDTH-1:0] fifo_axis_tdata;
   wire [KEEP_WIDTH-1:0] fifo_axis_tkeep;


 /***

*  AXI FIFO
*  xpm_fifo_axis: AXI Stream FIFO
   // Xilinx Parameterized Macro, version 2019.2
---------------------------------------------------------------------------------------------------------------------+
// | USE_ADV_FEATURES     | String             | Default value = 1000.                                                   |
// |---------------------------------------------------------------------------------------------------------------------|
// | Enables almost_empty_axis, rd_data_count_axis, prog_empty_axis, almost_full_axis, wr_data_count_axis,               |
// | prog_full_axis sideband signals.                                                                                    |
// |                                                                                                                     |
// |   Setting USE_ADV_FEATURES[1] to 1 enables prog_full flag;    Default value of this bit is 0                        |
// |   Setting USE_ADV_FEATURES[2]  to 1 enables wr_data_count;     Default value of this bit is 0                       |
// |   Setting USE_ADV_FEATURES[3]  to 1 enables almost_full flag;  Default value of this bit is 0                       |
// |   Setting USE_ADV_FEATURES[9]  to 1 enables prog_empty flag;   Default value of this bit is 0                       |
// |   Setting USE_ADV_FEATURES[10] to 1 enables rd_data_count;     Default value of this bit is 0                       |
// |   Setting USE_ADV_FEATURES[11] to 1 enables almost_empty flag; Default value of this bit is 0
// 8 * 64kB data fifo , Prog full = 20 * 8 B
//
*/
// UPSTREAM 32k sample FIFO 
   xpm_fifo_axis #(
      //.CDC_SYNC_STAGES(3),            // DECIMAL Range: 2 - 8. Default value = 2.
      .CLOCKING_MODE("common_clock"), // String
      .ECC_MODE("no_ecc"),            // String
      .FIFO_DEPTH(DMA_FIFO_DEPTH),              // DECIMAL 32768 (Max DEPTH* num of Bits= 4194304 bit)
      .FIFO_MEMORY_TYPE("ultra"),      // String
      .PACKET_FIFO("false"),          // String
       //.PROG_EMPTY_THRESH(32736),         // DECIMAL
      .PROG_FULL_THRESH(FIFO_PROG_FULL_THRESH),       // DECIMAL 8- 32763 32736
       //.RD_DATA_COUNT_WIDTH(16),        // DECIMAL
      .RELATED_CLOCKS(0),             // DECIMAL
      .SIM_ASSERT_CHK(0),             // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .TDATA_WIDTH(C_STREAM_DATA_WIDTH),               // DECIMAL Defines the width of the TDATA port, s_axis_tdata and m_axis_tdata
      .TDEST_WIDTH(1),                 // DECIMAL
      .TID_WIDTH(1),                   // DECIMAL
      .TUSER_WIDTH(1),                 // DECIMAL
       .USE_ADV_FEATURES("1006"),      // String USE_ADV_FEATURES[1] to 1 enables prog_full flag;
                                       // USE_ADV_FEATURES[2]  to 1 enables wr_data_count;
      .WR_DATA_COUNT_WIDTH(15)         // DECIMAL
   )
   xpm_fifo_axis_adc_0_i (
      .almost_empty_axis(),   // 1-bit output: Almost Empty : When asserted, this signal
                                               // indicates that only one more read can be performed before the
                                               // FIFO goes to empty.

      .almost_full_axis(),     // 1-bit output: Almost Full: When asserted, this signal
                                               // indicates that only one more write can be performed before
                                               // the FIFO is full.

      .dbiterr_axis(),             // 1-bit output: Double Bit Error- Indicates that the ECC
                                               // decoder detected a double-bit error and data in the FIFO core
                                               // is corrupted.

      .m_axis_tdata(fifo_axis_tdata),             // TDATA_WIDTH-bit output: TDATA: The primary payload that is
                                               // used to provide the data that is passing across the
                                               // interface. The width of the data payload is an integer number
                                               // of bytes.

      .m_axis_tdest(),             // TDEST_WIDTH-bit output: TDEST: Provides routing information
                                               // for the data stream.

      .m_axis_tid(),                 // TID_WIDTH-bit output: TID: The data stream identifier that
                                               // indicates different streams of data.

      .m_axis_tkeep(fifo_axis_tkeep),             // TDATA_WIDTH/8-bit output: TKEEP: The byte qualifier that
                                               // indicates whether the content of the associated byte of TDATA
                                               // is processed as part of the data stream. Associated bytes
                                               // that have the TKEEP byte qualifier deasserted are null bytes
                                               // and can be removed from the data stream. For a 64-bit DATA,
                                               // bit 0 corresponds to the least significant byte on DATA, and
                                               // bit 7 corresponds to the most significant byte. For example:
                                               // KEEP[0] = 1b, DATA[7:0] is not a NULL byte KEEP[7] = 0b,
                                               // DATA[63:56] is a NULL byte

      .m_axis_tlast(fifo_axis_tlast),             // 1-bit output: TLAST: Indicates the boundary of a packet.
      .m_axis_tstrb(),             // TDATA_WIDTH/8-bit output: TSTRB: The byte qualifier that
                                               // indicates whether the content of the associated byte of TDATA
                                               // is processed as a data byte or a position byte. For a 64-bit
                                               // DATA, bit 0 corresponds to the least significant byte on
                                               // DATA, and bit 0 corresponds to the least significant byte on
                                               // DATA, and bit 7 corresponds to the most significant byte. For
                                               // example: STROBE[0] = 1b, DATA[7:0] is valid STROBE[7] = 0b,
                                               // DATA[63:56] is not valid

      .m_axis_tuser(),             // TUSER_WIDTH-bit output: TUSER: The user-defined sideband
                                               // information that can be transmitted alongside the data
                                               // stream.

      .m_axis_tvalid(fifo_axis_tvalid),         // 1-bit output: TVALID: Indicates that the master is driving a
                                               // valid transfer. A transfer takes place when both TVALID and
                                               // TREADY are asserted

      .prog_empty_axis(),       // 1-bit output: Programmable Empty- This signal is asserted
                                               // when the number of words in the FIFO is less than or equal to
                                               // the programmable empty threshold value. It is de-asserted
                                               // when the number of words in the FIFO exceeds the programmable
                                               // empty threshold value.

      .prog_full_axis(fifo_prog_full_c2h_0),   // 1-bit output: Programmable Full: This signal is asserted when
                                               // the number of words in the FIFO is greater than or equal to
                                               // the programmable full threshold value. It is de-asserted when
                                               // the number of words in the FIFO is less than the programmable
                                               // full threshold value.

      .rd_data_count_axis(), // RD_DATA_COUNT_WIDTH-bit output: Read Data Count- rd_data_count This bus
                                               // indicates the number of words available for reading in the
                                               // FIFO.

      .s_axis_tready(fifo_ready_c2h_0),           // 1-bit output: TREADY: Indicates that the slave can accept a
                                               // transfer in the current cycle.

      .sbiterr_axis(),             // 1-bit output: Single Bit Error- Indicates that the ECC
                                               // decoder detected and fixed a single-bit error.

      .wr_data_count_axis(wr_data_count), // WR_DATA_COUNT_WIDTH-bit output: Write Data Count: This bus
                                               // indicates the number of words written into the FIFO.

      .injectdbiterr_axis(1'b0), // 1-bit input: Double Bit Error Injection- Injects a double bit
                                               // error if the ECC feature is used.

      .injectsbiterr_axis(1'b0), // 1-bit input: Single Bit Error Injection- Injects a single bit
                                               // error if the ECC feature is used.

      .m_aclk(),                         // 1-bit input: Master Interface Clock: All signals on master
                                               // interface are sampled on the rising edge of this clock.

      .m_axis_tready(fifo_axis_tready),           //  1-bit input: TREADY: Indicates that the slave can accept a
                                               // transfer in the current cycle.

      .s_aclk(adc_data_clk),                         // 1-bit input: Slave Interface Clock: All signals on slave
                                               // interface are sampled on the rising edge of this clock.

      .s_aresetn(axi_aresetn),                   // 1-bit input: Active low asynchronous reset.
      .s_axis_tdata(data_c2h_0_end_r),             // TDATA_WIDTH-bit input: TDATA: The primary payload that is
                                               // used to provide the data that is passing across the
                                               // interface. The width of the data payload is an integer number
                                               // of bytes.

      .s_axis_tdest(1'b0),             // TDEST_WIDTH-bit input: TDEST: Provides routing information
                                               // for the data stream.

      .s_axis_tid(1'b0),                 // TID_WIDTH-bit input: TID: The data stream identifier that
                                               // indicates different streams of data.

      .s_axis_tkeep(s_axis_tkeep_c),             // TDATA_WIDTH/8-bit input: TKEEP: The byte qualifier that
                                               // indicates whether the content of the associated byte of TDATA
                                               // is processed as part of the data stream. Associated bytes
                                               // that have the TKEEP byte qualifier deasserted are null bytes
                                               // and can be removed from the data stream. For a 64-bit DATA,
                                               // bit 0 corresponds to the least significant byte on DATA, and
                                               // bit 7 corresponds to the most significant byte. For example:
                                               // KEEP[0] = 1b, DATA[7:0] is not a NULL byte KEEP[7] = 0b,
                                               // DATA[63:56] is a NULL byte

      .s_axis_tlast(s_axis_tlast_r),             // 1-bit input: TLAST: Indicates the boundary of a packet.

      .s_axis_tstrb(s_axis_tstrb_c),             // TDATA_WIDTH/8-bit input: TSTRB: The byte qualifier that
                                               // indicates whether the content of the associated byte of TDATA
                                               // is processed as a data byte or a position byte. For a 64-bit
                                               // DATA, bit 0 corresponds to the least significant byte on
                                               // DATA, and bit 0 corresponds to the least significant byte on
                                               // DATA, and bit 7 corresponds to the most significant byte. For
                                               // example: STROBE[0] = 1b, DATA[7:0] is valid STROBE[7] = 0b,
                                               // DATA[63:56] is not valid

      .s_axis_tuser(1'b0),             // TUSER_WIDTH-bit input: TUSER: The user-defined sideband
                                               // information that can be transmitted alongside the data
                                               // stream.

      .s_axis_tvalid(data_vld_c2h_0_r)            // 1-bit input: TVALID: Indicates that the master is driving a
                                               // valid transfer. A transfer takes place when both TVALID and
                                               // TREADY are asserted

   );
   // End of xpm_fifo_axis_inst instantiation
   

   
   
   xpm_fifo_axis #(
      //.CDC_SYNC_STAGES(3),            // DECIMAL Range: 2 - 8. Default value = 2.
      .CLOCKING_MODE("independent_clock"), // String
      .ECC_MODE("no_ecc"),            // String
      .FIFO_DEPTH(512),              // DECIMAL 32768 (Max DEPTH* num of Bits= 4194304 bit)
      .FIFO_MEMORY_TYPE("bram"),      // String
      .PACKET_FIFO("false"),          // String
       //.PROG_EMPTY_THRESH(32736),         // DECIMAL
      .PROG_FULL_THRESH(FIFO_PROG_FULL_THRESH),       // DECIMAL 8- 32763 32736
       //.RD_DATA_COUNT_WIDTH(16),        // DECIMAL
      .RELATED_CLOCKS(0),             // DECIMAL
      .SIM_ASSERT_CHK(0),             // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .TDATA_WIDTH(C_STREAM_DATA_WIDTH),               // DECIMAL Defines the width of the TDATA port, s_axis_tdata and m_axis_tdata
      .TDEST_WIDTH(1),                 // DECIMAL
      .TID_WIDTH(1),                   // DECIMAL
      .TUSER_WIDTH(1),                 // DECIMAL
       .USE_ADV_FEATURES("0000"),      // String USE_ADV_FEATURES[1] to 1 enables prog_full flag;
                                       // USE_ADV_FEATURES[2]  to 1 enables wr_data_count;
      .WR_DATA_COUNT_WIDTH(15)         // DECIMAL
   )
   xpm_fifo_axis_cdc_adc (
      .almost_empty_axis(),                 // 1-bit output
      .almost_full_axis(),                  // 1-bit output 
      .dbiterr_axis(),                      // 1-bit output
      .m_axis_tdata(m_axis_tdata_0),        // TDATA_WIDTH-bit output
      .m_axis_tdest(),                      // TDEST_WIDTH-bit output
      .m_axis_tid(),                        // TID_WIDTH-bit output
      .m_axis_tkeep(m_axis_tkeep_0),        // TDATA_WIDTH/8-bit output
      .m_axis_tlast(m_axis_tlast_0),        // 1-bit output:
      .m_axis_tstrb(),                      // TDATA_WIDTH/8-bit output
      .m_axis_tuser(),                      // TUSER_WIDTH-bit output
      .m_axis_tvalid(m_axis_tvalid_0),      // 1-bit output
      .prog_empty_axis(),                   // 1-bit output:
      .prog_full_axis(),                    // 1-bit output.
      .rd_data_count_axis(),                // RD_DATA_COUNT_WIDTH-bit output
      .s_axis_tready(fifo_axis_tready),     // 1-bit output: TREADY
      .sbiterr_axis(),                      // 1-bit output
      .wr_data_count_axis(),                // WR_DATA_COUNT_WIDTH-bit output
      .injectdbiterr_axis(1'b0),            // 1-bit input
      .injectsbiterr_axis(1'b0),            // 1-bit input
      .m_aclk(axi_aclk),                    // 1-bit input
      .m_axis_tready(m_axis_tready_0),      //  1-bit input
      .s_aclk(adc_data_clk),                // 1-bit input
      .s_aresetn(axi_aresetn),              // 1-bit input
      .s_axis_tdata(fifo_axis_tdata),      // TDATA_WIDTH-bit input
      .s_axis_tdest(1'b0),                  // TDEST_WIDTH-bit input
      .s_axis_tid(1'b0),                    // TID_WIDTH-bit input
      .s_axis_tkeep(fifo_axis_tkeep),        // TDATA_WIDTH/8-bit input
      .s_axis_tlast(fifo_axis_tvalid),        // 1-bit input: TLAST
      .s_axis_tstrb(),        // TDATA_WIDTH/8-bit input
      .s_axis_tuser(1'b0),                  // TUSER_WIDTH-bit input
      .s_axis_tvalid(fifo_axis_tlast)      // 1-bit input
   );
   
endmodule
