###############################################################################
## Copyright (C) 2023 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

# constraints
# KV260
set_property  -dict {PACKAGE_PIN A12 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4}  [get_ports fan_en_b]; # Bank  45 VCCO - som240_1_b13 - IO_L11P_AD9P_45

# K26_SOM
# Common rules

set_property IOSTANDARD LVDS [get_ports {adc_sdo_cha_p[*]}]
set_property IOSTANDARD LVDS [get_ports {adc_sdo_chb_p[*]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {adc_sdo_cha_p[*]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {adc_sdo_chb_p[*]}]

# testing modules in slots 14/15
set_property PACKAGE_PIN U8 [get_ports {adc_sdo_cha_p[0]}]
set_property PACKAGE_PIN W8 [get_ports {adc_sdo_chb_p[0]}]
set_property PACKAGE_PIN N9 [get_ports {adc_sdo_cha_p[1]}]
set_property PACKAGE_PIN U9 [get_ports {adc_sdo_chb_p[1]}]

#set_property PACKAGE_PIN J5 [get_ports {adc_sdo_cha_p[0]}]
#set_property PACKAGE_PIN H4 [get_ports {adc_sdo_chb_p[0]}]
#set_property PACKAGE_PIN K2 [get_ports {adc_sdo_cha_p[1]}]
#set_property PACKAGE_PIN N7 [get_ports {adc_sdo_chb_p[1]}]

set_property PACKAGE_PIN L1 [get_ports {adc_sdo_cha_p[2]}]
set_property PACKAGE_PIN J1 [get_ports {adc_sdo_chb_p[2]}]
set_property PACKAGE_PIN R8 [get_ports {adc_sdo_cha_p[3]}]
set_property PACKAGE_PIN J7 [get_ports {adc_sdo_chb_p[3]}]


#set_property PACKAGE_PIN AF8 [get_ports {adc_sdo_cha_p[4]}]
#set_property PACKAGE_PIN H9 [get_ports {adc_sdo_chb_p[4]}]
#set_property PACKAGE_PIN AD2 [get_ports {adc_sdo_cha_p[5]}]
#set_property PACKAGE_PIN AG6 [get_ports {adc_sdo_chb_p[5]}]
#set_property PACKAGE_PIN AG3 [get_ports {adc_sdo_cha_p[6]}]
#set_property PACKAGE_PIN AH2 [get_ports {adc_sdo_chb_p[6]}]
#set_property PACKAGE_PIN AH8 [get_ports {adc_sdo_cha_p[7]}]
#set_property PACKAGE_PIN AB2 [get_ports {adc_sdo_chb_p[7]}]



set_property IOSTANDARD LVDS [get_ports adc_sdi_p]
set_property IOSTANDARD LVDS [get_ports adc_sck_p]
set_property IOSTANDARD LVDS [get_ports acq_clk_p]
set_property IOSTANDARD LVDS [get_ports adc_cnvst_p]


set_property PACKAGE_PIN AB7 [get_ports adc_sdi_p]
set_property PACKAGE_PIN AF7 [get_ports acq_clk_p]
set_property PACKAGE_PIN AC4 [get_ports adc_sck_p]
set_property PACKAGE_PIN AD7 [get_ports adc_cnvst_p]

set_property IOSTANDARD LVCMOS33 [get_ports carrier_led[*]]
set_property DRIVE 12 [get_ports carrier_led[*]]
set_property SLEW SLOW [get_ports carrier_led[*]]

set_property PACKAGE_PIN AC11 [get_ports carrier_led[0]]
set_property PACKAGE_PIN AB11 [get_ports carrier_led[1]]
set_property PACKAGE_PIN AA10 [get_ports carrier_led[2]]
set_property PACKAGE_PIN AA11 [get_ports carrier_led[3]]


set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN ENABLE [current_design]
