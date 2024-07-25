///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company: INSTITUTO DE PLASMAS E FUSAO NUCLEAR
// Engineer: BBC
//
// Create Date:   13:45:00 15/04/2016
// Project Name:
// Design Name:
// Module Name:    shapi_stdrt_dev_inc
// Target Devices:
// Tool versions:  Vivado 2022.1
//
// Description:
// Verilog Header
// SHAPI registers - standard device
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
`ifndef _shapi_stdrt_dev_inc_vh_
`define _shapi_stdrt_dev_inc_vh_

//####### SHAPI REGISTERS #############//

//#### STANDARD DEVICE REGISTERS ######//
`define DEV_MAGIC        16'h5348       // Current SHAPI standart
`define DEV_MAJOR        8'h01
`define DEV_MINOR        8'h00
`define DEV_NEXT_ADDR    32'h0000_0040  //offset_addr 0x04
`define DEV_HW_VENDOR    16'h10EE       //offset_addr 0x08 Xilinx Vendor
`define DEV_HW_ID        16'h0030
`define DEV_FW_VENDOR    16'h1570       //offset_addr 0x0c
`define DEV_FW_ID        16'h0032
/**
* Similar to the SHAPI version, the firmware version fields identify downward 
* compatibility between software and firmware. An increase in a version field 
* reflects the following:
    * Major Value: software compatibility is no longer assured;
    * Minor Value: changes in the firmware and device level registers which 
    *   do not interfere with available software;
    * Patch Value: internal firmware changes with no effect to external interfaces.
   *
* */
`define DEV_FW_PATCH     16'h0001       //offset_addr 0x10
`define DEV_FW_MINOR     8'h00
`define DEV_FW_MAJOR     8'h00

// Use Linux command: date +%s to get UNIX timestamp
`define DEV_TSTAMP      32'd1711623190
//TS Thu Mar 28 10:43:10 AM WET 2024

`define DEV_NAME1         "actA" // first char right
`define DEV_NAME2         "omiM"
`define DEV_NAME3         "s26K"
`define DEV_ENDIAN_CAPAB   1'b1      //offset_addr 0x24
`define DEV_RTM_CAPAB      1'b0     // TODO: Implement on IPMC
`define DEV_SOFT_RST_CAPAB 1'b1
`define DEV_FULL_RST_CAPAB 1'b1

`define DEV_CNTRL_FULL_RST_BIT 31
`define DEV_CNTRL_SFT_RST_BIT  30
`define DEV_CNTRL_ENDIAN_BIT   0

`define MOD_ACQ_REG_OFF    8'h10         // Base address of Module Device

//#### MODULE ACQUISITION MODULE REGISTERS ######//
`define MOD_ACQ_MAGIC      16'h534D       //offset_addr dev_mod1_addr
`define MOD_ACQ_MAJOR      8'h01
`define MOD_ACQ_MINOR      8'h00
`define MOD_ACQ_NEXT_ADDR  32'h00         //offset_addr dev_mod1_addr+0x04
`define MOD_ACQ_FW_VENDOR  16'h1570       //offset_addr dev_mod1_addr+0x08
`define MOD_ACQ_FW_ID      16'h0076
`define MOD_ACQ_FW_PATCH   16'h0000       //offset_addr dev_mod1_addr+0x0c
`define MOD_ACQ_FW_MINOR   8'h02
`define MOD_ACQ_FW_MAJOR   8'h02

`define MOD_ACQ_NAME       "kAdoMamD" // 64'h44_6D_61_4D_6F_64_41_6B //  DmaModAk

`define MOD_ACQ_MULTI_INT      1'b0               //module capabilities
`define MOD_ACQ_RTM_CAPAB      1'b0
`define MOD_ACQ_SOFT_RST_CAPAB 1'b0
`define MOD_ACQ_FULL_RST_CAPAB 1'b0
`define MOD_ACQ_INTERRUPT_ID   32'h00000000

`define MOD_ACQ_MAX_BYTES       32'h00400000    // 4MB DMA packets (Maybe more?)
//working with xdma driver
//`define MOD_ACQ_MAX_BYTES       32'h003FF000  //  Max allowed by Linux Driver

`define MOD_ACQ_TLP_PAYLOAD     32'h00000020  // 32 DW 128 Bytes. Depends or PCIe HW

`define MOD_CNTRL_FULL_RST_BIT 31
`define MOD_CNTRL_SFT_RST_BIT  30

`endif // _shapi_stdrt_dev_inc_vh_
