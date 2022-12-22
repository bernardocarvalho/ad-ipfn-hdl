##-----------------------------------------------------------------------------
##
## Project    : The Xilinx PCI Express DMA
## File       : xilinx_pcie_xdma_ref_board.xdc
## Version    : 4.1
##-----------------------------------------------------------------------------
#
###############################################################################
# User Configuration
# Link Width   - x8
# Link Speed   - gen2
# Family       - kintex7
# Part         - xc7k325t
# Package      - ffg900
# Speed grade  - -2
# PCIe Block   - X0Y0

###############################################################################
#
#########################################################################################################################
# User Constraints
#########################################################################################################################

# Replaces userclk2
# https://docs.xilinx.com/r/en-US/ug903-vivado-using-constraints/Limitations
# report_clocks -file /tmp/clocks.txt
#create_generated_clock -name axi_clk [get_pins xdma_id0032_i/inst/xdma_id0032_pcie2_to_pcie3_wrapper_i/pcie2_ip_i/inst/inst/gt_top_i/pipe_wrapper_i/pipe_clock_int.pipe_clock_i/mmcm_i/CLKOUT3]
# XDMA main clocks are
#
#  userclk1               {0.000 2.000}        4.000           250.000 MHz
#  userclk2               {0.000 4.000}        8.000           125.000 MHz
# Rename clk
#create_generated_clock -name adc_dt_clk [get_pins system_clocks_inst/mmcm_sc_100_inst/CLKOUT2]

###############################################################################
# User Time Names / User Time Groups / Time Specs
###############################################################################
create_clock -period 10.000 -name pci_sys_clk [get_ports pci_sys_clk_p]

#set_false_path -through [get_pins xdma_0_i/inst/pcie3_ip_i/inst/pcie_top_i/pcie_7vx_i/PCIE_3_0_i/CFGMAX*]
#set_false_path -through [get_nets xdma_0_i/inst/cfg_max*]

###############################################################################
# User Physical Constraints
###############################################################################

###############################################################################
# Pinout and Related I/O Constraints
###############################################################################


###############################################################################
# Pinout and Related I/O Constraints
###############################################################################
##### SYS RESET###########
set_property LOC G25 [get_ports pci_sys_rst_n]
set_property PULLUP true [get_ports pci_sys_rst_n]
set_property IOSTANDARD LVCMOS25 [get_ports pci_sys_rst_n]
set_false_path -from [get_ports pci_sys_rst_n]

set_false_path -from [get_ports sys_rst]
###############################################################################
# Physical Constraints
###############################################################################
#
# SYS clock 100 MHz (input) signal. The pci_sys_clk_p and pci_sys_clk_n
# signals are the PCI Express reference clock.
set_property LOC IBUFDS_GTE2_X0Y1 [get_cells pci_refclk_ibuf]

# Other constraints in:
#.../projects/common/kc705/kc705_system_constr.xdc
#First LED
#set_property -dict  {PACKAGE_PIN  AB8   IOSTANDARD  LVCMOS15} [get_ports gpio_bd[9]]
# PACKAGE_PIN AB8 [get_ports GPIO_LED_0_LS] 
#
################################################################################
##### SMA CLOCKS and GPOI
###############################################################################
set_property IOSTANDARD LVCMOS25 [get_ports user_sma_clk_*]
#user_sma_clk_p SMA J11
set_property PACKAGE_PIN L25 [get_ports user_sma_clk_p]
set_property PACKAGE_PIN K25 [get_ports user_sma_clk_n]
set_false_path -to [get_ports user_sma_clk_p]
set_false_path -to [get_ports user_sma_clk_n]
#set_output_delay -clock atca_clk10 -max 2.0 [get_ports user_sma_clk_p]
#set_output_delay -clock atca_clk10 -min 1.0 [get_ports user_sma_clk_n]

set_property IOSTANDARD LVCMOS25 [get_ports user_sma_gpio_*]
set_property PACKAGE_PIN Y23 [get_ports user_sma_gpio_p]
set_property PACKAGE_PIN Y24 [get_ports user_sma_gpio_n]
set_false_path -to [get_ports user_sma_gpio_p]
set_false_path -to [get_ports user_sma_gpio_n]

# These regs are stable during Acquisition
set_false_path -from [get_pins {shapi_regs_v1_inst/control_r_reg[*]/C}]
set_false_path -from [get_pins {shapi_regs_v1_inst/trig0_r_reg[*]/C}] 
set_false_path -from [get_pins {shapi_regs_v1_inst/trig1_r_reg[*]/C}] 
set_false_path -from [get_pins {shapi_regs_v1_inst/trig2_r_reg[*]/C}] 
set_false_path -from [get_pins {shapi_regs_v1_inst/param_mul_r_reg[*]/C}] 
set_false_path -from [get_pins {shapi_regs_v1_inst/param_off_r_reg[*]/C}] 
set_false_path -from [get_pins {shapi_regs_v1_inst/param_init_delay_r_reg[*]/C}] 

set_false_path -from [get_pins {trigger_gen_i/pulse_delay_r_reg[*]/C}] 
set_false_path -from [get_pins {trigger_gen_i/detect_pls_r_reg[*]/C}] 
set_false_path -from [get_pins {acq_on_r_reg/C}] 
# Used just for debug ...
set_false_path -from [get_pins {xpm_fifo_axis_c2h0_i/xpm_fifo_base_inst/gen_pntr_flags_cc.gaf_cc.ram_afull_i_reg/C}]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
