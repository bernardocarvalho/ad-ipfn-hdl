// ***************************************************************************
// Copyright (C) 2023 Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsibilities that he or she has by using this source/core.
//
// This core is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE.
//
// Redistribution and use of source or resulting binaries, with or without modification
// of this file, are permitted under one of the following two license terms:
//
//   1. The GNU General Public License version 2 as published by the
//      Free Software Foundation, which can be found in the top level directory
//      of this repository (LICENSE_GPL2), and also online at:
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/100ps
`include "atca_k26_config.vh"
`include "control_word_bits.vh"

module system_top #(
// From xdma_id0034 Example Design  
   parameter PL_LINK_CAP_MAX_LINK_WIDTH          = 4,            // 1- X1; 2 - X2; 4 - X4; 8 - X8
   parameter PL_SIM_FAST_LINK_TRAINING           = "FALSE",      // Simulation Speedup
   parameter PL_LINK_CAP_MAX_LINK_SPEED          = 2,             // 1- GEN1; 2 - GEN2; 4 - GEN3
   parameter C_DATA_WIDTH                        = 128 ,
   parameter EXT_PIPE_SIM                        = "FALSE",  // This Parameter has effect on selecting Enable External PIPE Interface in GUI.
   parameter C_ROOT_PORT                         = "FALSE",      // PCIe block is in root port mode
   parameter C_DEVICE_NUMBER                     = 0,            // Device number for Root Port configurations only
   parameter AXIS_CCIX_RX_TDATA_WIDTH     = 256, 
   parameter AXIS_CCIX_TX_TDATA_WIDTH     = 256,
   parameter AXIS_CCIX_RX_TUSER_WIDTH     = 46,
   parameter AXIS_CCIX_TX_TUSER_WIDTH     = 46,
       
	parameter ADC_CHANNELS = 8,           // Maximum 48, Must be even  

    // Do not override parameters below this line
    parameter ADC_MODULES =  ADC_CHANNELS / 2,     	   
    parameter ADC_DATA_WIDTH   = 18,
    parameter TCQ        = 1

)
(
   // PCIEe
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] pcie_mgt_0_txp,
    output [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] pcie_mgt_0_txn,
    input  [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] pcie_mgt_0_rxp,
    input  [PL_LINK_CAP_MAX_LINK_WIDTH-1 : 0] pcie_mgt_0_rxn,

    input    sys_clk_p,
    input    sys_clk_n,
    input  sys_rst_n,  // This board uses ATCA RX3 signal
    
    
  output acq_clk_n,
  output acq_clk_p,
  output adc_cnvst_n,
  output adc_cnvst_p,
  output adc_sck_n,
  output adc_sck_p,
  output adc_sdi_n,
  output adc_sdi_p,
  input [ADC_MODULES-1 :0] adc_sdo_cha_n,
  input [ADC_MODULES-1 :0] adc_sdo_cha_p,
  input [ADC_MODULES-1 :0] adc_sdo_chb_n,
  input [ADC_MODULES-1 :0] adc_sdo_chb_p,
  output [3 :0] carrier_led,
  output    fan_en_b
);

   
   //  AXI_LITE_DATA_WIDTH
   localparam C_M_AXI_LITE_DATA_WIDTH = 32;  
   localparam C_S_AXI_LITE_DATA_WIDTH = C_M_AXI_LITE_DATA_WIDTH;
   localparam C_M_AXI_LITE_ADDR_WIDTH = 32;
   localparam C_S_AXI_LITE_ADDR_WIDTH = 10;

  wire    [94:0]  gpio_i;
  wire    [94:0]  gpio_o; 

   //----------PCIEe------------------------------------------------------------------------------------------------------//
   //  AXI Interface                                                                                                 //
   //----------------------------------------------------------------------------------------------------------------//
   wire                        axi_aclk;    //  125 Mhz
   wire                        axi_aresetn;

   wire                        user_lnk_up;

  //----------------------------------------------------------------------------------------------------------------//
  //    System(SYS) Interface                                                                                       //
  //----------------------------------------------------------------------------------------------------------------//
   //wire     sys_rst_n;
    wire                                    sys_clk;
    wire                                    sys_clk_gt;
    wire                                    sys_rst_n_c;


  // User Clock LED Heartbeat
     // reg [25:0]                  axi_aclk_heartbeat;
     reg              usr_irq_req = 0;
     wire             usr_irq_ack;

     wire pl_clk0_i, ps_periph_aresetn_i, ps_periph_reset_i;
     wire ila_clk;
     wire mmcm_100_locked_i;

