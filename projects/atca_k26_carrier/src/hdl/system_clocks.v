//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company: INSTITUTO DOS PLASMAS E FUSAO NUCLEAR
// Engineer:  BBC
//
// Project Name:   atca-k26-carrier 
// Design Name:   
// Module Name:    system_clocks
// Target Devices: xck26-sfvc784-2LV-c
//
//Description:
// Dependencies:
//
// Revision 2 - File Created
// Additional Comments:
//
// Copyright 2020 - 2023 IPFN-Instituto Superior Tecnico, Portugal
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
// ***************************************************************************
`timescale 1ns/1ps
module system_clocks #(
    // Do not override parameters below this line
    parameter TCQ        = 1
)
    (
  input         reset,
  input         clk_in,
  
  output        locked,

  // Clock out ports
  output        clk_out1,
  output        clk_out2,
  output        clk_out3
 );
  // Input buffering
  //------------------------------------

//wire clk_in2_clk_wiz_0;
wire        clk_out1_clk_wiz;
wire        clk_out2_clk_wiz;
wire        clk_out3_clk_wiz;

wire        locked_int;
wire        clkfbout_clk_wiz;
/*
wire clk_in_clk_wiz;
  IBUF clkin1_ibuf
   (.O (clk_in_clk_wiz),
    .I (clk_in));
*/
 // Generated with Vivado 2023.1 Clock wizard
 MMCME4_ADV

  #(.BANDWIDTH            ("OPTIMIZED"),
    .CLKOUT4_CASCADE      ("FALSE"),
    .COMPENSATION         ("AUTO"),
    .STARTUP_WAIT         ("FALSE"),
    .DIVCLK_DIVIDE        (1),
    .CLKFBOUT_MULT_F      (12.000),
    .CLKFBOUT_PHASE       (0.000),
    .CLKFBOUT_USE_FINE_PS ("FALSE"),
    .CLKOUT0_DIVIDE_F     (3.750),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKOUT0_USE_FINE_PS  ("FALSE"),
    .CLKOUT1_DIVIDE       (15),
    .CLKOUT1_PHASE        (0.000),
    .CLKOUT1_DUTY_CYCLE   (0.500),
    .CLKOUT1_USE_FINE_PS  ("FALSE"),
    .CLKOUT2_DIVIDE       (15),
    .CLKOUT2_PHASE        (72),
    .CLKOUT2_DUTY_CYCLE   (0.500),
    .CLKOUT2_USE_FINE_PS  ("FALSE"),
    .CLKIN1_PERIOD        (10.000))

 mmcme4_adv_inst
    // Output clocks
   (
    .CLKFBOUT            (clkfbout_clk_wiz),
    .CLKFBOUTB           (),
    .CLKOUT0             (clk_out1_clk_wiz),
    .CLKOUT0B            (),
    .CLKOUT1             (clk_out2_clk_wiz),
    .CLKOUT1B            (),
    .CLKOUT2             (clk_out3_clk_wiz),
    .CLKOUT2B            (),
    .CLKOUT3             (),
    .CLKOUT3B            (),
    .CLKOUT4             (),
    .CLKOUT5             (),
    .CLKOUT6             (),
     // Input clock control
    .CLKFBIN             (clkfbout_clk_wiz),
    .CLKIN1              (clk_in),
    .CLKIN2              (1'b0),
     // Tied to always select the primary input clock
    .CLKINSEL            (1'b1),
    // Ports for dynamic reconfiguration
    .DADDR               (7'h0),
    .DCLK                (1'b0),
    .DEN                 (1'b0),
    .DI                  (16'h0),
    .DO                  (),
    .DRDY                (),
    .DWE                 (1'b0),
    .CDDCDONE            (),
    .CDDCREQ             (1'b0),
    // Ports for dynamic phase shift
    .PSCLK               (1'b0),
    .PSEN                (1'b0),
    .PSINCDEC            (1'b0),
    .PSDONE              (),
    // Other control and status signals
    .LOCKED              (locked_int),
    .CLKINSTOPPED        (),
    .CLKFBSTOPPED        (),
    .PWRDWN              (1'b0),
    .RST                 (reset_high));
  assign reset_high = reset; 

  assign locked = locked_int;
//--------------------------------------
 // Output buffering
  //-----------------------------------

  BUFG clkout1_buf
   (.O   (clk_out1),
    .I   (clk_out1_clk_wiz));


  BUFG clkout2_buf
   (.O   (clk_out2),
    .I   (clk_out2_clk_wiz));
    
  BUFG clkout3_buf
   (.O   (clk_out3),
    .I   (clk_out3_clk_wiz));
        
endmodule // system_clocks
// vim: set ts=8 sw=4 tw=0 et :

