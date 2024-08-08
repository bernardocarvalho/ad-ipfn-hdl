set_bus_skew -from [get_cells -hierarchical *chopp_period_r_reg*] -to [get_cells -hierarchical *max_count_local_reg*] 32.500
set_max_delay -datapath_only -from [get_cells -hierarchical *chopp_period_r_reg*] -to [get_cells -hierarchical *max_count_local_reg*] 32.500

set_bus_skew -from [get_cells -hierarchical *chopp_period_r_reg*] -to [get_cells -hierarchical *change_count_local_reg*] 32.500
set_max_delay -datapath_only -from [get_cells -hierarchical *chopp_period_r_reg*] -to [get_cells -hierarchical *change_count_local_reg*] 32.500

set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets pl_clk0_i]