//----------------------------------------------------------------------------------------------------------------//
//     AXI LITE Master
//----------------------------------------------------------------------------------------------------------------//
    //-- AXI Master Write Address Channel
    wire [C_M_AXI_LITE_ADDR_WIDTH-1:0] m_axil_awaddr;
   // wire [31:0] m_axil_awaddr;
    wire [2:0]  m_axil_awprot;
    wire    m_axil_awvalid;
    wire    m_axil_awready;

    //-- AXI Master Write Data Channel
    wire [C_M_AXI_LITE_DATA_WIDTH-1:0] m_axil_wdata;
    wire [3:0]  m_axil_wstrb;
    wire    m_axil_wvalid;
    wire    m_axil_wready;
    //-- AXI Master Write Response Channel
    wire    m_axil_bvalid;
    wire    m_axil_bready;
    //-- AXI Master Read Address Channel
    wire [C_M_AXI_LITE_ADDR_WIDTH-1:0]     m_axil_araddr;
    //wire [31:0] m_axil_araddr;
    wire [2:0]  m_axil_arprot;
    wire    m_axil_arvalid;
    wire    m_axil_arready;
    //-- AXI Master Read Data Channel
    wire [C_M_AXI_LITE_DATA_WIDTH-1:0] m_axil_rdata;
    wire [1:0]  m_axil_rresp;
    wire    m_axil_rvalid;
    wire    m_axil_rready;
    wire [1:0]  m_axil_bresp;

    wire [2:0]    msi_vector_width;
    wire          msi_enable;
    wire  [C_M_AXI_LITE_DATA_WIDTH-1:0] control_reg_i, chopp_period_i, channel_mask_i;
    wire  [575:0] eo_offset_i; 
    wire  [1023:0] wo_offset_i; 
    
   wire  adc_spi_clk, adc_read_clk;
    
   //wire [14:10] fifos_status_i;
   reg [4:0] fifos_status_cdc = 5'b00000;
   /*
   // xpm_cdc_array_single: Single-bit Array Synchronizer
   // Xilinx Parameterized Macro, version 2019.2
    xpm_cdc_array_single #(
      .DEST_SYNC_FF(4),   // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .SRC_INPUT_REG(1),  // DECIMAL; 0=do not register input, 1=register input
      .WIDTH(5)           // DECIMAL; range: 1-1024
   )
   xpm_cdc_array_single_cdc (
      .dest_out(fifos_status_cdc), // WIDTH-bit output: src_in synchronized to the destination clock domain. This
                           // output is registered.

      .dest_clk(axi_aclk), // 1-bit input: Clock signal for the destination clock domain.
      .src_clk(adc_read_clk),   // 1-bit input: optional; required when SRC_INPUT_REG = 1
      .src_in(fifos_status_i)      // WIDTH-bit input: Input single-bit array to be synchronized to destination clock
                           // domain. It is assumed that each bit of the array is unrelated to the others. This
                           // is reflected in the constraints applied to this macro. To transfer a binary value
                           // losslessly across the two clock domains, use the XPM_CDC_GRAY macro instead.
   );
*/

