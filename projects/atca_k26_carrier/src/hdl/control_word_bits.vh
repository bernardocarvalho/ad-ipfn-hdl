///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company: INSTITUTO DE PLASMAS E FUSAO NUCLEAR
// Engineer: BBC
//
// Create Date:   13:45:00
// 15/04/2017
// Project Name:
// Design Name:
// Module Name:  Bit position on Control Reg
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
`ifndef _control_word_bits_vh_
`define _control_word_bits_vh_

/* ************ CONTROL  REG BITS definitions **************** */
`define ENDIAN_DMA_BIT          0 //Endianness of DMA data words  (0:little , 1: Big Endian)
/* Only bits 10-24 are used in control reg*/
`define CHOP_ON_BIT             10 // State of Chop, if equals 1 chop is ON if 0 it is OFF
`define CHOP_DEFAULT_BIT        11 // Value of Chop case CHOP_STATE is 0
`define CHOP_RECONSTRUCT_BIT    12 // State of Chop Recontruction, if equals 1 chop is ON if 0 it is OFF
`define ILCK_F_OUT_EN_BIT       13 //
`define ILCK_QF_OUT_EN_BIT      14 //
//`define INT_CALC            = 14; // Output Integral Values
`define DMA_DATA_32_BIT       15  // 0 : 16 bit , 1:32 Bit data

`define FORCE_WRITE           16
`define FORCE_READ            17

//`define FWUSTAR_BIT 19
//`define STREAME_BIT     20 // Streaming enable
`define ACQE_BIT 		23
`define STRG_BIT 		24 // Soft Trigger

`endif // _control_word_bits_vh_
