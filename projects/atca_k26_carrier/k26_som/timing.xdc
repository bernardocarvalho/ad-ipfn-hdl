set_bus_skew -from [get_cells -hierarchical *chopp_period_r_reg*] -to [get_cells -hierarchical *max_count_local_reg*] 32.500
set_max_delay -datapath_only -from [get_cells -hierarchical *chopp_period_r_reg*] -to [get_cells -hierarchical *max_count_local_reg*] 32.500

set_bus_skew -from [get_cells -hierarchical *chopp_period_r_reg*] -to [get_cells -hierarchical *change_count_local_reg*] 32.500
set_max_delay -datapath_only -from [get_cells -hierarchical *chopp_period_r_reg*] -to [get_cells -hierarchical *change_count_local_reg*] 32.500

# adc read delay debug signals
set_output_delay -clock [get_clocks -of_objects [get_pins system_clocks_inst/mmcme4_adv_inst/CLKOUT3]] 3.000 [get_ports adc_read_clk_dbg]
set_output_delay -clock [get_clocks -of_objects [get_pins system_clocks_inst/mmcme4_adv_inst/CLKOUT3]] 3.000 [get_ports reader_en_sync]
set_output_delay -clock [get_clocks -of_objects [get_pins system_clocks_inst/mmcme4_adv_inst/CLKOUT2]] 3.000 [get_ports adc_cnvst_dbg]
set_output_delay -clock [get_clocks -of_objects [get_pins system_clocks_inst/mmcme4_adv_inst/CLKOUT2]] 3.000 [get_ports adc_sck_dbg]
set_max_delay -from [get_ports {adc_sdo_cha_n[0]}] -to [get_ports adc_sdo_cha1] 7.000
set_min_delay -from [get_ports {adc_sdo_cha_n[0]}] -to [get_ports adc_sdo_cha1] 3.000


set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets pl_clk0_i]
