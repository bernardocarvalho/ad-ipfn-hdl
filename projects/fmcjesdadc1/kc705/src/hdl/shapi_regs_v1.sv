//////////////////////////////////////////////////////////////////////////////////
// vim: sta:et:sw=4:ts=4:sts=4
// Company: INSTITUTO DE PLASMAS E FUSAO NUCLEAR/IST
// Engineer: Bernardo Carvalho
//
// Create Date: 05/08/2021 07:21:01 PM
// Design Name: esther_trigger
// Module Name: shapi_regs_v1
// Project Name: Esther Trigger System
// Target Devices: kintex-7
// Tool Versions:  Vivado 2019.2
// Description: BAR0 register accordind to SHAPI Standard
//
// Dependencies: shapi_stdrt_dev_inc.vh
//
// Revision 0.01 - File Created
// Additional Comments:
// Copyright 2015 - 2023 IPFN-Instituto Superior Tecnico, Portugal
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
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns / 1 ps
`include "shapi_stdrt_dev_inc.vh"
module shapi_regs_v1 #
    (
        // Users to add parameters here

        // User parameters ends
        // Do not modify the parameters beyond this line

        // Width of S_AXI data bus
        parameter integer C_S_AXI_DATA_WIDTH    = 32,
        // Width of S_AXI address bus
        parameter integer C_S_AXI_ADDR_WIDTH    = 8,
        parameter TCQ        = 1
    )
    (
        // Users to add ports here

        // User ports ends
        // Do not modify the ports beyond this line

        // Global Clock Signal
        input wire  S_AXI_ACLK,
        // Global Reset Signal. This Signal is Active LOW
        input wire  S_AXI_ARESETN,
        // Write address (issued by master, acceped by Slave)
        input wire [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
        // Write channel Protection type. This signal indicates the
        // privilege and security level of the transaction, and whether
        // the transaction is a data access or an instruction access.
        // input wire [2 : 0] S_AXI_AWPROT,
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
        // Protection type. This signal indicates the privilege
        // and security level of the transaction, and whether the
        // transaction is a data access or an instruction access.
        // input wire [2 : 0] S_AXI_ARPROT,
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
        output      [31:0]  trig_0,
        output      [31:0]  trig_1,
        output      [31:0]  trig_2,
        output      [31:0]  param_mul,
        output      [31:0]  param_off,
        output      [31:0]  init_delay,

        input       [31:0]  pulse_tof,

        input       [31:0]  status_reg,
        output      [31:0]  control_reg

    );

    /********IPFN regr ***********/

    reg   [31:0]     control_r = 32'h00;
    reg   [31:0]     trig0_r, trig1_r, trig2_r;
    reg   [31:0]     param_mul_r =32'h0001_0000, param_off_r = 32'h0001_0000;
    reg   [31:0]     param_init_delay_r = 32'd25_000_000; // (* 8ns) Initial Idle Time  = 0.2 s Max 4294967294/34 s    
    assign trig_0 = trig0_r;
    assign trig_1 = trig1_r;
    assign trig_2 = trig2_r;
    assign param_mul = param_mul_r;
    assign param_off = param_off_r;
    assign init_delay = param_init_delay_r;

    assign control_reg = control_r;

    //#### STANDARD DEVICE  ######//
    wire        dev_endian_status = control_r[10];  // 1'b0;        //offset_addr 0x28 '0' - little-endian format.
    wire        dev_rtm_status = 1'b0;           //offset_addr 0x28
    wire        dev_soft_rst_status = 1'b0;      //offset_addr 0x28
    wire        dev_full_rst_status = 1'b0;      //offset_addr 0x28

    //#### STANDARD DEVICE REGISTERS ######//
    reg  [31:0] dev_interrupt_mask_r ;   // pcie_regs_r[12];          //offset_addr 0x30
    wire [31:0] dev_interrupt_flag    = dev_interrupt_mask_r;       //offset_addr 0x34
    reg  [31:0] dev_interrupt_active_r; // = 32'h0;                    //offset_addr 0x38
    reg  [31:0] dev_scratch_reg  ;//      = 32'h0;          //offset_addr 0x3c

    reg  [31:1] dev_control_r        = 31'h0;  //offset_addr 0x2c
    wire  dev_endian_control   = control_r[10]; // dev_control_r[`DEV_CNTRL_ENDIAN_BIT];
    wire  dev_soft_rst_control = dev_control_r[`DEV_CNTRL_SFT_RST_BIT];
    wire  dev_full_rst_control = dev_control_r[`DEV_CNTRL_FULL_RST_BIT];


    //#### MODULE REGISTERS ######//
    wire [63:0] mod_name = `MOD_TRIG_NAME; // Two words

    reg [31:30]  mod_control_r = 2'h0;
    wire   mod_soft_rst_control = mod_control_r[`MOD_CNTRL_SFT_RST_BIT];       //offset_addr 0x2c
    wire   mod_full_rst_control = mod_control_r[`MOD_CNTRL_FULL_RST_BIT];       //offset_addr 0x2c

    reg [31:0]  mod_interrupt_flag_clear_r  = 32'h0;
    localparam        MOD_SOFT_RST_STATUS = 1'b0;                       //offset_addr 0x28
    localparam        MOD_FULL_RST_STATUS = 1'b0;                       //offset_addr 0x28

    reg [31:0]  mod_interrupt_mask_r  = 32'h0;
    localparam  MOD_INTERRUPT_FLAG   = 32'h0; //mod1_interrupt_mask;                //offset_addr 0x34
    localparam  MOD_INTERRUPT_ACTIVE = 32'h0;     //offset_addr 0x38


    /*********************/
    // AXI4LITE signals
    reg [C_S_AXI_ADDR_WIDTH-1 : 0]  axi_awaddr;
    reg     axi_awready;
    reg     axi_wready;
    reg [1 : 0]     axi_bresp;
    reg     axi_bvalid;
    reg [C_S_AXI_ADDR_WIDTH-1 : 0]  axi_araddr;
    reg     axi_arready;
    reg [C_S_AXI_DATA_WIDTH-1 : 0]  axi_rdata;
    reg [1 : 0]     axi_rresp;
    reg     axi_rvalid;

    // Example-specific design signals
    // local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
    // ADDR_LSB is used for addressing 32/64 bit registers/memories
    // ADDR_LSB = 2 for 32 bits (n downto 2)
    // ADDR_LSB = 3 for 64 bits (n downto 3)
    localparam integer ADDR_LSB = (C_S_AXI_DATA_WIDTH/32) + 1;
    localparam integer OPT_MEM_ADDR_BITS = 5;
    //----------------------------------------------
    //-- Signals for user logic register space example
    //------------------------------------------------
    //-- Number of Slave Registers 64
    //reg [C_S_AXI_DATA_WIDTH-1:0]  slv_reg15;
    //reg [C_S_AXI_DATA_WIDTH-1:0]  slv_reg89;
    //  reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg127;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg50;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg51;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg52;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg53;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg54;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg55;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg56;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg57;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg58;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg59;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg60;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg61;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg62;
    reg [C_S_AXI_DATA_WIDTH-1:0]    slv_reg63;
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
            dev_scratch_reg <=  32'h00BB;
            dev_control_r   <=  31'h0000;
            control_r       <=  32'h0000;
            trig0_r         <=  32'h0400_8000; // +1024 / -16385
            trig1_r         <=  32'h0400_8000; // +1024 / -16385
            trig2_r         <=  32'h0400_8000;
            param_mul_r     <=  32'h0001_0000;
            param_off_r         <= 32'h0001_0000;
            param_init_delay_r  <= 32'd25_000_000; // (* 8ns) Initial Idle Time  = 0.2 s Max 4294967294/34 s    

            slv_reg50 <= 'h00;
            slv_reg51 <= 'h00;
            slv_reg52 <= 'h00;
            slv_reg53 <= 0;
            slv_reg54 <= 0;
            slv_reg55 <= 0;
        end
        else begin
            if (slv_reg_wren)
            begin
                case ( axi_awaddr[ADDR_LSB+OPT_MEM_ADDR_BITS:ADDR_LSB] )
                    6'h0F: dev_scratch_reg <= S_AXI_WDATA; // BAR 0 regsmod_interrupt_mask

                    (`MOD_TRIG_REG_OFF + 6'h08): mod_control_r  <= S_AXI_WDATA[31:30];
                    (`MOD_TRIG_REG_OFF + 6'h0A): mod_interrupt_flag_clear_r  <= S_AXI_WDATA;
                    (`MOD_TRIG_REG_OFF + 6'h0B): mod_interrupt_mask_r        <= S_AXI_WDATA;
                    //(`MOD_TRIG_REG_OFF + 6'h09):
                    //(`MOD_TRIG_REG_OFF + 6'h10): slv_reg32             <= S_AXI_WDATA;
                    (`MOD_TRIG_REG_OFF + 6'h11): control_r             <= S_AXI_WDATA;
                    (`MOD_TRIG_REG_OFF + 6'h12): trig0_r               <= S_AXI_WDATA;
                    (`MOD_TRIG_REG_OFF + 6'h13): trig1_r               <= S_AXI_WDATA;
                    (`MOD_TRIG_REG_OFF + 6'h14): trig2_r               <= S_AXI_WDATA;
                    (`MOD_TRIG_REG_OFF + 6'h15): param_mul_r              <= S_AXI_WDATA;
                    (`MOD_TRIG_REG_OFF + 6'h16): param_off_r              <= S_AXI_WDATA;
                    (`MOD_TRIG_REG_OFF + 6'h17): param_init_delay_r    <= S_AXI_WDATA;

                    /*
                    //(`MOD_TRIG_REG_OFF + 6'h17): slv_reg39             <= S_AXI_WDATA;

                    (`MOD_TRIG_REG_OFF + 6'h1C): slv_reg44             <= S_AXI_WDATA;
                    */

                    default : begin
                        slv_reg50 <= slv_reg50;
                        slv_reg51 <= slv_reg51;
                        slv_reg52 <= slv_reg52;
                        slv_reg53 <= slv_reg53;
                        slv_reg54 <= slv_reg54;
                        slv_reg55 <= slv_reg55;
                        slv_reg56 <= slv_reg56;
                        slv_reg57 <= slv_reg57;
                        slv_reg58 <= slv_reg58;
                        slv_reg59 <= slv_reg59;
                        slv_reg60 <= slv_reg60;
                        slv_reg61 <= slv_reg61;
                        slv_reg62 <= slv_reg62;
                        slv_reg63 <= slv_reg63;
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
            //BAR 1 addresses125000000
            6'h00 : reg_data_out = {`DEV_MAGIC,`DEV_MAJOR, `DEV_MINOR}; // BAR1 access
            6'h01 : reg_data_out = {`DEV_NEXT_ADDR};
            6'h02 : reg_data_out = {`DEV_HW_ID,`DEV_HW_VENDOR};
            6'h03 : reg_data_out = {`DEV_FW_ID,`DEV_FW_VENDOR};
            6'h04 : reg_data_out = {`DEV_FW_MAJOR,`DEV_FW_MINOR,`DEV_FW_PATCH};
            6'h05 : reg_data_out = {`DEV_TSTAMP};
            6'h06 : reg_data_out = {`DEV_NAME1};
            6'h07 : reg_data_out = {`DEV_NAME2};
            6'h08 : reg_data_out = {`DEV_NAME3};
            6'h09 : reg_data_out = {`DEV_FULL_RST_CAPAB,`DEV_SOFT_RST_CAPAB,26'h0,`DEV_RTM_CAPAB,`DEV_ENDIAN_CAPAB}; // ro
            6'h0A : reg_data_out = {dev_full_rst_status,dev_soft_rst_status,28'h0,dev_rtm_status,dev_endian_status};    //SHAPI status
            6'h0B : reg_data_out = {dev_full_rst_control,dev_soft_rst_control,29'h0,dev_endian_control};                //SHAPI dev control

            6'h0F : reg_data_out = dev_scratch_reg;

            (`MOD_TRIG_REG_OFF + 6'h00): reg_data_out <= #TCQ {`MOD_TRIG_MAGIC,`MOD_TRIG_MAJOR,`MOD_TRIG_MINOR};
            (`MOD_TRIG_REG_OFF + 6'h01): reg_data_out <= #TCQ {`MOD_TRIG_NEXT_ADDR};
            (`MOD_TRIG_REG_OFF + 6'h02): reg_data_out <= #TCQ {`MOD_TRIG_FW_ID,`MOD_TRIG_FW_VENDOR};
            (`MOD_TRIG_REG_OFF + 6'h03): reg_data_out <= #TCQ {`MOD_TRIG_FW_MAJOR,`MOD_TRIG_FW_MINOR,`MOD_TRIG_FW_PATCH};
            (`MOD_TRIG_REG_OFF + 6'h04): reg_data_out <= #TCQ mod_name[31:0];
            (`MOD_TRIG_REG_OFF + 6'h05): reg_data_out <= #TCQ mod_name[63:32];
            (`MOD_TRIG_REG_OFF + 6'h06): reg_data_out <= #TCQ {`MOD_TRIG_FULL_RST_CAPAB,`MOD_TRIG_SOFT_RST_CAPAB,26'h0,`MOD_TRIG_RTM_CAPAB,`MOD_TRIG_MULTI_INT}; // Module Capabilities - ro

            (`MOD_TRIG_REG_OFF + 6'h07): reg_data_out <= #TCQ {MOD_FULL_RST_STATUS,  MOD_SOFT_RST_STATUS, 30'h0};  // Module Status - ro
            (`MOD_TRIG_REG_OFF + 6'h08): reg_data_out <= #TCQ {mod_full_rst_control, mod_soft_rst_control, 30'h0}; // Module Control rw
            (`MOD_TRIG_REG_OFF + 6'h09): reg_data_out <= #TCQ `MOD_TRIG_INTERRUPT_ID; // rw
            (`MOD_TRIG_REG_OFF + 6'h0A): reg_data_out <= #TCQ  mod_interrupt_flag_clear_r; // rw
            (`MOD_TRIG_REG_OFF + 6'h0B): reg_data_out <= #TCQ  mod_interrupt_mask_r; // rw
            (`MOD_TRIG_REG_OFF + 6'h0C): reg_data_out <= #TCQ  MOD_INTERRUPT_FLAG; // ro
            (`MOD_TRIG_REG_OFF + 6'h0D): reg_data_out <= #TCQ  MOD_INTERRUPT_ACTIVE; // ro
            // ....2
            (`MOD_TRIG_REG_OFF + 6'h10): reg_data_out <= #TCQ status_reg; // ro
            (`MOD_TRIG_REG_OFF + 6'h11): reg_data_out <= #TCQ control_r; // rw
            (`MOD_TRIG_REG_OFF + 6'h12): reg_data_out <= #TCQ trig0_r; // rw
            (`MOD_TRIG_REG_OFF + 6'h13): reg_data_out <= #TCQ trig1_r; // rw
            (`MOD_TRIG_REG_OFF + 6'h14): reg_data_out <= #TCQ trig2_r; // rw
            (`MOD_TRIG_REG_OFF + 6'h15): reg_data_out <= #TCQ param_mul_r; // rw param_mul 
            (`MOD_TRIG_REG_OFF + 6'h16): reg_data_out <= #TCQ param_off_r; // rw  param_off
            (`MOD_TRIG_REG_OFF + 6'h17): reg_data_out <= #TCQ param_init_delay_r; // rw

            (`MOD_TRIG_REG_OFF + 6'h20): reg_data_out <= #TCQ pulse_tof; // ro
            (`MOD_TRIG_REG_OFF + 6'h21): reg_data_out <= #TCQ 32'hA5A5; //pulse_tof; // ro

            /**
                (`MOD_TRIG_REG_OFF + 6'h12): reg_data_out <= #TCQ chopp_period_r;// rw
                //            (`MOD_TRIG_REG_OFF + 6'h12): reg_data_out <= #TCQ {8'b0, dma_size_r}; // rw
                (`MOD_TRIG_REG_OFF + 6'h13): reg_data_out <= #TCQ {`MOD_TRIG_MAX_BYTES} ; // ro
                (`MOD_TRIG_REG_OFF + 6'h14): reg_data_out <= #TCQ {`MOD_TRIG_TLP_PAYLOAD}; // ro

                */
                default : reg_data_out <= 0;
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

endmodule