//            rtm_r8_i, atca_master, msi_enable, idelay_rdy_w,  // bits 23:20
//                            1'b0, atca_clk_locked_i, te0741_clk_100_locked_i, rtm_clk10_locked_i, // bits 19:16
//        i2C_reg0[7:0]}; // bits 7:0 atca slot_id 
    reg  acq_on_r, acq_on_q;
    wire [C_M_AXI_LITE_ADDR_WIDTH-1 :0] status_reg_i = {8'h00,  // bits 31:24
            2'b00, msi_enable, 1'b0,  // bits 23:20
            3'b000, mmcm_100_locked_i, // bits 19:16
            1'b0, fifos_status_cdc, acq_on_q, 1'b0,    // bits 15:8
            8'h00}; // bits 7:0 atca slot_id 

    //-- AXI streaming ports 1 * H2C, 2 * C2H
    wire [C_DATA_WIDTH-1:0] m_axis_h2c_tdata_0;
    wire            m_axis_h2c_tlast_0;
    wire            m_axis_h2c_tvalid_0;
    wire            m_axis_h2c_tready_0;
    wire [C_DATA_WIDTH/8-1:0]   m_axis_h2c_tkeep_0;

    wire [C_DATA_WIDTH-1:0] s_axis_c2h_tdata_0, s_axis_c2h_tdata_1;
    wire s_axis_c2h_tlast_0, s_axis_c2h_tlast_1;
    (* keep = "true" *) wire s_axis_c2h_tvalid_0, s_axis_c2h_tvalid_1;
    (* keep = "true" *) wire s_axis_c2h_tready_0, s_axis_c2h_tready_1;
    wire [C_DATA_WIDTH/8-1:0] s_axis_c2h_tkeep_0, s_axis_c2h_tkeep_1;

    wire  adc_cnvst;
    wire [ADC_DATA_WIDTH*ADC_CHANNELS-1 :0] adc_data_arr_i; //, adc_b_data_arr_i;

    assign m_axis_h2c_tready_0 = 1'b1; // Allways Flush H2C data, for now

   // PCIEe Ref clock buffer
    // Ref clock buffer

    IBUFDS_GTE4 # (.REFCLK_HROW_CK_SEL(2'b00)) 
        refclk_ibuf (.O(sys_clk_gt), .ODIV2(sys_clk), .I(sys_clk_p), .CEB(1'b0), .IB(sys_clk_n));
  // Reset buffer
    IBUF   sys_reset_n_ibuf (.O(sys_rst_n_c), .I(sys_rst_n));
     
   //IBUFDS_GTE4 refclk_ibuf (.O(sys_clk), .ODIV2(), .I(sys_clk_p), .CEB(1'b0), .IB(sys_clk_n));
     
  // PCIe Reset buffer
  //    IBUF atca_rx_3a_buf ( .O(sys_rst_n_c), .I(sys_rst_n ) ); // atca_3a_r

    OBUFDS adc_sdi_obuf ( .O(adc_sdi_p), .OB(adc_sdi_n), .I(adc_sdi));
    OBUFDS adc_sck_obuf ( .O(adc_sck_p), .OB(adc_sck_n), .I(adc_sck));
    OBUFDS cnvst_obuf ( .O(adc_cnvst_p), .OB(adc_cnvst_n), .I(adc_cnvst));
    OBUFDS acq_clk_obuf ( .O(acq_clk_p), .OB(acq_clk_n), .I(adc_spi_clk));

    assign gpio_i[94:1] = gpio_o[94:1];

    assign fan_en_b = gpio_o[0];

// required for crossing clock domains between the acqusition clock and the read clock.
    xpm_cdc_single #(
        .DEST_SYNC_FF(2),   // DECIMAL; range: 2-10
        .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
        .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
        .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
    )
    acq_on_cdc (
        .dest_out(acq_on_q), // 1-bit output: src_in synchronized to the destination clock domain. This output is
        // registered.
        .dest_clk(axi_aclk),   // 1-bit input: Clock signal for the destination clock domain.
        .src_clk(adc_read_clk),     // 1-bit input: optional; required when SRC_INPUT_REG = 1
        .src_in(acq_on_r)         // 1-bit input: Input signal to be synchronized to dest_clk domain.
    );

    reg [1:0] soft_trig_dly;
    reg [1:0] hard_trig_dly;
    reg [31:0] ps_clk_hb=32'd0;
    reg [31:0] pci_clk_hb=32'd0;
    
    always @(posedge axi_aclk) begin
        if(pci_clk_hb == 32'd124999999)
            pci_clk_hb <= 32'd0;
        else
            pci_clk_hb <= pci_clk_hb+32'd1; 
    end
    assign carrier_led[0] = pci_clk_hb > 32'd62499999;
    
    always @(posedge pl_clk0_i) begin
        if(ps_clk_hb == 32'd99999999)
            ps_clk_hb <= 32'd0;
        else
            ps_clk_hb <= ps_clk_hb+32'd1; 
    end
    assign carrier_led[1] = ps_clk_hb > 32'd49999999;
    assign carrier_led[2] = adc_spi_clk;
    assign carrier_led[3] = adc_read_clk;
    
    wire strg_sync;
    xpm_cdc_single #(
        .DEST_SYNC_FF(3),   // DECIMAL; range: 2-10
        .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
        .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
        .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
    )
    strg_cdc (
        .dest_out(strg_sync), // 1-bit output: src_in synchronized to the destination clock domain. This output is
        // registered.
        .dest_clk(adc_spi_clk),   // 1-bit input: Clock signal for the destination clock domain.
        .src_clk(axi_aclk),     // 1-bit input: optional; required when SRC_INPUT_REG = 1
        .src_in(control_reg_i[`STRG_BIT])         // 1-bit input: Input signal to be synchronized to dest_clk domain.
    );
    
   wire acqe_arst_sync;
   xpm_cdc_async_rst #(
      .DEST_SYNC_FF(4),    // DECIMAL; range: 2-10
      .INIT_SYNC_FF(0),    // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
      .RST_ACTIVE_HIGH(0)  // DECIMAL; 0=active low reset, 1=active high reset
   )
   xpm_cdc_async_rst_inst (
      .dest_arst(acqe_arst_sync), // 1-bit output: src_arst asynchronous reset signal synchronized to destination
                             // clock domain. This output is registered. NOTE: Signal asserts asynchronously
                             // but deasserts synchronously to dest_clk. Width of the reset signal is at least
                             // (DEST_SYNC_FF*dest_clk) period.

      .dest_clk(adc_read_clk),   // 1-bit input: Destination clock.
      .src_arst(control_reg_i[`ACQE_BIT])    // 1-bit input: Source asynchronous reset signal.
   );
   
    
// ---------------- Trigger generation -------------------------------//
    always @(posedge adc_read_clk or negedge acqe_arst_sync) begin
        if (!acqe_arst_sync)
        begin
            acq_on_r <= #TCQ  1'b0;
            soft_trig_dly <=  #TCQ 2'b11;
            hard_trig_dly <=  #TCQ 2'b00;
        end
        else
        begin
            soft_trig_dly <=  #TCQ  {soft_trig_dly[0], strg_sync}; // delay pipe
            hard_trig_dly <=  #TCQ  {hard_trig_dly[0], 1'b0};         // delay pipe
            //hard_trig_dly <=  #TCQ  {hard_trig_dly[0], atca_hard_trig_rcv};         // delay pipe

            if ((soft_trig_dly == 2'b01) || (hard_trig_dly == 2'b10)) // detect rising / falling edge
                acq_on_r <= #TCQ  1'b1;
        end
    end

  // instantiations
  system_wrapper i_system_wrapper (
      .gpio_i (gpio_i),
      .gpio_o (gpio_o),
      .gpio_t (),
      .pl_clk0(pl_clk0_i), // o
      .periph_aresetn(ps_periph_aresetn_i),
      .periph_reset(ps_periph_reset_i),
      .spi0_csn (),
      .spi0_miso (1'b0),
      .spi0_mosi (),
      .spi0_sclk ()
    );
    
  xdma_id0034 xdma_id0034_i (
      .sys_clk(sys_clk),                          // input wire sys_clk
      .sys_clk_gt(sys_clk_gt),                    // input wire sys_clk_gt
      .sys_rst_n(sys_rst_n_c),                      // input wire sys_rst_n
      .user_lnk_up(user_lnk_up),                  // output wire user_lnk_up
      .pci_exp_txp(pcie_mgt_0_txp),                  // output wire [3 : 0] pci_exp_txp
      .pci_exp_txn(pcie_mgt_0_txn),                  // output wire [3 : 0] pci_exp_txn
      .pci_exp_rxp(pcie_mgt_0_rxp),                  // input wire [3 : 0] pci_exp_rxp
      .pci_exp_rxn(pcie_mgt_0_rxn),                  // input wire [3 : 0] pci_exp_rxn
      .axi_aclk(axi_aclk),                        // output wire axi_aclk
      .axi_aresetn(axi_aresetn),                  // output wire axi_aresetn
      .usr_irq_req(usr_irq_req),                  // input wire [0 : 0] usr_irq_req
      .usr_irq_ack(usr_irq_ack),                  // output wire [0 : 0] usr_irq_ack
      .msi_enable(msi_enable),                    // output wire msi_enable
      .msi_vector_width(msi_vector_width),        // output wire [2 : 0] msi_vector_width
      .m_axil_awaddr(m_axil_awaddr),              // output wire [31 : 0] m_axil_awaddr
      .m_axil_awprot(m_axil_awprot),              // output wire [2 : 0] m_axil_awprot
      .m_axil_awvalid(m_axil_awvalid),            // output wire m_axil_awvalid
      .m_axil_awready(m_axil_awready),            // input wire m_axil_awready
      .m_axil_wdata(m_axil_wdata),                // output wire [31 : 0] m_axil_wdata
      .m_axil_wstrb(m_axil_wstrb),                // output wire [3 : 0] m_axil_wstrb
      .m_axil_wvalid(m_axil_wvalid),              // output wire m_axil_wvalid
      .m_axil_wready(m_axil_wready),              // input wire m_axil_wready
      .m_axil_bvalid(m_axil_bvalid),              // input wire m_axil_bvalid
      .m_axil_bresp(m_axil_bresp),                // input wire [1 : 0] m_axil_bresp
      .m_axil_bready(m_axil_bready),              // output wire m_axil_bready
      .m_axil_araddr(m_axil_araddr),              // output wire [31 : 0] m_axil_araddr
      .m_axil_arprot(m_axil_arprot),              // output wire [2 : 0] m_axil_arprot
      .m_axil_arvalid(m_axil_arvalid),            // output wire m_axil_arvalid
      .m_axil_arready(m_axil_arready),            // input wire m_axil_arready
      .m_axil_rdata(m_axil_rdata),                // input wire [31 : 0] m_axil_rdata
      .m_axil_rresp(m_axil_rresp),                // input wire [1 : 0] m_axil_rresp
      .m_axil_rvalid(m_axil_rvalid),              // input wire m_axil_rvalid
      .m_axil_rready(m_axil_rready),              // output wire m_axil_rready
      .s_axis_c2h_tdata_0(s_axis_c2h_tdata_0),    // input wire [127 : 0] s_axis_c2h_tdata_0
      .s_axis_c2h_tlast_0(s_axis_c2h_tlast_0),    // input wire s_axis_c2h_tlast_0
      .s_axis_c2h_tvalid_0(s_axis_c2h_tvalid_0),  // input wire s_axis_c2h_tvalid_0
      .s_axis_c2h_tready_0(s_axis_c2h_tready_0),  // output wire s_axis_c2h_tready_0
      .s_axis_c2h_tkeep_0(s_axis_c2h_tkeep_0),    // input wire [15 : 0] s_axis_c2h_tkeep_0
      .m_axis_h2c_tdata_0(m_axis_h2c_tdata_0),    // output wire [127 : 0] m_axis_h2c_tdata_0
      .m_axis_h2c_tlast_0(m_axis_h2c_tlast_0),    // output wire m_axis_h2c_tlast_0
      .m_axis_h2c_tvalid_0(m_axis_h2c_tvalid_0),  // output wire m_axis_h2c_tvalid_0
      .m_axis_h2c_tready_0(m_axis_h2c_tready_0),  // input wire m_axis_h2c_tready_0
      .m_axis_h2c_tkeep_0(m_axis_h2c_tkeep_0),    // output wire [15 : 0] m_axis_h2c_tkeep_0
      .s_axis_c2h_tdata_1(s_axis_c2h_tdata_1),    // input wire [127 : 0] s_axis_c2h_tdata_1
      .s_axis_c2h_tlast_1(s_axis_c2h_tlast_1),    // input wire s_axis_c2h_tlast_1
      .s_axis_c2h_tvalid_1(s_axis_c2h_tvalid_1),  // input wire s_axis_c2h_tvalid_1
      .s_axis_c2h_tready_1(s_axis_c2h_tready_1),  // output wire s_axis_c2h_tready_1
      .s_axis_c2h_tkeep_1(s_axis_c2h_tkeep_1)    // input wire [15 : 0] s_axis_c2h_tkeep_1
    );

   shapi_regs # (
        .C_S_AXI_DATA_WIDTH(C_S_AXI_LITE_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S_AXI_LITE_ADDR_WIDTH)
    ) shapi_regs_inst (
        .S_AXI_ACLK(axi_aclk),
        .S_AXI_ARESETN(axi_aresetn), //i
        .S_AXI_AWADDR(m_axil_awaddr[C_S_AXI_LITE_ADDR_WIDTH-1 :0]),
        //.S_AXI_AWPROT(s_axil_awprot), // Not used
        .S_AXI_AWVALID(m_axil_awvalid),
        .S_AXI_AWREADY(m_axil_awready),
        .S_AXI_WDATA(m_axil_wdata),
        .S_AXI_WSTRB(m_axil_wstrb),
        .S_AXI_WVALID(m_axil_wvalid),
        .S_AXI_WREADY(m_axil_wready),
        .S_AXI_BRESP(m_axil_bresp),
        .S_AXI_BVALID(m_axil_bvalid),
        .S_AXI_BREADY(m_axil_bready),
        .S_AXI_ARADDR(m_axil_araddr[9:0]),

        .S_AXI_ARVALID(m_axil_arvalid),
        .S_AXI_ARREADY(m_axil_arready),
        .S_AXI_RDATA(m_axil_rdata),
        .S_AXI_RRESP(m_axil_rresp),
        .S_AXI_RVALID(m_axil_rvalid),
        .S_AXI_RREADY(m_axil_rready),
          
        .dev_hard_reset(dev_hard_reset_i),
        .status_reg(status_reg_i),   // i
        .control_reg(control_reg_i), // o
        .eo_offset(eo_offset_i),  // o
        .wo_offset(wo_offset_i),  // o
        
        .debug_0(32'hAABBCCDD),   // i
        .debug_1(32'hAABB0011),   // i
        
        .chopp_period(chopp_period_i),  // o
        .channel_mask(channel_mask_i)   // o
    );

   system_clocks system_clocks_inst (
    // Status and control signals
        .reset(!axi_aresetn), // input sys_reset? 
        .locked(mmcm_100_locked_i),       // output 
    // Clock in ports
        .clk_in(pl_clk0_i),      // input clk_in1
        // Clock out ports
        .clk_out2(adc_spi_clk),     // output 80Mhz 80MHz 0º
        .clk_out3(adc_read_clk),     // output 80Mhz but delayed for 47nsec 80MHz 180º
        .clk_out1(ila_clk)
        
    );
    
   wire [5:0] adc_spi_clk_count_i;
   wire reader_en_sync;
   
   wire adc_rst_sync;   
   xpm_cdc_single #(
        .DEST_SYNC_FF(3),   // DECIMAL; range: 2-10
        .INIT_SYNC_FF(0),   // DECIMAL; 0=disable simulation init values, 1=enable simulation init values
        .SIM_ASSERT_CHK(0), // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
        .SRC_INPUT_REG(1)   // DECIMAL; 0=do not register input, 1=register input
    )
    adc_rst_cdc (
        .dest_out(adc_rst_sync), // 1-bit output: src_in synchronized to the destination clock domain. This output is
        // registered.
        .dest_clk(adc_spi_clk),   // 1-bit input: Clock signal for the destination clock domain.
        .src_clk(axi_aclk),     // 1-bit input: optional; required when SRC_INPUT_REG = 1
        .src_in(control_reg_i[`ADC_RST])         // 1-bit input: Input signal to be synchronized to dest_clk domain.
    );
   
   ad4003_deserializer #(.ADC_CHANNELS(ADC_CHANNELS)) 
    ad4003_deserializer_inst (
       .ila_clk(ila_clk),
       .rst(adc_rst_sync), // i CHECK This
       .adc_spi_clk(adc_spi_clk),    // i
       .adc_read_clk(adc_read_clk),   // i  
       .adc_spi_clk_count(adc_spi_clk_count_i),  // o [5:0]
       .cnvst(adc_cnvst),          // o
       .sdi(adc_sdi),              // o
       .sck(adc_sck),              // o
       .adc_sdo_cha_p(adc_sdo_cha_p), // i [ADC_MODULES-1 :0] 
       .adc_sdo_cha_n(adc_sdo_cha_n), // i
       .adc_sdo_chb_p(adc_sdo_chb_p), // i
       .adc_sdo_chb_n(adc_sdo_chb_n), // i 
       .adc_data_arr(adc_data_arr_i)  // o
   );
   
// ---            ADC data acquisition and packeting ---------
  xdma_data_producer #(
    .C_S_AXI_DATA_WIDTH(C_M_AXI_LITE_DATA_WIDTH),
    .C_STREAM_DATA_WIDTH(C_DATA_WIDTH),
    .ADC_CHANNELS(ADC_CHANNELS)) 
    xdma_data_producer_inst (
        .axi_aclk(axi_aclk),
        .axi_aresetn(axi_aresetn),

        .adc_data_clk(adc_read_clk),  // i
        .adc_clk_cnt(adc_spi_clk_count_i),  // i [5:0]

        .control_reg(control_reg_i),
        //.channel_mask(channel_mask_i),
        .acq_on(acq_on_r),
        //.fifos_status(fifos_status_i),  // o [14:10]

        //.adc_a_data_arr(adc_a_data_arr_i), // i [ADC_DATA_WIDTH*ADC_MODULES-1 :0] 
        .adc_data_arr(adc_data_arr_i), // i  [ADC_DATA_WIDTH*ADC_CHANNELS-1 :0]  

        // AXI streaming ports
        .m_axis_tdata_0(s_axis_c2h_tdata_0),
        .m_axis_tlast_0(s_axis_c2h_tlast_0),
        .m_axis_tvalid_0(s_axis_c2h_tvalid_0),
        .m_axis_tready_0(s_axis_c2h_tready_0),
        .m_axis_tkeep_0(s_axis_c2h_tkeep_0),

        .m_axis_tdata_1(s_axis_c2h_tdata_1),
        .m_axis_tlast_1(s_axis_c2h_tlast_1),
        .m_axis_tvalid_1(s_axis_c2h_tvalid_1),
        .m_axis_tkeep_1(s_axis_c2h_tkeep_1),
        .m_axis_tready_1(s_axis_c2h_tready_1)
  );

endmodule
