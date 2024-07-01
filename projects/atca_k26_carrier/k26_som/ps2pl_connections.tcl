## IPFN atca-k26-carrier PS to PL Interconnections
#
create_bd_port -dir O pl_clk0
connect_bd_net [get_bd_ports pl_clk0] [get_bd_pins sys_ps8/pl_clk0]

# create_bd_port -dir O -from 31 -to 0 adc_data_b
# connect_bd_net [get_bd_ports adc_data_b] [get_bd_pins axi_ad9250_core/adc_data_1]
