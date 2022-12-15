//////////////////////////////////////////////////////////////////////////////////
// Company: IPFN IST
// Engineer: Bernardo Carvalho
//
// vim: sta:et:sw=4:ts=4:sts=4
//
// Create Date: 04/30/2021 03:15:44 PM
// Design Name:
// Module Name: system_top
// Project Name: ESTHER Shock Tube Trigger/DAQ system
// Target Devices: Kintex-7
// Tool Versions: Vivado 2019.1
// Description:
//
// Dependencies:
//      trigger_gen
// Additional Comments:
//
// Copyright 2018-2023 IPFN-Instituto Superior Tecnico, Portugal
// Creation Date   04/30/2018 03:15:44 PM
//
// Licensed under the EUPL, Version 1.2 or - as soon they
// will be approved by the European Commission - subsequent
// versions of the EUPL (the "Licence");
//
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
//

`timescale 1ns/100ps

`define ACQE_BIT 		23
`define STRG_BIT 		24 // Soft Trigger

module system_top #

  (
   parameter PL_LINK_CAP_MAX_LINK_WIDTH          = 8,            // 1- X1; 2 - X2; 4 - X4; 8 - X8
   parameter PL_SIM_FAST_LINK_TRAINING           = "FALSE",      // Simulation Speedup
   parameter PL_LINK_CAP_MAX_LINK_SPEED          = 2,             // 1- GEN1; 2 - GEN2; 4 - GEN3
   parameter C_DATA_WIDTH                        = 128 ,
   parameter EXT_PIPE_SIM                        = "FALSE",  // This Parameter has effect on selecting Enable External PIPE Interface in GUI.
   parameter C_ROOT_PORT                         = "FALSE",      // PCIe block is in root port mode
   parameter C_DEVICE_NUMBER                     = 0,            // Device number for Root Port configurations only
   parameter AXIS_CCIX_RX_TDATA_WIDTH     = 256,
   parameter AXIS_CCIX_TX_TDATA_WIDTH     = 256,
   parameter AXIS_CCIX_RX_TUSER_WIDTH     = 46,
   parameter AXIS_CCIX_TX_TUSER_WIDTH     = 46
   )
(

    input                   sys_rst,
    input                   sys_clk_p,
    input                   sys_clk_n,

    input                   uart_sin,
    output                  uart_sout,

    output      [ 2:0]      ddr3_1_n,
    output      [ 1:0]      ddr3_1_p,
    output                  ddr3_reset_n,
    output      [13:0]      ddr3_addr,
    output      [ 2:0]      ddr3_ba,

    output                  ddr3_cas_n,
    output                  ddr3_ras_n,
    output                  ddr3_we_n,
    output      [ 0:0]      ddr3_ck_n,
    output      [ 0:0]      ddr3_ck_p,

    output      [ 0:0]      ddr3_cke,
    output      [ 0:0]      ddr3_cs_n,

    output      [ 7:0]      ddr3_dm,
    inout       [63:0]      ddr3_dq,
    inout       [ 7:0]      ddr3_dqs_n,
    inout       [ 7:0]      ddr3_dqs_p,
    output      [ 0:0]      ddr3_odt,

    output                  mdio_mdc,
    inout                   mdio_mdio,
    output                  mii_rst_n,
    input                   mii_col,

    input                   mii_crs,
    input                   mii_rx_clk,
    input                   mii_rx_er,
    input                   mii_rx_dv,
    input       [ 3:0]      mii_rxd,


    input                   mii_tx_clk,
    output                  mii_tx_en,
    output      [ 3:0]      mii_txd,

    output      [26:1]      linear_flash_addr,
    output                  linear_flash_adv_ldn,
    output                  linear_flash_ce_n,
    inout       [15:0]      linear_flash_dq_io,
    output                  linear_flash_oen,
    output                  linear_flash_wen,

    output                  fan_pwm,

    inout       [ 6:0]      gpio_lcd,
    inout       [16:0]      gpio_bd,

    output                  iic_rstn,
    inout                   iic_scl,
    inout                   iic_sda,

    input                   rx_ref_clk_p,

    input                   rx_ref_clk_n,
    output                  rx_sysref,
    output                  rx_sync,
    input       [ 3:0]      rx_data_p,
    input       [ 3:0]      rx_data_n,


    output                  spi_csn_0,
    output                  spi_clk,
    inout                   spi_sdio,

// IPFN mods

  // User SMA Clocks
    output          user_sma_clk_p, // SMA J11

    output          user_sma_clk_n, // SMA J12
    //User SMA Gpios
    output          user_sma_gpio_p, //Y23 USER_SMA_GPIO_P LVCMOS25 J13.1
    output          user_sma_gpio_n, //Y24 USER_SMA_GPIO_N LVCMOS25 J14.1 bellow J11


    //PciE
    output  [(PL_LINK_CAP_MAX_LINK_WIDTH - 1):0]    pci_exp_txp,
    output  [(PL_LINK_CAP_MAX_LINK_WIDTH - 1):0]    pci_exp_txn,
    input   [(PL_LINK_CAP_MAX_LINK_WIDTH - 1):0]    pci_exp_rxp,
    input   [(PL_LINK_CAP_MAX_LINK_WIDTH - 1):0]    pci_exp_rxn,

    input   pci_sys_clk_p,
    input   pci_sys_clk_n,
    input   pci_sys_rst_n
  );

   // Local Parameters derived from user selection
   localparam integer                              USER_CLK_FREQ         = ((PL_LINK_CAP_MAX_LINK_SPEED == 3'h4) ? 5 : 4);
   localparam TCQ = 1;

   localparam C_S_AXI_ID_WIDTH = 4;
   localparam C_M_AXI_ID_WIDTH = 4;
   localparam C_S_AXI_DATA_WIDTH = C_DATA_WIDTH;
   localparam C_M_AXI_DATA_WIDTH = C_DATA_WIDTH;
   localparam C_S_AXI_ADDR_WIDTH = 64;
   localparam C_M_AXI_ADDR_WIDTH = 64;
   localparam C_NUM_USR_IRQ      = 1;

    localparam N_ADC_CHANNELS  = 4;

  // internal signals

  wire    [63:0]  gpio_i;
  wire    [63:0]  gpio_o;
  wire    [63:0]  gpio_t;
  wire    [ 7:0]  spi_csn;
  wire            spi_mosi;
  wire            spi_miso;
  wire            rx_ref_clk;
  wire            rx_clk;

  wire    [N_ADC_CHANNELS-1:0] adc_enable;
  wire    [N_ADC_CHANNELS-1:0] adc_valid;
  wire    [31:0] adc_data[0:N_ADC_CHANNELS-1]; // array of  32-bit registers;

  assign ddr3_1_p = 2'b11;
  assign ddr3_1_n = 3'b000;
  assign fan_pwm = 1'b1;
  assign iic_rstn = 1'b1;
  assign spi_csn_0 = spi_csn[0];

  //----------------------------------------------------------------------------------------------------------------//
   //  AXI Interface                                                                                                 //
   //----------------------------------------------------------------------------------------------------------------//

   wire 					   pci_user_clk;
   wire 					   pci_user_resetn;
// PCIe XDMA
   wire 					   pci_user_lnk_up;
//----------------------------------------------------------------------------------------------------------------//
  //    System(SYS) Interface                                                                                       //
  //----------------------------------------------------------------------------------------------------------------//

    wire                                    pci_sys_clk;
    wire                                    pci_sys_rst_n_c;

  // User Clock LED Heartbeat
     reg [25:0]                              user_clk_heartbeat;
     reg [((2*C_NUM_USR_IRQ)-1):0]              usr_irq_function_number=0;
     reg [C_NUM_USR_IRQ-1:0]                 usr_irq_req = 0;
     wire [C_NUM_USR_IRQ-1:0]                usr_irq_ack;

      //-- AXI Master Write Address Channel
     wire [C_M_AXI_ADDR_WIDTH-1:0] m_axi_awaddr;
     wire [C_M_AXI_ID_WIDTH-1:0] m_axi_awid;
     wire [2:0]                  m_axi_awprot;
     wire [1:0]                  m_axi_awburst;
     wire [2:0]                  m_axi_awsize;
     wire [3:0]                  m_axi_awcache;
     wire [7:0]                  m_axi_awlen;
     wire                        m_axi_awlock;
     wire                        m_axi_awvalid;
     wire                        m_axi_awready;

     //-- AXI Master Write Data Channel
     wire [C_M_AXI_DATA_WIDTH-1:0]     m_axi_wdata;
     wire [(C_M_AXI_DATA_WIDTH/8)-1:0] m_axi_wstrb;
     wire                              m_axi_wlast;
     wire                              m_axi_wvalid;
   //-- AXI Master Write Response Channel
     wire                              m_axi_bvalid;
     wire                              m_axi_bready;
     wire [C_M_AXI_ID_WIDTH-1 : 0]     m_axi_bid ;
     wire [1:0]                        m_axi_bresp ;

     //-- AXI Master Read Address Channel
     wire [C_M_AXI_ID_WIDTH-1 : 0]     m_axi_arid;
     wire [C_M_AXI_ADDR_WIDTH-1:0]     m_axi_araddr;
     wire [7:0]                        m_axi_arlen;
     wire [2:0]                        m_axi_arsize;
     wire [1:0]                        m_axi_arburst;
     wire [2:0]                        m_axi_arprot;
     wire                              m_axi_arvalid;
     wire                              m_axi_arready;
     wire                              m_axi_arlock;
     wire [3:0]                        m_axi_arcache;
     //-- AXI Master Read Data Channel
     wire [C_M_AXI_ID_WIDTH-1 : 0]   m_axi_rid;
     wire [C_M_AXI_DATA_WIDTH-1:0]   m_axi_rdata;
     wire [1:0]                      m_axi_rresp;
     wire                            m_axi_rvalid;
     wire                            m_axi_rready;

//////////////////////////////////////////////////  AXI Master LITE
   //-- AXI Master Write Address Channel
    wire [31:0] m_axil_awaddr;
    wire [2:0]  m_axil_awprot;
    wire        m_axil_awvalid;
    wire        m_axil_awready;

    //-- AXI Master Write Data Channel
    wire [31:0] m_axil_wdata;
    wire [3:0]  m_axil_wstrb;
    wire        m_axil_wvalid;
    wire        m_axil_wready;
    //-- AXI Master Write Response Channel
    wire        m_axil_bvalid;
    wire        m_axil_bready;
    //-- AXI Master Read Address Channel
    wire [31:0] m_axil_araddr;
    wire [2:0]  m_axil_arprot;
    wire        m_axil_arvalid;
    wire        m_axil_arready;
    //-- AXI Master Read Data Channel
    wire [31:0] m_axil_rdata;
    wire [1:0]  m_axil_rresp;
    wire        m_axil_rvalid;
    wire        m_axil_rready;
    wire [1:0]  m_axil_bresp;

    wire [2:0]    msi_vector_width;
    wire          msi_enable;
     // AXI streaming ports
    wire [C_DATA_WIDTH-1:0]     m_axis_h2c_tdata_0;
    wire                        m_axis_h2c_tlast_0;
    wire                        m_axis_h2c_tvalid_0;
    wire                        m_axis_h2c_tready_0;
    wire [C_DATA_WIDTH/8-1:0]   m_axis_h2c_tkeep_0;
    wire [C_DATA_WIDTH-1:0] s_axis_c2h_tdata_0;
    wire s_axis_c2h_tlast_0;
    wire s_axis_c2h_tvalid_0;
    wire s_axis_c2h_tready_0;
    wire [C_DATA_WIDTH/8-1:0] s_axis_c2h_tkeep_0;


    wire [31:0] triglvl_0, triglvl_1, triglvl_2;
    wire [31:0] param_mul_i, param_off_i, init_delay_i, pulse_tof_i;

    wire [31:0] control_reg_i;
    wire acq_en_i = control_reg_i[`ACQE_BIT];
    wire [7:0] detect_pls_i;
    //wire trigger1_i;

    // instantiations
  wire sma_j11 =  detect_pls_i[0];
  OBUF   obuf_J11  (.O(user_sma_clk_p),  .I(sma_j11));
  wire sma_j12 =  detect_pls_i[1];
  OBUF   obuf_J12  (.O(user_sma_clk_n),  .I(sma_j12));
  wire sma_j4_1 =  detect_pls_i[2];
  OBUF   obuf_J4_1 (.O(user_sma_gpio_n), .I(acq_en_i)); // J14.1 bellow J11
  OBUF   obuf_j13 (.O(user_sma_gpio_p), .I(detect_pls_i[3]));

  IBUFDS_GTE2 i_ibufds_rx_ref_clk (
    .CEB (1'd0),
    .I (rx_ref_clk_p),
    .IB (rx_ref_clk_n),
    .O (rx_ref_clk),
    .ODIV2 ()
  );

  ad_iobuf #(.DATA_WIDTH(17)) i_iobuf (
    .dio_t (gpio_t[16:0]),
    .dio_i (gpio_o[16:0]),
    .dio_o (gpio_i[16:0]),
    .dio_p (gpio_bd)
  );

  assign gpio_i[63:32] = gpio_o[63:32];
  assign gpio_i[31:17] = gpio_o[31:17];

  fmcjesdadc1_spi i_fmcjesdadc1_spi (
    .spi_csn (spi_csn[0]),
    .spi_clk (spi_clk),
    .spi_mosi (spi_mosi),
    .spi_miso (spi_miso),
    .spi_sdio (spi_sdio)
  );

  ad_sysref_gen #(.SYSREF_PERIOD(64)) i_sysref (
    .core_clk (rx_clk),
    .sysref_en (gpio_o[32]),
    .sysref_out (rx_sysref)
  );

 // Ref clock buffer
  IBUFDS_GTE2 pci_refclk_ibuf (.O(pci_sys_clk), .ODIV2(), .I(pci_sys_clk_p), .CEB(1'b0), .IB(pci_sys_clk_n));
  // Reset buffer
  IBUF   pci_sys_reset_n_ibuf (.O(pci_sys_rst_n_c), .I(pci_sys_rst_n));

 // PCIe XDMA Core Top Level Wrapper

  xdma_8g2 xdma_id7028_i
     (
      //---------------------------------------------------------------------------------------//
      //  PCI Express (pci_exp) Interface                                                      //
      //---------------------------------------------------------------------------------------//
      .sys_rst_n       ( pci_sys_rst_n_c ),
      .sys_clk         ( pci_sys_clk ),

      // Tx
      .pci_exp_txn     ( pci_exp_txn ),
      .pci_exp_txp     ( pci_exp_txp ),

      // Rx
      .pci_exp_rxn     ( pci_exp_rxn ),
      .pci_exp_rxp     ( pci_exp_rxp ),

      // AXI streaming ports
      .s_axis_c2h_tdata_0(s_axis_c2h_tdata_0),
      .s_axis_c2h_tlast_0(s_axis_c2h_tlast_0),
      .s_axis_c2h_tvalid_0(s_axis_c2h_tvalid_0),
      .s_axis_c2h_tready_0(s_axis_c2h_tready_0), // O
      .s_axis_c2h_tkeep_0(s_axis_c2h_tkeep_0),
      .m_axis_h2c_tdata_0(m_axis_h2c_tdata_0),
      .m_axis_h2c_tlast_0(m_axis_h2c_tlast_0),
      .m_axis_h2c_tvalid_0(m_axis_h2c_tvalid_0),
      .m_axis_h2c_tready_0(m_axis_h2c_tready_0),
      .m_axis_h2c_tkeep_0(m_axis_h2c_tkeep_0),
     // LITE interface
      //-- AXI Master Write Address Channel
      .m_axil_awaddr    (m_axil_awaddr),
      .m_axil_awprot    (m_axil_awprot),
      .m_axil_awvalid   (m_axil_awvalid),
      .m_axil_awready   (m_axil_awready),
      //-- AXI Master Write Data Channel
      .m_axil_wdata     (m_axil_wdata),
      .m_axil_wstrb     (m_axil_wstrb),
      .m_axil_wvalid    (m_axil_wvalid),
      .m_axil_wready    (m_axil_wready),
      //-- AXI Master Write Response Channel
      .m_axil_bvalid    (m_axil_bvalid),
      .m_axil_bresp     (m_axil_bresp),
      .m_axil_bready    (m_axil_bready),
      //-- AXI Master Read Address Channel
      .m_axil_araddr    (m_axil_araddr),
      .m_axil_arprot    (m_axil_arprot),
      .m_axil_arvalid   (m_axil_arvalid),
      .m_axil_arready   (m_axil_arready),
      .m_axil_rdata     (m_axil_rdata),
      //-- AXI Master Read Data Channel
      .m_axil_rresp     (m_axil_rresp),
      .m_axil_rvalid    (m_axil_rvalid),
      .m_axil_rready    (m_axil_rready),


      .usr_irq_req       (usr_irq_req),
      .usr_irq_ack       (usr_irq_ack),
      .msi_enable        (msi_enable),
      .msi_vector_width  (msi_vector_width),

      //-- AXI Global
      .axi_aclk        ( pci_user_clk ),
      .axi_aresetn   (pci_user_resetn),

      .user_lnk_up     ( pci_user_lnk_up )
    );


    system_wrapper i_system_wrapper (

        .adc_data_a (adc_data[0]),
        .adc_enable_a (adc_enable[0]),
        .adc_valid_a (adc_valid[0]),
        .adc_data_b (adc_data[1]),
        .adc_enable_b (adc_enable[1]),
        .adc_valid_b (adc_valid[1]),
        .adc_data_c (adc_data[2]),
        .adc_enable_c (adc_enable[2]),
        .adc_valid_c (adc_valid[2]),
        .adc_data_d (adc_data[3]),
        .adc_enable_d (adc_enable[3]),
        .adc_valid_d (adc_valid[3]),

        .ddr3_addr (ddr3_addr),
        .ddr3_ba (ddr3_ba),
        .ddr3_cas_n (ddr3_cas_n),
        .ddr3_ck_n (ddr3_ck_n),
        .ddr3_ck_p (ddr3_ck_p),
        .ddr3_cke (ddr3_cke),
        .ddr3_cs_n (ddr3_cs_n),
        .ddr3_dm (ddr3_dm),
        .ddr3_dq (ddr3_dq),
        .ddr3_dqs_n (ddr3_dqs_n),
        .ddr3_dqs_p (ddr3_dqs_p),
        .ddr3_odt (ddr3_odt),
        .ddr3_ras_n (ddr3_ras_n),
        .ddr3_reset_n (ddr3_reset_n),
        .ddr3_we_n (ddr3_we_n),
        .gpio0_i (gpio_i[31:0]),
        .gpio0_o (gpio_o[31:0]),
        .gpio0_t (gpio_t[31:0]),
        .gpio1_i (gpio_i[63:32]),
        .gpio1_o (gpio_o[63:32]),
        .gpio1_t (gpio_t[63:32]),
        .gpio_lcd_tri_io (gpio_lcd),
        .iic_main_scl_io (iic_scl),
        .iic_main_sda_io (iic_sda),
        .mdio_mdc (mdio_mdc),
        .mdio_mdio_io (mdio_mdio),
        .mii_col (mii_col),
        .mii_crs (mii_crs),
        .mii_rst_n (mii_rst_n),
        .mii_rx_clk (mii_rx_clk),
        .mii_rx_dv (mii_rx_dv),
        .mii_rx_er (mii_rx_er),
        .mii_rxd (mii_rxd),
        .mii_tx_clk (mii_tx_clk),
        .mii_tx_en (mii_tx_en),
        .mii_txd (mii_txd),
        .linear_flash_addr (linear_flash_addr),
        .linear_flash_adv_ldn (linear_flash_adv_ldn),
        .linear_flash_ce_n (linear_flash_ce_n),
        .linear_flash_dq_io (linear_flash_dq_io),
        .linear_flash_oen (linear_flash_oen),
        .linear_flash_wen (linear_flash_wen),
        .sys_clk_n (sys_clk_n),
        .sys_clk_p (sys_clk_p),
        .sys_rst (sys_rst),
        .uart_sin (uart_sin),
        .uart_sout (uart_sout),
        .rx_data_0_n (rx_data_n[0]),
        .rx_data_0_p (rx_data_p[0]),
        .rx_data_1_n (rx_data_n[1]),
        .rx_data_1_p (rx_data_p[1]),
        .rx_data_2_n (rx_data_n[2]),
        .rx_data_2_p (rx_data_p[2]),
        .rx_data_3_n (rx_data_n[3]),
        .rx_data_3_p (rx_data_p[3]),
        .rx_ref_clk_0 (rx_ref_clk),
        .rx_sync_0 (rx_sync),
        .rx_sysref_0 (rx_sysref),
        .rx_core_clk (rx_clk),
        .spi_clk_i (spi_clk),
        .spi_clk_o (spi_clk),
        .spi_csn_i (spi_csn),
        .spi_csn_o (spi_csn),
        .spi_sdi_i (spi_miso),
        .spi_sdo_i (spi_mosi),
        .spi_sdo_o (spi_mosi)
    );

    // BAR0 register Space 8-bit address, 32-bit Data
    (* keep = "true" *) reg  acq_on_r, acq_on_q;
    wire almost_full_axis, almost_empty_axis; //, prog_full, prog_empty;
    //wire [31:0] control_reg_i;

    wire [15:0] rd_data_count;
    wire prog_empty_axis_pre;
    wire [31:0] status_reg_i = {rd_data_count,
        detect_pls_i,
        3'h0, acq_on_r,      almost_full_axis, almost_empty_axis, 1'b0, prog_empty_axis_pre}; //, prog_full, prog_empty};

    shapi_regs_v1 # (
        .C_S_AXI_DATA_WIDTH(32),
        .C_S_AXI_ADDR_WIDTH(8)
    ) shapi_regs_v1_inst (
        .S_AXI_ACLK(pci_user_clk),
        .S_AXI_ARESETN(pci_user_resetn),
        .S_AXI_AWADDR(m_axil_awaddr[7:0]),
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
        //.S_AXI_ARPROT(s_axil_arprot), // Not used
        .S_AXI_ARVALID(m_axil_arvalid),
        .S_AXI_ARREADY(m_axil_arready),
        .S_AXI_RDATA(m_axil_rdata),
        .S_AXI_RRESP(m_axil_rresp),
        .S_AXI_RVALID(m_axil_rvalid),
        .S_AXI_RREADY(m_axil_rready),

        .status_reg(status_reg_i),
        .trig_0(triglvl_0),
        .trig_1(triglvl_1),  // I
        .trig_2(triglvl_2),
        .param_mul(param_mul_i),
        .param_off(param_off_i),
        .init_delay(init_delay_i),

        .pulse_tof(pulse_tof_i),

        .control_reg(control_reg_i)
    );

    trigger_gen trigger_gen_i (
        .rxclk(rx_clk), // 125MHz

        .adc_data_a (adc_data[0]),
        .adc_enable_a (adc_enable[0]),
        //.adc_valid_a (adc_valid[0]),

        .adc_data_b (adc_data[1]),

        .adc_enable_b (adc_enable[1]),
        //.adc_valid_b (adc_valid[1]),

        .adc_data_c (adc_data[2]),
        .adc_enable_c (adc_enable[2]),
        //.adc_valid_c (adc_valid[2]),

        .adc_data_d (adc_data[3]),
        .adc_enable_d (adc_enable[3]),
        //.adc_valid_d (adc_valid[3]),

        // Latency 480 ns ?
        //Trigger levels are positive

        .trig_enable(acq_en_i), // bit 4 second gpio gpio_o[36]

        .trig_level_a(triglvl_0),
        .trig_level_b(triglvl_1),  // i
        .trig_level_c(triglvl_2),
        .param_mul(param_mul_i),
        .param_off(param_off_i),

        .init_delay(init_delay_i),

        .pulse_tof(pulse_tof_i), // o

        .detect_pls (detect_pls_i)  // o
    );

    // AXI streaming ports

    reg [14:0] s_axis_c2h_cnt = 15'h00; // 15'h3FF;

    always @(posedge pci_user_clk or negedge pci_user_resetn)
        if (!pci_user_resetn)
            s_axis_c2h_cnt <= 15'h00;
        else if (s_axis_c2h_tvalid_0 && s_axis_c2h_tready_0)
            s_axis_c2h_cnt <= s_axis_c2h_cnt +1;

    assign s_axis_c2h_tlast_0 = (s_axis_c2h_cnt ==15'h3FF)? 1'b1:1'b0;// m_axis_h2c_tlast_0;

    //-- H2C data dump
    assign m_axis_h2c_tready_0 = 1'b1; // H2C data discarded

    wire almost_full_axis_pre;

    reg [15:0] adc_cnt = 'h00;
    wire [31:0] adc_data3  = adc_data[3];
    wire [C_S_AXI_DATA_WIDTH-1:0] adc_data_all = {adc_cnt[15:3], almost_empty_axis, almost_full_axis, almost_full_axis_pre, adc_data3[15:0], adc_data[2], adc_data[1], adc_data[0]};
    wire  adc_dma_tvalid = adc_enable[0]; // && detect_0_i; //&& adc_valid[0] Write DMA FIFO only after trigger 0

    reg [1:0] acq_soft_trig_dly, acq_hard_trig_dly;

    // -- Trigger generation
    always @(posedge pci_user_clk or negedge acq_en_i) begin
        if (!acq_en_i)
        begin
            acq_on_r <= #TCQ  1'b0;
            acq_soft_trig_dly <=  #TCQ 2'b11;
            acq_hard_trig_dly <=  #TCQ 2'b11;
        end
        else
        begin
            acq_soft_trig_dly <=  #TCQ  {acq_soft_trig_dly[0], control_reg_i[`STRG_BIT]}; // delay pipe
            acq_hard_trig_dly <=  #TCQ  {acq_hard_trig_dly[0], detect_pls_i[1]}; // delay pipe

            if( (acq_soft_trig_dly == 2'b01) ||  (acq_hard_trig_dly == 2'b01)) // detect rising  edge
                acq_on_r <= #TCQ  1'b1;
        end
    end

    wire s_axis_tready_pre;
    always @(posedge rx_clk or posedge sys_rst)
        if (sys_rst)
            adc_cnt <= 0;
        else if (adc_dma_tvalid) // && s_axis_tready_pre)
            adc_cnt <= adc_cnt + 1;

    reg acq_on_rx_r = 1'b0;
    always @(posedge rx_clk or posedge sys_rst)
        if (sys_rst)
            acq_on_rx_r <= 1'b0;
        else
            acq_on_rx_r <= acq_on_r;

    wire   m_axis_tready_main = s_axis_c2h_tready_0 || (!acq_on_r ) ;// && prog_full); // Flush MAIN buffer on ACQ OFF
    wire   m_axis_tvalid_main;
    assign s_axis_c2h_tvalid_0 = m_axis_tvalid_main &&  acq_on_r ; // Stream only with ACQ ON

    wire [127:0] m_axis_tdata_pre;
    wire s_axis_tready_main;

    //wire m_axis_tready_pre = s_axis_tready_main || ( (!acq_on_r) && (!prog_empty_axis_pre) ) ; // on ACQ disable, fill  PRE  buffer up to  almost_full
    //    wire m_axis_tready_pre = s_axis_tready_main || ( (!acq_on_r) && almost_full_axis_pre ) ; // on ACQ disable, fill  PRE  buffer up to  almost_full
    wire m_axis_tready_pre = (acq_on_r)? s_axis_tready_main :
                                         almost_full_axis_pre; // on ACQ disable, empty PRE  buffer when almost_full ( keep pre-trigger samples)
                                         //  !prog_empty_axis_pre;  
    wire m_axis_tvalid_pre;
    wire s_axis_tvalid_main = m_axis_tvalid_pre &&  acq_on_rx_r ; // Fill Main only with ACQ ON

    xpm_fifo_axis #(
        .CDC_SYNC_STAGES(3),            // DECIMAL Range: 2 - 8. Default value = 2.
        .CLOCKING_MODE("independent_clock"), // String
        //.CLOCKING_MODE("common_clock"), // String
        .ECC_MODE("no_ecc"),            // String
        .FIFO_DEPTH(32768),              // DECIMAL    ~0.25 ms pre-trigger ACQ
        .FIFO_MEMORY_TYPE("auto"),      // String
        .PACKET_FIFO("false"),          // String
        .PROG_EMPTY_THRESH(32760),         // DECIMAL 
        .PROG_FULL_THRESH(32760),       // DECIMAL 8- 32763 // Not used
        //.RD_DATA_COUNT_WIDTH(14),        // DECIMAL
        .RELATED_CLOCKS(0),             // DECIMAL
        .SIM_ASSERT_CHK(0),             // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
        .TDATA_WIDTH(128),               // DECIMAL Defines the width of the TDATA port, s_axis_tdata and m_axis_tdata
        .TDEST_WIDTH(1),                // DECIMAL
        .TID_WIDTH(1),                  // DECIMAL
        .TUSER_WIDTH(1),                // DECIMAL
        .USE_ADV_FEATURES("0208")      // String  [3] enables almost_full flag; 
                                        //         [9]  to 1 enables prog_empty flag; 
        //.WR_DATA_COUNT_WIDTH(15)         // DECIMAL log2(32768) + 1 = 16
    ) xpm_fifo_axis_pre_trigg_i (
        .almost_empty_axis(),   // 1-bit output: Almost Empty : When asserted, this signal
        // indicates that only one more user_clkread can be performed before the
        // FIFO goes to empty.

        .almost_full_axis(almost_full_axis_pre),     // 1-bit output: Almost Full: When asserted, this signal
        // indicates that only one more write can be performed before
        // the FIFO is full.

        .dbiterr_axis(),             // 1-bit output: Double Bit Error- Indicates that the ECC
        // decoder detected a double-bit error and data in the FIFO core
        // is corrupted.

        .m_axis_tdata(m_axis_tdata_pre),        // TDATA_WIDTH-bit output: TDATA: The primary payload that is m_axis128_data
        // used to provide the data that is passing across the
        // interface. The width of the data payload is an integer number
        // of bytes.

        .m_axis_tdest(),             // TDEST_WIDTH-bit output: TDEST: Provides routing information
        // for the data stream.

        .m_axis_tid(),                 // TID_WIDTH-bit output: TID: The data stream identifier that
        // indicates different streams of data.

        .m_axis_tkeep(),             // TDATA_WIDTH/8-bit output: TKEEP: The byte qualifier that
        // indicates whether the content of the associated byte of TDATA
        // is processed as part of the data stream. Associated bytes
        // that have the TKEEP byte qualifier deasserted are null bytes
        // and can be removed from the data stream. For a 64-bit DATA,
        // bit 0 corresponds to the least significant byte on DATA, and
        // bit 7 corresponds to the most significant byte. For example:
        // KEEP[0] = 1b, DATA[7:0] is not a NULL byte KEEP[7] = 0b,
        // DATA[63:56] is a NULL byte

        .m_axis_tlast(),             // 1-bit output: TLAST: Indicates the boundary of a packet.
        .m_axis_tstrb(),             // TDATA_WIDTH/8-bit output: TSTRB: The byte qualifier that
        // indicates whether the content of the associated byte of TDATA
        // is processed as a data byte or a position byte. For a 64-bit
        // DATA, biprog_empty_axis_pret 0 corresponds to the least significant byte on
        // DATA, and bit 0 corresponds to the least significant byte on
        // DATA, and bit 7 corresponds to the most significant byte. For
        // example: STROBE[0] = 1b, DATA[7:0] is valid STROBE[7] = 0b,
        // DATA[63:56] is not valid

        .m_axis_tuser(),             // TUSER_WIDTH-bit output: TUSER: The user-defined sideband
        // information that can be transmitted alongside the data
        // stream.

        .m_axis_tvalid(m_axis_tvalid_pre),           // 1-bit output: TVALID: Indicates that the master is driving a m_axis128_tvalid
        // valid transfer. A transfer takes place when both TVALID and
        // TREADY are asserted

        .prog_empty_axis(prog_empty_axis_pre),       // 1-bit output: Programmable Empty- This signal is asserted
        // when the number of words in the FIFO is less than or equal to
        // the programmable empty threshold value. It is de-asserted
        // when the number of words in the FIFO exceeds the programmable
        // empty threshold value.

        .prog_full_axis(),         // 1-bit output: Programmable Full: This signal is asserted when
        // the number of words in the FIFO is greater than or equal to
        // the programmable full threshold value. It is de-asserted when
        // the number of words in the FIFO is less than the programmable
        // full threshold value.

        .rd_data_count_axis(), // RD_DATA_COUNT_WIDTH-bit output: Read Data Count- This bus
        // indicates the number of words available for reading in the
        // FIFO.

        .s_axis_tready(s_axis_tready_pre),           // 1-bit output: TREADY: Indicates that the slave can accept a
        // transfer in the current cycle.

        .sbiterr_axis(),             // 1-bit output: Single Bit Error- Indicates that the ECC
        // decoder detected and fixed a single-bit error.

        .wr_data_count_axis(), // WR_DATA_COUNT_WIDTH-bit output: Write Data Count: This bus
        // indicates the number of words written into the FIFO.

        .injectdbiterr_axis(1'b0), // 1-bit input: Double Bit Error Injection- Injects a double bit
        // error if the ECC feature is used.

        .injectsbiterr_axis(1'b0), // 1-bit input: Single Bit Error Injection- Injects a single bit
        // error if the ECC feature is used.

        //.m_aclk(),                         // 1-bit input: Master Interface Clock:
        .m_aclk(pci_user_clk),                         // 1-bit input: Master Interface Clock:

        .m_axis_tready(m_axis_tready_pre),           // 1-bit input: TREADY: Indicates that the slave can accept a 
        // transfer in the current cycle.

        .s_aclk(rx_clk),                         // 1-bit input: Slave Interface Clock:

        .s_aresetn(pci_user_resetn),                   // 1-bit input: Active low asynchronous reset.
        .s_axis_tdata(adc_data_all),             // TDATA_WIDTH-bit input: TDATA: The primary payload that is
        // used to provide the data that is passing across the
        // interface. The width of the data payload is an integer number
        // of bytes.

        .s_axis_tdest(1'b0),             // TDEST_WIDTH-bit input: TDEST: Provides routing information
        // for the data stream.

        .s_axis_tid(1'b0),                 // TID_WIDTH-bit input: TID: The data stream identifier that
        // indicates different streams of data.

        .s_axis_tkeep(16'hFFFF),             // TDATA_WIDTH/8-bit input: TKEEP: The byte qualifier that
        // indicates whether the content of the associated byte of TDATA
        // is processed as part of the data stream. Associated bytes
        // that have the TKEEP byte qualifier deasserted are null bytes
        // and can be removed from the data stream. For a 64-bit DATA,
        // bit 0 corresponds to the least significant byte on DATA, and
        // bit 7 corresponds to the most significant byte. For example:
        // KEEP[0] = 1b, DATA[7:0] is not a NULL byte KEEP[7] = 0b,
        // DATA[63:56] is a NULL byte

        .s_axis_tlast(1'b0),             // 1-bit input: TLAST: Indicates the boundary of a packet.
        .s_axis_tstrb(8'h00),             // TDATA_WIDTH/8-bit input: TSTRB: The byte qualifier that
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

        .s_axis_tvalid(adc_dma_tvalid)            // 1-bit input: TVALID: Indicates that the master is driving a
        // valid transfer. A transfer takes place when both TVALID and
        // TREADY are asserted

    );

    xpm_fifo_axis #(
        .CDC_SYNC_STAGES(3),            // DECIMAL Range: 2 - 8. Default value = 2.
        //.CLOCKING_MODE("independent_clock"), 
        .CLOCKING_MODE("common_clock"), // String
        .ECC_MODE("no_ecc"),            // String
        .FIFO_DEPTH(32768),              // DECIMAL 131072 65536  32768 (65536 Max 4194304 bit?) ~0.5 ms ACQ
        .FIFO_MEMORY_TYPE("auto"),      // String
        .PACKET_FIFO("false"),          // String
        .PROG_EMPTY_THRESH(10000),         // DECIMAL
        .PROG_FULL_THRESH(20000),       // DECIMAL 8- 32763
        .RD_DATA_COUNT_WIDTH(16),        // DECIMAL
        .RELATED_CLOCKS(0),             // DECIMAL
        .SIM_ASSERT_CHK(0),             // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
        .TDATA_WIDTH(128),               // DECIMAL Defines the width of the TDATA port, s_axis_tdata and m_axis_tdata
        .TDEST_WIDTH(1),                // DECIMAL
        .TID_WIDTH(1),                  // DECIMAL
        .TUSER_WIDTH(1),                // DECIMAL
        //      .USE_ADV_FEATURES("0202"),      // String

        // |   Setting USE_ADV_FEATURES[3]  to 1 enables almost_full flag;  Default value of this bit is 0                       |
        // |   Setting USE_ADV_FEATURES[11] to 1 enables almost_empty flag; Default value of this bit is 0               
        .USE_ADV_FEATURES("0808"),      // String

        //.USE_ADV_FEATURES("0E0A"),      // String
        .WR_DATA_COUNT_WIDTH(16)         // DECIMAL
    ) xpm_fifo_axis_c2h0_i (
        .almost_empty_axis(almost_empty_axis),   // 1-bit output: Almost Empty : When asserted, this signal
        // indicates that only one more user_clkread can be performed before the
        // FIFO goes to empty.

        .almost_full_axis(almost_full_axis),     // 1-bit output: Almost Full: When asserted, this signal
        // indicates that only one more write can be performed before
        // the FIFO is full.

        .dbiterr_axis(),             // 1-bit output: Double Bit Error- Indicates that the ECC
        // decoder detected a double-bit error and data in the FIFO core
        // is corrupted.

        .m_axis_tdata(s_axis_c2h_tdata_0),        // TDATA_WIDTH-bit output: TDATA: The primary payload that is m_axis128_data
        // used to provide the data that is passing across the
        // interface. The width of the data payload is an integer number
        // of bytes.

        .m_axis_tdest(),             // TDEST_WIDTH-bit output: TDEST: Provides routing information
        // for the data stream.

        .m_axis_tid(),                 // TID_WIDTH-bit output: TID: The data stream identifier that
        // indicates different streams of data.

        .m_axis_tkeep(s_axis_c2h_tkeep_0),             // TDATA_WIDTH/8-bit output: TKEEP: The byte qualifier that
        // indicates whether the content of the associated byte of TDATA
        // is processed as part of the data stream. Associated bytes
        // that have the TKEEP byte qualifier deasserted are null bytes
        // and can be removed from the data stream. For a 64-bit DATA,
        // bit 0 corresponds to the least significant byte on DATA, and
        // bit 7 corresponds to the most significant byte. For example:
        // KEEP[0] = 1b, DATA[7:0] is not a NULL byte KEEP[7] = 0b,
        // DATA[63:56] is a NULL byte

        .m_axis_tlast(),             // 1-bit output: TLAST: Indicates the boundary of a packet.
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

        .m_axis_tvalid(m_axis_tvalid_main),           // 1-bit output: TVALID: Indicates that the master is driving a m_axis128_tvalid
        // valid transfer. A transfer takes place when both TVALID and
        // TREADY are asserted

        .prog_empty_axis(),       // 1-bit output: Programmable Empty- This signal is asserted
        // when the number of words in the FIFO is less than or equal to
        // the programmable empty threshold value. It is de-asserted
        // when the number of words in the FIFO exceeds the programmable
        // empty threshold value.

        .prog_full_axis(),         // 1-bit output: Programmable Full: This signal is asserted when
        // the number of words in the FIFO is greater than or equal to
        // the programmable full threshold value. It is de-asserted when
        // the number of words in the FIFO is less than the programmable
        // full threshold value.

        .rd_data_count_axis(rd_data_count), // RD_DATA_COUNT_WIDTH-bit output: Read Data Count- This bus
        // indicates the number of words available for reading in the
        // FIFO.

        .s_axis_tready(s_axis_tready_main),           // 1-bit output: TREADY: Indicates that the slave can accept a
        // transfer in the current cycle.

        .sbiterr_axis(),             // 1-bit output: Single Bit Error- Indicates that the ECC
        // decoder detected and fixed a single-bit error.

        .wr_data_count_axis(), // WR_DATA_COUNT_WIDTH-bit output: Write Data Count: This bus
        // indicates the number of words written into the FIFO.

        .injectdbiterr_axis(1'b0), // 1-bit input: Double Bit Error Injection- Injects a double bit
        // error if the ECC feature is used.

        .injectsbiterr_axis(1'b0), // 1-bit input: Single Bit Error Injection- Injects a single bit
        // error if the ECC feature is used.

        //.m_aclk(pci_user_clk),                         // 1-bit input: Master Interface Clock:
        .m_aclk(),                         // 1-bit input: Master Interface Clock: All signals on slave clock
        // interface are sampled on the rising edge of this clock.

        .m_axis_tready(m_axis_tready_main),           // 1-bit input: TREADY: Indicates that the slave can accept a m_axis128_tvalid
        // transfer in the current cycle.

        //.s_aclk(rx_clk),                         // 1-bit input: Slave Interface Clock: All signals on slave clock
        .s_aclk(pci_user_clk),                         // 1-bit input: Slave Interface Clock: All signals on slave clock
        // interface are sampled on the rising edge of this clock.

        .s_aresetn(pci_user_resetn),                   // 1-bit input: Active low asynchronous reset.
        .s_axis_tdata(m_axis_tdata_pre),             // TDATA_WIDTH-bit input: TDATA: The primary payload that is
        // used to provide the data that is passing across the
        // interface. The width of the data payload is an integer number
        // of bytes.

        .s_axis_tdest(1'b0),             // TDEST_WIDTH-bit input: TDEST: Provides routing information
        // for the data stream.

        .s_axis_tid(1'b0),                 // TID_WIDTH-bit input: TID: The data stream identifier that
        // indicates different streams of data.

        .s_axis_tkeep(16'hFFFF),             // TDATA_WIDTH/8-bit input: TKEEP: The byte qualifier that
        // indicates whether the content of the associated byte of TDATA
        // is processed as part of the data stream. Associated bytes
        // that have the TKEEP byte qualifier deasserted are null bytes
        // and can be removed from the data stream. For a 64-bit DATA,
        // bit 0 corresponds to the least significant byte on DATA, and
        // bit 7 corresponds to the most significant byte. For example:
        // KEEP[0] = 1b, DATA[7:0] is not a NULL byte KEEP[7] = 0b,
        // DATA[63:56] is a NULL byte

        .s_axis_tlast(1'b0),             // 1-bit input: TLAST: Indicates the boundary of a packet.
        .s_axis_tstrb(8'h00),             // TDATA_WIDTH/8-bit input: TSTRB: The byte qualifier that
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

        .s_axis_tvalid(s_axis_tvalid_main)            // 1-bit input: TVALID: Indicates that the master is driving a
        // valid transfer. A transfer takes place when both TVALID and
        // TREADY are asserted

    );

endmodule

// ***************************************************************************
// XPM_FIFO instantiation template for AXI Stream FIFO configurations
// Refer to the targeted device family architecture libraries guide for XPM_FIFO documentation
// =======================================================================================================================

// Parameter usage table, organized as follows:
// +---------------------------------------------------------------------------------------------------------------------+
// | Parameter name       | Data type          | Restrictions, if applicable                                             |
// |---------------------------------------------------------------------------------------------------------------------|
// | Description                                                                                                         |
// +---------------------------------------------------------------------------------------------------------------------+
// +---------------------------------------------------------------------------------------------------------------------+
// | CDC_SYNC_STAGES      | Integer            | Range: 2 - 8. Default value = 2.                                        |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specifies the number of synchronization stages on the CDC path.                                                     |
// | Applicable only if CLOCKING_MODE = "independent_clock"                                                              |
// +---------------------------------------------------------------------------------------------------------------------+
// | CLOCKING_MODE        | String             | Allowed values: common_clock, independent_clock. Default value = common_clock.|
// |---------------------------------------------------------------------------------------------------------------------|
// | Designate whether AXI Stream FIFO is clocked with a common clock or with independent clocks-                        |
// |                                                                                                                     |
// |   "common_clock"- Common clocking; clock both write and read domain s_aclk                                          |
// |   "independent_clock"- Independent clocking; clock write domain with s_aclk and read domain with m_aclk             |
// +---------------------------------------------------------------------------------------------------------------------+
// | ECC_MODE             | String             | Allowed values: no_ecc, en_ecc. Default value = no_ecc.                 |
// |---------------------------------------------------------------------------------------------------------------------|
// |                                                                                                                     |
// |   "no_ecc" - Disables ECC                                                                                           |
// |   "en_ecc" - Enables both ECC Encoder and Decoder                                                                   |
// |                                                                                                                     |
// | NOTE: ECC_MODE should be "no_ecc" if FIFO_MEMORY_TYPE is set to "auto". Violating this may result incorrect behavior.|
// +---------------------------------------------------------------------------------------------------------------------+
// | FIFO_DEPTH           | Integer            | Range: 16 - 4194304. Default value = 2048.                              |
// |---------------------------------------------------------------------------------------------------------------------|
// | Defines the AXI Stream FIFO Write Depth, must be power of two                                                       |
// | NOTE: The maximum FIFO size (width x depth) is limited to 150-Megabits.                                             |
// +---------------------------------------------------------------------------------------------------------------------+
// | FIFO_MEMORY_TYPE     | String             | Allowed values: auto, block, distributed, ultra. Default value = auto.  |
// |---------------------------------------------------------------------------------------------------------------------|
// | Designate the fifo memory primitive (resource type) to use-                                                         |
// |                                                                                                                     |
// |   "auto"- Allow Vivado Synthesis to choose                                                                          |
// |   "block"- Block RAM FIFO                                                                                           |
// |   "distributed"- Distributed RAM FIFO                                                                               |
// |   "ultra"- URAM FIFO                                                                                                |
// |                                                                                                                     |
// | NOTE: There may be a behavior mismatch if Block RAM or Ultra RAM specific features, like ECC or Asymmetry, are selected with FIFO_MEMORY_TYPE set to "auto".|
// +---------------------------------------------------------------------------------------------------------------------+
// | PACKET_FIFO          | String             | Allowed values: false, true. Default value = false.                     |
// |---------------------------------------------------------------------------------------------------------------------|
// |                                                                                                                     |
// |   "true"- Enables Packet FIFO mode                                                                                  |
// |   "false"- Disables Packet FIFO mode                                                                                |
// +---------------------------------------------------------------------------------------------------------------------+
// | PROG_EMPTY_THRESH    | Integer            | Range: 5 - 4194301. Default value = 10.                                 |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specifies the minimum number of read words in the FIFO at or below which prog_empty is asserted.                    |
// |                                                                                                                     |
// |   Min_Value = 5                                                                                                     |
// |   Max_Value = FIFO_WRITE_DEPTH - 5                                                                                  |
// |                                                                                                                     |
// | NOTE: The default threshold value is dependent on default FIFO_WRITE_DEPTH value. If FIFO_WRITE_DEPTH value is      |
// | changed, ensure the threshold value is within the valid range though the programmable flags are not used.           |
// +---------------------------------------------------------------------------------------------------------------------+
// | PROG_FULL_THRESH     | Integer            | Range: 5 - 4194301. Default value = 10.                                 |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specifies the maximum number of write words in the FIFO at or above which prog_full is asserted.                    |
// |                                                                                                                     |
// |   Min_Value = 5 + CDC_SYNC_STAGES                                                                                   |
// |   Max_Value = FIFO_WRITE_DEPTH - 5                                                                                  |
// |                                                                                                                     |
// | NOTE: The default threshold value is dependent on default FIFO_WRITE_DEPTH value. If FIFO_WRITE_DEPTH value is      |
// | changed, ensure the threshold value is within the valid range though the programmable flags are not used.           |
// +---------------------------------------------------------------------------------------------------------------------+
// | RD_DATA_COUNT_WIDTH  | Integer            | Range: 1 - 23. Default value = 1.                                       |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specifies the width of rd_data_count_axis. To reflect the correct value, the width should be log2(FIFO_DEPTH)+1.    |
// +---------------------------------------------------------------------------------------------------------------------+
// | RELATED_CLOCKS       | Integer            | Range: 0 - 1. Default value = 0.                                        |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specifies if the s_aclk and m_aclk are related having the same source but different clock ratios.                   |
// | Applicable only if CLOCKING_MODE = "independent_clock"                                                              |
// +---------------------------------------------------------------------------------------------------------------------+
// | SIM_ASSERT_CHK       | Integer            | Range: 0 - 1. Default value = 0.                                        |
// |---------------------------------------------------------------------------------------------------------------------|
// | 0- Disable simulation message reporting. Messages related to potential misuse will not be reported.                 |
// | 1- Enable simulation message reporting. Messages related to potential misuse will be reported.                      |
// +---------------------------------------------------------------------------------------------------------------------+
// | TDATA_WIDTH          | Integer            | Range: 8 - 2048. Default value = 32.                                    |
// |---------------------------------------------------------------------------------------------------------------------|
// | Defines the width of the TDATA port, s_axis_tdata and m_axis_tdata                                                  |
// | NOTE: The maximum FIFO size (width x depth) is limited to 150-Megabits.                                             |
// +---------------------------------------------------------------------------------------------------------------------+
// | TDEST_WIDTH          | Integer            | Range: 1 - 32. Default value = 1.                                       |
// |---------------------------------------------------------------------------------------------------------------------|
// | Defines the width of the TDEST port, s_axis_tdest and m_axis_tdest                                                  |
// +---------------------------------------------------------------------------------------------------------------------+
// | TID_WIDTH            | Integer            | Range: 1 - 32. Default value = 1.                                       |
// |---------------------------------------------------------------------------------------------------------------------|
// | Defines the width of the ID port, s_axis_tid and m_axis_tid                                                         |
// +---------------------------------------------------------------------------------------------------------------------+
// | TUSER_WIDTH          | Integer            | Range: 1 - 4086. Default value = 1.                                     |
// |---------------------------------------------------------------------------------------------------------------------|
// | Defines the width of the TUSER port, s_axis_tuser and m_axis_tuser                                                  |
// +---------------------------------------------------------------------------------------------------------------------+
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
// |   Setting USE_ADV_FEATURES[11] to 1 enables almost_empty flag; Default value of this bit is 0                       |
// +---------------------------------------------------------------------------------------------------------------------+
// | WR_DATA_COUNT_WIDTH  | Integer            | Range: 1 - 23. Default value = 1.                                       |
// |---------------------------------------------------------------------------------------------------------------------|
// | Specifies the width of wr_data_count_axis. To reflect the correct value, the width should be log2(FIFO_DEPTH)+1.    |
// +---------------------------------------------------------------------------------------------------------------------+

// ***************************************************************************
