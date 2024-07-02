##-----------------------------------------------------------------------------
##
## (c) Copyright 2012-2012 Xilinx, Inc. All rights reserved.
##
## This file contains confidential and proprietary information
## of Xilinx, Inc. and is protected under U.S. and
## international copyright and other intellectual property
## laws.
##
## DISCLAIMER
## This disclaimer is not a license and does not grant any
## rights to the materials distributed herewith. Except as
## otherwise provided in a valid license issued to you by
## Xilinx, and to the maximum extent permitted by applicable
## law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
## WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
## AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
## BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
## INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
## (2) Xilinx shall not be liable (whether in contract or tort,
## including negligence, or under any other theory of
## liability) for any loss or damage of any kind or nature
## related to, arising under or in connection with these
## materials, including for any direct, or any indirect,
## special, incidental, or consequential loss or damage
## (including loss of data, profits, goodwill, or any type of
## loss or damage suffered as a result of any action brought
## by a third party) even if such damage or loss was
## reasonably foreseeable or Xilinx had been advised of the
## possibility of the same.
##
## CRITICAL APPLICATIONS
## Xilinx products are not designed or intended to be fail-
## safe, or for use in any application requiring fail-safe
## performance, such as life-support or safety devices or
## systems, Class III medical devices, nuclear facilities,
## applications related to the deployment of airbags, or any
## other applications that could lead to death, personal
## injury, or severe property or environmental damage
## (individually and collectively, "Critical
## Applications"). Customer assumes the sole risk and
## liability of any use of Xilinx products in Critical
## Applications, subject only to applicable laws and
## regulations governing limitations on product liability.
##
## THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
## PART OF THIS FILE AT ALL TIMES.
##
##-----------------------------------------------------------------------------
##
## Project    : The Xilinx PCI Express DMA 
## File       : xilinx_pcie_xdma_ref_board.xdc
## Version    : 4.1
##-----------------------------------------------------------------------------
#
# User Configuration
# Link Width   - x4
# Link Speed   - Gen2
# Family       - zynquplus
# Part         - xck26
# Package      - sfvc784
# Speed grade  - -2LV
#
# PCIe Block INT - 1
# PCIe Block STR - X0Y1
#

# Xilinx Reference Board is KV260_SOM
###############################################################################
# User Time Names / User Time Groups / Time Specs
###############################################################################
##
## Free Running Clock is Required for IBERT/DRP operations.
##
#############################################################################################################
create_clock -name sys_clk -period 10 [get_ports sys_clk_p]
#
#############################################################################################################
set_false_path -from [get_ports sys_rst_n]
set_property PULLUP true [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS18 [get_ports sys_rst_n]
#
set_property LOC [get_package_pins -filter {PIN_FUNC =~ *_PERSTN0_65}] [get_ports sys_rst_n]
#set_property PACKAGE_PIN AV27 [get_ports sys_rst_n]
#
set_property CONFIG_VOLTAGE 1.8 [current_design]
#
#############################################################################################################
set_property LOC [get_package_pins -of_objects [get_bels [get_sites -filter {NAME =~ *COMMON*} -of_objects [get_iobanks -of_objects [get_sites GTHE4_CHANNEL_X0Y7]]]/REFCLK0P]] [get_ports sys_clk_p]
set_property LOC [get_package_pins -of_objects [get_bels [get_sites -filter {NAME =~ *COMMON*} -of_objects [get_iobanks -of_objects [get_sites GTHE4_CHANNEL_X0Y7]]]/REFCLK0N]] [get_ports sys_clk_n]
#
# MGT 0 interface pins
# set_property PACKAGE_PIN Y5 [get_ports gth_ref_clk0_n]
# set_property PACKAGE_PIN Y6 [get_ports gth_ref_clk0_p]
# set_property PACKAGE_PIN V5 [get_ports gth_ref_clk1_n]
# set_property PACKAGE_PIN V6 [get_ports gth_ref_clk1_p]
set_property PACKAGE_PIN Y1 [get_ports {pcie_mgt_0_rxn[0]}]
set_property PACKAGE_PIN V1 [get_ports {pcie_mgt_0_rxn[1]}]
set_property PACKAGE_PIN T1 [get_ports {pcie_mgt_0_rxn[2]}]
set_property PACKAGE_PIN P1 [get_ports {pcie_mgt_0_rxn[3]}]
set_property PACKAGE_PIN Y2 [get_ports {pcie_mgt_0_rxp[0]}]
set_property PACKAGE_PIN V2 [get_ports {pcie_mgt_0_rxp[1]}]
set_property PACKAGE_PIN T2 [get_ports {pcie_mgt_0_rxp[2]}]
set_property PACKAGE_PIN P2 [get_ports {pcie_mgt_0_rxp[3]}]
set_property PACKAGE_PIN W3 [get_ports {pcie_mgt_0_txn[0]}]
set_property PACKAGE_PIN U3 [get_ports {pcie_mgt_0_txn[1]}]
set_property PACKAGE_PIN R3 [get_ports {pcie_mgt_0_txn[2]}]
set_property PACKAGE_PIN N3 [get_ports {pcie_mgt_0_txn[3]}]
set_property PACKAGE_PIN W4 [get_ports {pcie_mgt_0_txp[0]}]
set_property PACKAGE_PIN U4 [get_ports {pcie_mgt_0_txp[1]}]
set_property PACKAGE_PIN R4 [get_ports {pcie_mgt_0_txp[2]}]
set_property PACKAGE_PIN N4 [get_ports {pcie_mgt_0_txp[3]}]

#############################################################################################################
#############################################################################################################
#
#
# BITFILE/BITSTREAM compress options
#
#set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]
#set_property BITSTREAM.CONFIG.BPI_SYNC_MODE Type1 [current_design]
#set_property CONFIG_MODE BPI16 [current_design]
#set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
#set_property BITSTREAM.CONFIG.UNUSEDPIN Pulldown [current_design]
#
#
set_false_path -to [get_pins -hier *sync_reg[0]/D]
#
