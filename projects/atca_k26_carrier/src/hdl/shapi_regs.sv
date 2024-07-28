//////////////////////////////////////////////////////////////////////////////////
// Company: IPFN-IST
// Engineer: BBC
//
// Create Date: 05/08/2021 07:21:01 PM
// Design Name:
// Module Name: shapi_regs
// Project Name:
// Target Devices: kintex-7
// Tool Versions:  Vivado 2023.1
// Description: 
//          AXI  LITE Slave module to read / write internal Board registers 
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// Copyright 2015 - 2023 IPFN-Instituto Superior Tecnico, Portugal
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
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ps
`include "atca_k26_config.vh"
`include "shapi_stdrt_dev_inc.vh"

module shapi_regs #
    (
        // Users to add parameters here
        parameter ADC_DATA_WIDTH   = `ADC_DATA_WIDTH,
        parameter FLOAT_WIDTH      = `FLOAT_WIDTH,

        parameter N_ADC_CHANNELS   = `N_ADC_MAX_CHANNELS,
        parameter N_INT_CHANNELS   = `N_INT_CHANNELS,

        // User parameters ends
        // Do not modify the parameters beyond this line

        // Width of S_AXI data bus
        parameter integer C_S_AXI_DATA_WIDTH    = 32,
        // Width of S_AXI address bus
        parameter integer C_S_AXI_ADDR_WIDTH    = 10,

        parameter N_ILOCK_PARAMS   =  N_INT_CHANNELS + 2,
        //parameter EO_WIDTH   = ADC_DATA_WIDTH;
        parameter EO_VECT_WIDTH   = ADC_DATA_WIDTH * N_ADC_CHANNELS,
        parameter WO_VECT_WIDTH   = FLOAT_WIDTH    * N_ADC_CHANNELS,
        
        parameter TCQ        = 1
    )
    (

        // Global Clock Signal
        input wire  S_AXI_ACLK,
        // Global Reset Signal. This Signal is Active LOW
        input wire  S_AXI_ARESETN,
        // Write address (issued by master, acceped by Slave)
        input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
        // Write address valid. This signal indicates that the master signaling
            // valid write address and control information.
        input wire  S_AXI_AWVALID,
        // Write address ready. This signal indicates that the slave is ready
            // to accept an address and associated control signals.
        output wire  S_AXI_AWREADY,
        // Write data (issued by master, acceped by Slave)
        input wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
        // Write strobes. This signal indicates which byte lanes hold
            // valid data. There is one write strobe bit for each eight
            // bits of the write data bus.
        input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
        // Write valid. This signal indicates that valid write
            // data and strobes are available.
        input wire  S_AXI_WVALID,
        // Write ready. This signal indicates that the slave
            // can accept the write data.
        output wire  S_AXI_WREADY,
        // Write response. This signal indicates the status
            // of the write transaction.
        output wire [1 : 0] S_AXI_BRESP,
        // Write response valid. This signal indicates that the channel
            // is signaling a valid write response.
        output wire  S_AXI_BVALID,
        // Response ready. This signal indicates that the master
            // can accept a write response.
        input wire  S_AXI_BREADY,
        // Read address (issued by master, acceped by Slave)
        input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
        // Read address valid. This signal indicates that the channel
            // is signaling valid read address and control information.
        input wire  S_AXI_ARVALID,
        // Read address ready. This signal indicates that the slave is
            // ready to accept an address and associated control signals.
        output wire  S_AXI_ARREADY,
        // Read data (issued by slave)
        output wire [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
        // Read response. This signal indicates the status of the
            // read transfer.
        output wire [1 : 0] S_AXI_RRESP,
        // Read valid. This signal indicates that the channel is
            // signaling the required read data.
        output wire  S_AXI_RVALID,
        // Read ready. This signal indicates that the master can
            // accept the read data and response information.
        input wire  S_AXI_RREADY,

        //ADC Port
        input       [C_S_AXI_DATA_WIDTH-1 :0]  status_reg,
        output      [C_S_AXI_DATA_WIDTH-1 :0]  control_reg,

        input       [C_S_AXI_DATA_WIDTH-1 :0]  debug_0,
        input       [C_S_AXI_DATA_WIDTH-1 :0]  debug_1,
        input       [C_S_AXI_DATA_WIDTH-1 :0]  debug_2,
        input       [C_S_AXI_DATA_WIDTH-1 :0]  debug_3,
                                
        output             dev_hard_reset,


        //output      [31:0]  i2C_reg1,
        output     [EO_VECT_WIDTH-1 : 0]  eo_offset,
        output     [WO_VECT_WIDTH-1 : 0]  wo_offset,


        output      [C_S_AXI_DATA_WIDTH-1:0]  channel_mask,

        output      [C_S_AXI_DATA_WIDTH-1:0]  chopp_period

    );

/*********** Function Declarations ***************/
// Extend raw ADC data to 32 bit
    function  [FLOAT_WIDTH-1:0] adc18_extend_f;
        input [ADC_DATA_WIDTH-1:0] adc_data;
         begin
            adc18_extend_f =  {{14{adc_data[ADC_DATA_WIDTH-1]}}, adc_data};  // extend sign bit to 32 bits
         end
      endfunction

//--      IPFN ATCA-MIMO-ISOL v2 regs

    reg   [C_S_AXI_DATA_WIDTH-1:0]  chopp_period_r, channel_mask_r;
    reg   [24:0] control_r;
    
    reg   [EO_VECT_WIDTH-1 :0]  eo_offset_r;
    reg   [WO_VECT_WIDTH-1 :0]  wo_offset_r;

    assign eo_offset  = eo_offset_r; // [EO_VECT_WIDTH-1:0];
    assign wo_offset  = wo_offset_r;// [WO_VECT_WIDTH-1:0];

    assign chopp_period = chopp_period_r;
    //assign i2C_reg1 = 32'h00; //{dev_full_rst_control, 7'h00, 8'h00, i2C_reg1_r[15:0]};
    assign channel_mask = channel_mask_r;

    
 //#### SHAPI STANDARD DEVICE  ######//
    //#### STANDARD DEVICE REGISTERS ######//
    reg  [C_S_AXI_DATA_WIDTH-1:0] dev_interrupt_mask_r;   // pcie_regs_r[12];          //offset_addr 0x30
    wire [C_S_AXI_DATA_WIDTH-1:0] dev_interrupt_flag = dev_interrupt_mask_r;       //offset_addr 0x34
    reg  [C_S_AXI_DATA_WIDTH-1:0] dev_interrupt_active_r; // = 32'h0;                    //offset_addr 0x38
    reg  [C_S_AXI_DATA_WIDTH-1 :0] dev_scratch_reg  ;//      = 32'h0;          //offset_addr 0x3c

    reg  [C_S_AXI_DATA_WIDTH-1:0] dev_control_r        = 32'h00;  //offset_addr 0x2c
    wire  dev_endian_control   = dev_control_r[`DEV_CNTRL_ENDIAN_BIT]; //control_r[`ENDIAN_DMA_BIT]; // IMPC should generate TE0741 RESIN pin low
    wire  dev_soft_rst_control = dev_control_r[`DEV_CNTRL_SFT_RST_BIT];

    wire        dev_endian_status = dev_endian_control; //control_r[`ENDIAN_DMA_BIT];  //offset_addr 0x28 '0' - little-endian format.
    wire        dev_rtm_status = 1'b0;           //offset_addr 0x28 TODO: implement in IPMC
    wire        dev_soft_rst_status = dev_soft_rst_control;      //offset_addr 0x28
    wire        dev_full_rst_status = dev_control_r[`DEV_CNTRL_FULL_RST_BIT]; //dev_full_rst_control; //1'b0;      //offset_addr 0x28

    //#### MODULE REGISTERS ######//
    wire [63:0] mod_name = `MOD_ACQ_NAME; // Two words

    reg [C_S_AXI_DATA_WIDTH-1:30]  mod_control_r = 2'h0;      // Not used
    wire   mod_soft_rst_control = mod_control_r[`MOD_CNTRL_SFT_RST_BIT];       //offset_addr 0x2c
    wire   mod_full_rst_control = mod_control_r[`MOD_CNTRL_FULL_RST_BIT];       //offset_addr 0x2c

    reg [C_S_AXI_DATA_WIDTH-1:0]  mod_interrupt_flag_clear_r  = 32'h0;
    localparam        MOD_SOFT_RST_STATUS = 1'b0;                       //offset_addr 0x28
    localparam        MOD_FULL_RST_STATUS = 1'b0;                       //offset_addr 0x28

    reg [C_S_AXI_DATA_WIDTH-1:0]  mod_interrupt_mask_r  = 32'h0;
    localparam  MOD_INTERRUPT_FLAG   = 32'h0;                           //offset_addr 0x34
    localparam  MOD_INTERRUPT_ACTIVE = 32'h0;                           //offset_addr 0x38

    assign dev_hard_reset = dev_control_r[`DEV_CNTRL_FULL_RST_BIT]; 

    assign control_reg = {7'h00, control_r[24:13], dev_endian_control, control_r[11:10], 4'b0000,  control_r[5:0]};

    /*********************/
    // AXI4 Master LITE signals
    reg [(C_S_AXI_ADDR_WIDTH-1): 0]  axi_awaddr;
    reg     axi_awready;
    reg     axi_wready;
    reg [1 : 0]     axi_bresp;
    reg     axi_bvalid;
    reg [(C_S_AXI_ADDR_WIDTH-1): 0]  axi_araddr;
    reg     axi_arready;
    reg [(C_S_AXI_DATA_WIDTH-1): 0]  axi_rdata;
    reg [1 : 0]     axi_rresp;
    reg     axi_rvalid;

    // Example-specific design signals
    // local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
    // ADDR_LSB is used for addressing 32/64 bit registers/memories
    // ADDR_LSB = 2 for 32 bits (n downto 2)
    // ADDR_LSB = 3 for 64 bits (n downto 3)
    localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
    localparam integer OPT_MEM_ADDR_BITS = 7;
    //----------------------------------------------
    //-- Signals for user logic register space example
    //------------------------------------------------
    //-- Number of Slave Registers 256

//  reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg127;

    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg255;
    wire     slv_reg_rden;
    wire     slv_reg_wren;
    reg [C_S_AXI_DATA_WIDTH-1:0]     reg_data_out;
    integer  byte_index;
    reg  aw_en;

    // I/O Connections assignments

    assign S_AXI_AWREADY    = axi_awready;
    assign S_AXI_WREADY = axi_wready;
    assign S_AXI_BRESP  = axi_bresp;
    assign S_AXI_BVALID = axi_bvalid;
    assign S_AXI_ARREADY    = axi_arready;
    assign S_AXI_RDATA  = axi_rdata;
    assign S_AXI_RRESP  = axi_rresp;
    assign S_AXI_RVALID = axi_rvalid;

// Implement axi_awready generation
    // axi_awready is asserted for one S_AXI_ACLK clock cycle when both
    // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
    // de-asserted when reset is low.

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_awready <= 1'b0;
          aw_en <= 1'b1;
        end
      else
        begin
          if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
            begin
              // slave is ready to accept write address when
              // there is a valid write address and write data
              // on the write address and data bus. This design
              // expects no outstanding transactions.
              axi_awready <= 1'b1;
              aw_en <= 1'b0;
            end
            else if (S_AXI_BREADY && axi_bvalid)
                begin
                  aw_en <= 1'b1;
                  axi_awready <= 1'b0;
                end
          else
            begin
              axi_awready <= 1'b0;
            end
        end
    end

    // Implement axi_awaddr latching
    // This process is used to latch the address when both
    // S_AXI_AWVALID and S_AXI_WVALID are valid.

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_awaddr <= 0;
        end
      else
        begin
          if (~axi_awready && S_AXI_AWVALID && S_AXI_WVALID && aw_en)
            begin
              // Write Address latching
              axi_awaddr <= S_AXI_AWADDR;
            end
        end
    end

    // Implement axi_wready generation
    // axi_wready is asserted for one S_AXI_ACLK clock cycle when both
    // S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is
    // de-asserted when reset is low.

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_wready <= 1'b0;
        end
      else
        begin
          if (~axi_wready && S_AXI_WVALID && S_AXI_AWVALID && aw_en )
            begin
              // slave is ready to accept write data when
              // there is a valid write address and write data
              // on the write address and data bus. This design
              // expects no outstanding transactions.
              axi_wready <= 1'b1;
            end
          else
            begin
              axi_wready <= 1'b0;
            end
        end
    end

    // Implement memory mapped register select and write logic generation
    // The write data is accepted and written to memory mapped registers when
    // axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
    // select byte enables of slave registers while writing.
    // These registers are cleared when reset (active low) is applied.
    // Slave register write enable is asserted when valid address and data are available
    // and the slave is ready to accept the write address and write data.
    assign slv_reg_wren = axi_wready && S_AXI_WVALID && axi_awready && S_AXI_AWVALID;

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
            dev_scratch_reg <=  32'h0000BB;
            dev_control_r   <=  32'h00;
            control_r       <=  {19'h00, 6'd`HOLD_SAMPLES};
            channel_mask_r  <=  32'hFFFF_FFFF;
            eo_offset_r     <=   {EO_VECT_WIDTH{1'b0}};
            wo_offset_r     <=   {WO_VECT_WIDTH{1'b0}};

            chopp_period_r  <= #TCQ ((16'd2000 << 16) | (16'd1000 )); // 1kz chopp rate 50 % d.c.

          slv_reg255 <= 0;
        end
      else begin
        if (slv_reg_wren)
          begin
            case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
                8'h0B: begin
                    if(S_AXI_WDATA[`DEV_CNTRL_FULL_RST_BIT]) begin
                        //  Device Control, hard reset bit
                        dev_control_r[`DEV_CNTRL_FULL_RST_BIT]  <= 1'b1; //  Device Control, hard reset bit 
                        //i2C_reg1_r[`DEV_CNTRL_FULL_RST_BIT]     <= 1'b1;
                    end
                    else if(S_AXI_WDATA[`DEV_CNTRL_SFT_RST_BIT]) begin
                        //  Device Control, soft reset bit 
                        dev_scratch_reg <=  32'h00;
                        dev_control_r   <=  'h00; //  Device Control
                        control_r       <=  {19'h00, 6'd`HOLD_SAMPLES};
                        channel_mask_r  <=  32'hFFFF_FFFF;
                        eo_offset_r     <=  {EO_VECT_WIDTH{1'b0}};//
                        wo_offset_r     <=  {WO_VECT_WIDTH{1'b0}};
                    end
                    else
                        dev_control_r[`DEV_CNTRL_ENDIAN_BIT] <= S_AXI_WDATA[`DEV_CNTRL_ENDIAN_BIT]; //  Device Control,  bit 
                end
                8'h0F: dev_scratch_reg <= S_AXI_WDATA; // BAR 0 regs

                    (`MOD_ACQ_REG_OFF + 8'h0A): mod_interrupt_flag_clear_r  <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h0B): mod_interrupt_mask_r        <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h11): control_r[24:0]             <= S_AXI_WDATA[24:0];  // rw ADDR 0x84
                    (`MOD_ACQ_REG_OFF + 8'h12): chopp_period_r              <= S_AXI_WDATA;

                    (`MOD_ACQ_REG_OFF + 8'h15): channel_mask_r              <= S_AXI_WDATA;           //rw    ADDR 0x94
//            (`MOD_ACQ_REG_OFF + 8'h13): dma_prog_thresh_r     <= S_AXI_WDATA[23:5]; // DMA Byte Size
//
                    //(`MOD_ACQ_REG_OFF + 8'h1C):  i2C_reg1_r[7:0]      <= S_AXI_WDATA[7:0];      //rw  ADDR 0xB0

                    (`MOD_ACQ_REG_OFF + 8'h30): eo_offset_r[17:0]     <= S_AXI_WDATA[17:0];     //wo    ADDR 0x100
                    (`MOD_ACQ_REG_OFF + 8'h31): eo_offset_r[35:18]    <= S_AXI_WDATA[17:0];
                    (`MOD_ACQ_REG_OFF + 8'h32): eo_offset_r[53:36]    <= S_AXI_WDATA[17:0];
                    (`MOD_ACQ_REG_OFF + 8'h33): eo_offset_r[71:54]    <= S_AXI_WDATA[17:0];
                    (`MOD_ACQ_REG_OFF + 8'h34): eo_offset_r[89:72]    <= S_AXI_WDATA[17:0];
                    (`MOD_ACQ_REG_OFF + 8'h35): eo_offset_r[107:90]   <= S_AXI_WDATA[17:0];
                    (`MOD_ACQ_REG_OFF + 8'h36): eo_offset_r[125:108]  <= S_AXI_WDATA[17:0];
                    (`MOD_ACQ_REG_OFF + 8'h37): eo_offset_r[143:126]  <= S_AXI_WDATA[17:0];                    
                    (`MOD_ACQ_REG_OFF + 8'h38): eo_offset_r[161:144]  <= S_AXI_WDATA[17:0]; 
                    (`MOD_ACQ_REG_OFF + 8'h39): eo_offset_r[179:162]  <= S_AXI_WDATA[17:0];
                    (`MOD_ACQ_REG_OFF + 8'h3A): eo_offset_r[197:180]  <= S_AXI_WDATA[17:0];
                    (`MOD_ACQ_REG_OFF + 8'h3B): eo_offset_r[215:198]  <= S_AXI_WDATA[17:0];
                    (`MOD_ACQ_REG_OFF + 8'h3C): eo_offset_r[233:216]  <= S_AXI_WDATA[17:0];
                    (`MOD_ACQ_REG_OFF + 8'h3D): eo_offset_r[251:234]  <= S_AXI_WDATA[17:0];
                    (`MOD_ACQ_REG_OFF + 8'h3E): eo_offset_r[269:252]  <= S_AXI_WDATA[17:0];
                    (`MOD_ACQ_REG_OFF + 8'h3F): eo_offset_r[287:270]  <= S_AXI_WDATA[17:0];
                    
                    (`MOD_ACQ_REG_OFF + 8'h40): eo_offset_r[305:288]  <= S_AXI_WDATA[17:0];
                    (`MOD_ACQ_REG_OFF + 8'h41): eo_offset_r[323:306]  <= S_AXI_WDATA[17:0];
                    (`MOD_ACQ_REG_OFF + 8'h42): eo_offset_r[341:324]  <= S_AXI_WDATA[17:0];
                    (`MOD_ACQ_REG_OFF + 8'h43): eo_offset_r[359:342]  <= S_AXI_WDATA[17:0];
                    (`MOD_ACQ_REG_OFF + 8'h44): eo_offset_r[377:360]  <= S_AXI_WDATA[17:0];
                    (`MOD_ACQ_REG_OFF + 8'h45): eo_offset_r[395:378]  <= S_AXI_WDATA[17:0];
                    (`MOD_ACQ_REG_OFF + 8'h46): eo_offset_r[413:396]  <= S_AXI_WDATA[17:0];
                    (`MOD_ACQ_REG_OFF + 8'h47): eo_offset_r[431:414]  <= S_AXI_WDATA[17:0];
                    (`MOD_ACQ_REG_OFF + 8'h48): eo_offset_r[449:432]  <= S_AXI_WDATA[17:0];
                    (`MOD_ACQ_REG_OFF + 8'h49): eo_offset_r[467:450]  <= S_AXI_WDATA[17:0];
                    (`MOD_ACQ_REG_OFF + 8'h4A): eo_offset_r[485:468]  <= S_AXI_WDATA[17:0];
                    (`MOD_ACQ_REG_OFF + 8'h4B): eo_offset_r[503:486]  <= S_AXI_WDATA[17:0];
                    (`MOD_ACQ_REG_OFF + 8'h4C): eo_offset_r[521:504]  <= S_AXI_WDATA[17:0];
                    (`MOD_ACQ_REG_OFF + 8'h4D): eo_offset_r[539:522]  <= S_AXI_WDATA[17:0];
                    (`MOD_ACQ_REG_OFF + 8'h4E): eo_offset_r[557:540]  <= S_AXI_WDATA[17:0];
                    (`MOD_ACQ_REG_OFF + 8'h4F): eo_offset_r[575:558]  <= S_AXI_WDATA[17:0];
                    
                    (`MOD_ACQ_REG_OFF + 8'h50): wo_offset_r[31:0]     <= S_AXI_WDATA;   //rw    ADDR 0x180
                    (`MOD_ACQ_REG_OFF + 8'h51): wo_offset_r[63:32]    <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h52): wo_offset_r[95:64]    <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h53): wo_offset_r[127:96]   <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h54): wo_offset_r[159:128]  <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h55): wo_offset_r[191:160]  <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h56): wo_offset_r[223:192]  <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h57): wo_offset_r[255:224]  <= S_AXI_WDATA;

                    (`MOD_ACQ_REG_OFF + 8'h58): wo_offset_r[287:256]  <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h59): wo_offset_r[319:288]  <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h5A): wo_offset_r[351:320]  <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h5B): wo_offset_r[383:352]  <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h5C): wo_offset_r[415:384]  <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h5D): wo_offset_r[447:416]  <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h5E): wo_offset_r[479:448]  <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h5F): wo_offset_r[511:480]  <= S_AXI_WDATA;

                    (`MOD_ACQ_REG_OFF + 8'h60): wo_offset_r[543:512]  <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h61): wo_offset_r[575:544]  <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h62): wo_offset_r[607:576]  <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h63): wo_offset_r[639:608]  <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h64): wo_offset_r[671:640]  <= S_AXI_WDATA; 
                    (`MOD_ACQ_REG_OFF + 8'h65): wo_offset_r[703:672]  <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h66): wo_offset_r[735:704]  <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h67): wo_offset_r[767:736]  <= S_AXI_WDATA;

                    (`MOD_ACQ_REG_OFF + 8'h68): wo_offset_r[799:768]  <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h69): wo_offset_r[831:800]  <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h6A): wo_offset_r[863:832]  <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h6B): wo_offset_r[895:864]  <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h6C): wo_offset_r[927:896]  <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h6D): wo_offset_r[959:928]  <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h6E): wo_offset_r[991:960]  <= S_AXI_WDATA;
                    (`MOD_ACQ_REG_OFF + 8'h6F): wo_offset_r[1023:992]  <= S_AXI_WDATA;


/*
              8'h80:
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    // Slave register 128
                    slv_reg128[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end

                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    // Slave register 137
                    slv_reg137[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
              8'h8A:
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    // Slave register 138
                    slv_reg138[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end

                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    // Slave register 149
                    slv_reg149[(byte_index*8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
*/
              8'hFF:
                for ( byte_index = 0; byte_index <= (C_S_AXI_DATA_WIDTH/8)-1; byte_index = byte_index+1 )
                  if ( S_AXI_WSTRB[byte_index] == 1 ) begin
                    // Respective byte enables are asserted as per write strobes
                    // Slave register 255
                    slv_reg255[(byte_index * 8) +: 8] <= S_AXI_WDATA[(byte_index*8) +: 8];
                  end
              default : begin

                          slv_reg255 <= slv_reg255;
                        end
            endcase
          end
      end
    end

    // Implement write response logic generation
    // The write response and response valid signals are asserted by the slave
    // when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.
    // This marks the acceptance of address and indicates the status of
    // write transaction.

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_bvalid  <= 0;
          axi_bresp   <= 2'b0;
        end
      else
        begin
          if (axi_awready && S_AXI_AWVALID && ~axi_bvalid && axi_wready && S_AXI_WVALID)
            begin
              // indicates a valid write response is available
              axi_bvalid <= 1'b1;
              axi_bresp  <= 2'b0; // 'OKAY' response
            end                   // work error responses in future
          else
            begin
              if (S_AXI_BREADY && axi_bvalid)
                //check if bready is asserted while bvalid is high)
                //(there is a possibility that bready is always asserted high)
                begin
                  axi_bvalid <= 1'b0;
                end
            end
        end
    end

    // Implement axi_arready generation
    // axi_arready is asserted for one S_AXI_ACLK clock cycle when
    // S_AXI_ARVALID is asserted. axi_awready is
    // de-asserted when reset (active low) is asserted.
    // The read address is also latched when S_AXI_ARVALID is
    // asserted. axi_araddr is reset to zero on reset assertion.

    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_arready <= 1'b0;
          axi_araddr  <= 32'b0;
        end
      else
        begin
          if (~axi_arready && S_AXI_ARVALID)
            begin
              // indicates that the slave has acceped the valid read address
              axi_arready <= 1'b1;
              // Read address latching
              axi_araddr  <= S_AXI_ARADDR;
            end
          else
            begin
              axi_arready <= 1'b0;
            end
        end
    end

    // Implement axi_arvalid generation
    // axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both
    // S_AXI_ARVALID and axi_arready are asserted. The slave registers
    // data are available on the axi_rdata bus at this instance. The
    // assertion of axi_rvalid marks the validity of read data on the
    // bus and axi_rresp indicates the status of read transaction.axi_rvalid
    // is deasserted on reset (active low). axi_rresp and axi_rdata are
    // cleared to zero on reset (active low).
    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_rvalid <= 0;
          axi_rresp  <= 0;
        end
      else
        begin
          if (axi_arready && S_AXI_ARVALID && ~axi_rvalid)
            begin

              // Valid read data is available at the read data bus
              axi_rvalid <= 1'b1;
              axi_rresp  <= 2'b0; // 'OKAY' response
            end
          else if (axi_rvalid && S_AXI_RREADY)
            begin
              // Read data is accepted by the master
              axi_rvalid <= 1'b0;
            end
        end
    end

    // Implement memory mapped register select and read logic generation
    // Slave register read enable is asserted when valid address is available
    // and the slave is ready to accept the read address.
    assign slv_reg_rden = axi_arready & S_AXI_ARVALID & ~axi_rvalid;
    always @(*)
    begin
          // Address decoding for reading registers
          case ( axi_araddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
            // PCIe BAR 0 reg addresses
            8'h00 : reg_data_out = {`DEV_MAGIC,`DEV_MAJOR, `DEV_MINOR};
            8'h01 : reg_data_out = {`DEV_NEXT_ADDR};
            8'h02 : reg_data_out = {`DEV_HW_ID,`DEV_HW_VENDOR};
            8'h03 : reg_data_out = {`DEV_FW_ID,`DEV_FW_VENDOR};
            8'h04 : reg_data_out = {`DEV_FW_MAJOR,`DEV_FW_MINOR,`DEV_FW_PATCH};
            8'h05 : reg_data_out = {`DEV_TSTAMP};
            8'h06 : reg_data_out = {`DEV_NAME1};
            8'h07 : reg_data_out = {`DEV_NAME2};
            8'h08 : reg_data_out = {`DEV_NAME3};
            8'h09 : reg_data_out = {`DEV_FULL_RST_CAPAB,`DEV_SOFT_RST_CAPAB,28'h0,`DEV_RTM_CAPAB,`DEV_ENDIAN_CAPAB}; // ro
            8'h0A : reg_data_out = {dev_full_rst_status, dev_soft_rst_status,
                28'h00, dev_rtm_status, dev_endian_status};    //SHAPI status
            8'h0B : reg_data_out = dev_control_r;   //SHAPI dev control

            8'h0F : reg_data_out = dev_scratch_reg;

            (`MOD_ACQ_REG_OFF + 8'h00): reg_data_out = {`MOD_ACQ_MAGIC,`MOD_ACQ_MAJOR,`MOD_ACQ_MINOR}; // MOD_ACQ_REG_OFF = 8'h10
            (`MOD_ACQ_REG_OFF + 8'h01): reg_data_out = {`MOD_ACQ_NEXT_ADDR};
            (`MOD_ACQ_REG_OFF + 8'h02): reg_data_out = {`MOD_ACQ_FW_ID,`MOD_ACQ_FW_VENDOR};
            (`MOD_ACQ_REG_OFF + 8'h03): reg_data_out = {`MOD_ACQ_FW_MAJOR,`MOD_ACQ_FW_MINOR,`MOD_ACQ_FW_PATCH};
            (`MOD_ACQ_REG_OFF + 8'h04): reg_data_out = mod_name[31:0];
            (`MOD_ACQ_REG_OFF + 8'h05): reg_data_out = mod_name[63:32];
            (`MOD_ACQ_REG_OFF + 8'h06): reg_data_out = {`MOD_ACQ_FULL_RST_CAPAB,`MOD_ACQ_SOFT_RST_CAPAB,28'h0,`MOD_ACQ_RTM_CAPAB,`MOD_ACQ_MULTI_INT}; // Module Capabilities - ro

            (`MOD_ACQ_REG_OFF + 8'h07): reg_data_out = {MOD_FULL_RST_STATUS,  MOD_SOFT_RST_STATUS, 30'h0};  // Module Status - ro
            (`MOD_ACQ_REG_OFF + 8'h08): reg_data_out = {mod_full_rst_control, mod_soft_rst_control, 30'h0}; // Module Control rw
            (`MOD_ACQ_REG_OFF + 8'h09): reg_data_out = `MOD_ACQ_INTERRUPT_ID; // rw
            (`MOD_ACQ_REG_OFF + 8'h0A): reg_data_out =  mod_interrupt_flag_clear_r; // rw
            (`MOD_ACQ_REG_OFF + 8'h0B): reg_data_out =  mod_interrupt_mask_r; // rw
            (`MOD_ACQ_REG_OFF + 8'h0C): reg_data_out =  MOD_INTERRUPT_FLAG; // ro
            (`MOD_ACQ_REG_OFF + 8'h0D): reg_data_out =  MOD_INTERRUPT_ACTIVE; // ro
            // ....2
            (`MOD_ACQ_REG_OFF + 8'h10): reg_data_out = status_reg; // ro
            (`MOD_ACQ_REG_OFF + 8'h11): reg_data_out = {7'h00, control_r[24:0]}; // rw
            (`MOD_ACQ_REG_OFF + 8'h12): reg_data_out = chopp_period_r;       // rw
            (`MOD_ACQ_REG_OFF + 8'h13): reg_data_out = `MOD_ACQ_MAX_BYTES;   // ro
            (`MOD_ACQ_REG_OFF + 8'h14): reg_data_out = `MOD_ACQ_TLP_PAYLOAD; // ro
            (`MOD_ACQ_REG_OFF + 8'h15): reg_data_out = channel_mask_r;       // rw     ADDR 0x94

            (`MOD_ACQ_REG_OFF + 8'h16): reg_data_out = debug_0;              // r0     ADDR 0x98
            (`MOD_ACQ_REG_OFF + 8'h17): reg_data_out = debug_1;              // r0     ADDR 0x9C
            (`MOD_ACQ_REG_OFF + 8'h18): reg_data_out = debug_2;              // r0     ADDR 0xA0
            (`MOD_ACQ_REG_OFF + 8'h19): reg_data_out = debug_3;              // r0     ADDR 0xA4
                                    
            //(`MOD_ACQ_REG_OFF + 8'h1C): reg_data_out <= #TCQ i2C_reg1_r;  // rw     ADDR 0xB0
/*
            (`MOD_ACQ_REG_OFF + 8'h1D): reg_data_out <= #TCQ  //  Not implemented
            (`MOD_ACQ_REG_OFF + 8'h1E): reg_data_out <= #TCQ  //
            (`MOD_ACQ_REG_OFF + 8'h1F): reg_data_out <= #TCQ  //
            (`MOD_ACQ_REG_OFF + 8'h20): reg_data_out <= #TCQ  //

*/
 
            (`MOD_ACQ_REG_OFF + 8'h30): reg_data_out = adc18_extend_f(eo_offset_r[17:0]); // rw        ADDR 0x100
            (`MOD_ACQ_REG_OFF + 8'h31): reg_data_out = adc18_extend_f(eo_offset_r[35:18]); // rw
            (`MOD_ACQ_REG_OFF + 8'h32): reg_data_out = adc18_extend_f(eo_offset_r[53:36]); // rw
            (`MOD_ACQ_REG_OFF + 8'h33): reg_data_out = adc18_extend_f(eo_offset_r[71:54]); // rw
            (`MOD_ACQ_REG_OFF + 8'h34): reg_data_out = adc18_extend_f(eo_offset_r[89:72]); // rw
            (`MOD_ACQ_REG_OFF + 8'h35): reg_data_out = adc18_extend_f(eo_offset_r[107:90]); // rw
            (`MOD_ACQ_REG_OFF + 8'h36): reg_data_out = adc18_extend_f(eo_offset_r[125:108]); // rw
            (`MOD_ACQ_REG_OFF + 8'h37): reg_data_out = adc18_extend_f(eo_offset_r[143:126]); // rw
           
            (`MOD_ACQ_REG_OFF + 8'h38): reg_data_out = adc18_extend_f(eo_offset_r[161:144]); // rw //  Not implemented
            (`MOD_ACQ_REG_OFF + 8'h39): reg_data_out = adc18_extend_f(eo_offset_r[179:162]); // rw
            (`MOD_ACQ_REG_OFF + 8'h3A): reg_data_out = adc18_extend_f(eo_offset_r[197:180]); // rw
            (`MOD_ACQ_REG_OFF + 8'h3B): reg_data_out = adc18_extend_f(eo_offset_r[215:198]); // rw
            (`MOD_ACQ_REG_OFF + 8'h3C): reg_data_out = adc18_extend_f(eo_offset_r[233:216]); // rw
            (`MOD_ACQ_REG_OFF + 8'h3D): reg_data_out = adc18_extend_f(eo_offset_r[251:234]); // rw
            (`MOD_ACQ_REG_OFF + 8'h3E): reg_data_out = adc18_extend_f(eo_offset_r[269:252]); // rw
            (`MOD_ACQ_REG_OFF + 8'h3F): reg_data_out = adc18_extend_f(eo_offset_r[287:270]); // rw

            (`MOD_ACQ_REG_OFF + 8'h40): reg_data_out = adc18_extend_f(eo_offset_r[305:288]); // rw
            (`MOD_ACQ_REG_OFF + 8'h41): reg_data_out = adc18_extend_f(eo_offset_r[323:306]); // rw
            (`MOD_ACQ_REG_OFF + 8'h42): reg_data_out = adc18_extend_f(eo_offset_r[341:324]); // rw
            (`MOD_ACQ_REG_OFF + 8'h43): reg_data_out = adc18_extend_f(eo_offset_r[359:342]); // rw
            (`MOD_ACQ_REG_OFF + 8'h44): reg_data_out = adc18_extend_f(eo_offset_r[377:360]); // rw
            (`MOD_ACQ_REG_OFF + 8'h45): reg_data_out = adc18_extend_f(eo_offset_r[395:378]); // rw
            (`MOD_ACQ_REG_OFF + 8'h46): reg_data_out = adc18_extend_f(eo_offset_r[413:396]); // rw
            (`MOD_ACQ_REG_OFF + 8'h47): reg_data_out = adc18_extend_f(eo_offset_r[431:414]); // rw
            (`MOD_ACQ_REG_OFF + 8'h48): reg_data_out = adc18_extend_f(eo_offset_r[449:432]); // rw
            (`MOD_ACQ_REG_OFF + 8'h49): reg_data_out = adc18_extend_f(eo_offset_r[467:450]); // rw
            (`MOD_ACQ_REG_OFF + 8'h4A): reg_data_out = adc18_extend_f(eo_offset_r[485:468]); // rw
            (`MOD_ACQ_REG_OFF + 8'h4B): reg_data_out = adc18_extend_f(eo_offset_r[503:486]); // rw
            (`MOD_ACQ_REG_OFF + 8'h4C): reg_data_out = adc18_extend_f(eo_offset_r[521:504]); // rw
            (`MOD_ACQ_REG_OFF + 8'h4D): reg_data_out = adc18_extend_f(eo_offset_r[539:522]); // rw
            (`MOD_ACQ_REG_OFF + 8'h4E): reg_data_out = adc18_extend_f(eo_offset_r[557:540]); // rw
            (`MOD_ACQ_REG_OFF + 8'h4F): reg_data_out = adc18_extend_f(eo_offset_r[575:558]); // rw

            (`MOD_ACQ_REG_OFF + 8'h50): reg_data_out = wo_offset_r[31:0];     // rw  ADDR 0x180
            (`MOD_ACQ_REG_OFF + 8'h51): reg_data_out = wo_offset_r[63:32];
            (`MOD_ACQ_REG_OFF + 8'h52): reg_data_out = wo_offset_r[95:64];
            (`MOD_ACQ_REG_OFF + 8'h53): reg_data_out = wo_offset_r[127:96];
            (`MOD_ACQ_REG_OFF + 8'h54): reg_data_out = wo_offset_r[159:128];
            (`MOD_ACQ_REG_OFF + 8'h55): reg_data_out = wo_offset_r[191:160];
            (`MOD_ACQ_REG_OFF + 8'h56): reg_data_out = wo_offset_r[223:192];
            (`MOD_ACQ_REG_OFF + 8'h57): reg_data_out = wo_offset_r[255:224];
            (`MOD_ACQ_REG_OFF + 8'h58): reg_data_out = wo_offset_r[287:256];
            (`MOD_ACQ_REG_OFF + 8'h59): reg_data_out = wo_offset_r[319:288];
            (`MOD_ACQ_REG_OFF + 8'h5A): reg_data_out = wo_offset_r[351:320];
            (`MOD_ACQ_REG_OFF + 8'h5B): reg_data_out = wo_offset_r[383:352];
            (`MOD_ACQ_REG_OFF + 8'h5C): reg_data_out = wo_offset_r[415:384];
            (`MOD_ACQ_REG_OFF + 8'h5D): reg_data_out = wo_offset_r[447:416];
            (`MOD_ACQ_REG_OFF + 8'h5E): reg_data_out = wo_offset_r[479:448];
            (`MOD_ACQ_REG_OFF + 8'h5F): reg_data_out = wo_offset_r[511:480];
            (`MOD_ACQ_REG_OFF + 8'h60): reg_data_out = wo_offset_r[543:512];
            (`MOD_ACQ_REG_OFF + 8'h61): reg_data_out = wo_offset_r[575:544];
            (`MOD_ACQ_REG_OFF + 8'h62): reg_data_out = wo_offset_r[607:576];
            (`MOD_ACQ_REG_OFF + 8'h63): reg_data_out = wo_offset_r[639:608];
            (`MOD_ACQ_REG_OFF + 8'h64): reg_data_out = wo_offset_r[671:640];
            (`MOD_ACQ_REG_OFF + 8'h65): reg_data_out = wo_offset_r[703:672];
            (`MOD_ACQ_REG_OFF + 8'h66): reg_data_out = wo_offset_r[735:704];
            (`MOD_ACQ_REG_OFF + 8'h67): reg_data_out = wo_offset_r[767:736];
            (`MOD_ACQ_REG_OFF + 8'h68): reg_data_out = wo_offset_r[799:768];
            (`MOD_ACQ_REG_OFF + 8'h69): reg_data_out = wo_offset_r[831:800];
            (`MOD_ACQ_REG_OFF + 8'h6A): reg_data_out = wo_offset_r[863:832];
            (`MOD_ACQ_REG_OFF + 8'h6B): reg_data_out = wo_offset_r[895:864];
            (`MOD_ACQ_REG_OFF + 8'h6C): reg_data_out = wo_offset_r[927:896];
            (`MOD_ACQ_REG_OFF + 8'h6D): reg_data_out = wo_offset_r[959:928];
            (`MOD_ACQ_REG_OFF + 8'h6E): reg_data_out = wo_offset_r[991:960];
            (`MOD_ACQ_REG_OFF + 8'h6F): reg_data_out = wo_offset_r[1023:992];


/*
            8'h80   : reg_data_out <= slv_reg128;               // Dummy registers
            8'h95   : reg_data_out <= slv_reg149;
*/
            8'hFF   : reg_data_out = slv_reg255;
            default : reg_data_out = 'h00;
          endcase
    end

    // Output register or memory read data
    always @( posedge S_AXI_ACLK )
    begin
      if ( S_AXI_ARESETN == 1'b0 )
        begin
          axi_rdata  <= 0;
        end
      else
        begin
          // When there is a valid read address (S_AXI_ARVALID) with
          // acceptance of read address by the slave (axi_arready),
          // output the read dada
          if (slv_reg_rden)
            begin
              axi_rdata <= reg_data_out;     // register read data
            end
        end
    end

    endmodule  // shapi_regs.sv
