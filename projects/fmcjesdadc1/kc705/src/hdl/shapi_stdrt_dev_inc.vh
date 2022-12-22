///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// vim: sta:et:sw=4:ts=4:sts=4
// Company: INSTITUTO DE PLASMAS E FUSAO NUCLEAR/IST
// Engineer: Bernardo Carvalho
//
// Create Date:   13:45:00 15/04/2016
// Project Name:
// Design Name:
// Module Name:    shapi_stdrt_dev_inc
// Target Devices:
// Tool versions:  Vivado 2019.1
//
// Description:
//      Verilog Header
//      SHAPI registers - standard device definitions
//
//
// Copyright 2015 - 2022 IPFN-Instituto Superior Tecnico, Portugal
// Creation Date  2017-11-09
//
// Licensed under the EUPL, Version 1.2 or - as soon they
// will be approved by the European Commission 
//subsequent versions of the EUPL (the "Licence");
// You may not use this work except in compliance with the
// Licence.
// You may obtain a copy of the Licence at:
//
// https://joinup.ec.europa.eu/software/page/eupl
// Unless required by applicable law or agreed to in
// writing, software distributed under the Licence is
// distributed on an "AS IS" basis,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied.
// See the Licence for the specific language governing
// permissions and limitations under the Licence.

`ifndef _shapi_stdrt_dev_inc_vh_
    `define _shapi_stdrt_dev_inc_vh_

    //####### SHAPI REGISTERS #############//

    //#### STANDARD DEVICE REGISTERS ######//
    `define DEV_MAGIC        16'h5348       //offset_addr 0x00
    `define DEV_MAJOR           8'h01
    `define DEV_MINOR           8'h00
    `define DEV_NEXT_ADDR    32'h0000_0040  //offset_addr 0x04
    `define DEV_HW_VENDOR    16'h10EE       //offset_addr 0x08 Xilinx Vendor
    `define DEV_HW_ID        16'h7018
    `define DEV_FW_VENDOR    16'h1570       //offset_addr 0x0c
    `define DEV_FW_ID        16'h0032

    `define DEV_FW_PATCH     16'h0003       //offset_addr 0x10
    `define DEV_FW_MINOR        8'h01
    `define DEV_FW_MAJOR        8'h01

    // Use Linux command: date +%s; date  to get UNIX timestamp
    `define DEV_TSTAMP      32'd1671719731
    //TS Thu 22 Dec 2022 02:35:31 PM WET

    `define DEV_NAME1         "1cdA" // first char right
    `define DEV_NAME2         "girT"
    `define DEV_NAME3         "htsE"
    `define DEV_ENDIAN_CAPAB   1'b0   //offset_addr 0x24
    `define DEV_RTM_CAPAB      1'b0
    `define DEV_SOFT_RST_CAPAB 1'b1
    `define DEV_FULL_RST_CAPAB 1'b0

    `define DEV_CNTRL_FULL_RST_BIT 31
    `define DEV_CNTRL_SFT_RST_BIT  30
    `define DEV_CNTRL_ENDIAN_BIT   0

    `define MOD_TRIG_REG_OFF    6'h10         // Base address of Module Device 16

    //#### MODULE TRIGGER DMA MODULE REGISTERS ######//
    `define MOD_TRIG_MAGIC      16'h534D       //offset_addr dev_mod1_addr
    `define MOD_TRIG_MAJOR      8'h01
    `define MOD_TRIG_MINOR      8'h00
    `define MOD_TRIG_NEXT_ADDR  32'h00         //offset_addr dev_mod1_addr+0x04
    `define MOD_TRIG_FW_VENDOR  16'h1570       //offset_addr dev_mod1_addr+0x08
    `define MOD_TRIG_FW_ID      16'h0076
    `define MOD_TRIG_FW_PATCH   16'h0001       //offset_addr dev_mod1_addr+0x0c
    `define MOD_TRIG_FW_MINOR   8'h00
    `define MOD_TRIG_FW_MAJOR   8'h01
    `define MOD_TRIG_NAME       "kAdoM1aB" // 64'h44_6D_61_4D_6F_64_41_6B //  DmaModAk

    `define MOD_TRIG_MULTI_INT      1'b0               //module capabilities
    `define MOD_TRIG_RTM_CAPAB      1'b0
    `define MOD_TRIG_SOFT_RST_CAPAB 1'b0
    `define MOD_TRIG_FULL_RST_CAPAB 1'b0
    `define MOD_TRIG_INTERRUPT_ID   32'h00000000

    //`define MOD_TRIG_MAX_BYTES       32'h00200000  // 2MB DMA packets
    `define MOD_TRIG_MAX_BYTES       32'h00800000  // 8MB DMA packets, maybe higher

    `define MOD_TRIG_TLP_PAYLOAD     32'h00000020  // 32 DW 128 Bytes. Depends or PCIe HW

    `define MOD_CNTRL_FULL_RST_BIT 31
    `define MOD_CNTRL_SFT_RST_BIT  30

    /*  #### CONTROL  REG BITS definitions ###### */
    //`define FWUSTAR_BIT 19
    `define STREAME_BIT     20 // Streaming enable
    `define ACQE_BIT 		 23
    `define STRG_BIT 		 24 // Soft Trigger

`endif // _shapi_stdrt_dev_inc_vh_
