///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company: INSTITUTO DE PLASMAS E FUSAO NUCLEAR
// Engineer: BBC
//
// Create Date:   13:45:00 15/04/2016
// Project Name:
// Design Name:
// Module Name:  header for ADC data functions
// Target Devices:
// Tool versions:  Vivado 2022.1
//
// Description:
// Verilog Header
//
//
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
`ifndef _atca_k26_config_vh_
`define _atca_k26_config_vh_

`define N_ADC_MAX_CHANNELS 32
`define ADC_DATA_WIDTH 18
`define FLOAT_WIDTH    32
//`define N_INT_CHANNELS  8

//`define MASTER_ATCA_ADDR  8'h45  // Upper slot on IPFN 4 slot ATCA
//`define MASTER_ATCA_ADDR  8'hCE  //  ATCA board slot on Garching/Greifswald Lab ATCA crates

//`define I2C_MAGIC         8'h53  // Same MSByte of SHAPI Magic WORD

`define HOLD_SAMPLES    3   // Suppress N data samples and hold last good values during dechopping algorithm
`define CHOP_DLAY       3  // Delay N data samples for phase reconstruction


`endif // _atca_k26_config_vh_
