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
#15A
#15B
#16A
#16B
set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L3P_*_65}] [get_ports {adc_sdo_cha_p[0]}]
set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L1P_*_65}] [get_ports {adc_sdo_chb_p[0]}]
set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L17P_*_65}] [get_ports {adc_sdo_cha_p[1]}]
set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L2P_*_65}] [get_ports {adc_sdo_chb_p[1]}]

#13A
#13B
#14A
#14B
set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L22P_*_65}] [get_ports {adc_sdo_cha_p[2]}]
set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L23P_*_65}] [get_ports {adc_sdo_chb_p[2]}]
set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L5P_*_65}] [get_ports {adc_sdo_cha_p[3]}]
set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L16P_*_65}] [get_ports {adc_sdo_chb_p[3]}]
#1-4 AB
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L19P_*_65}] [get_ports {adc_sdo_cha_p[ 4]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L10P_*_65}] [get_ports {adc_sdo_chb_p[ 4]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L9P_*_65}] [get_ports {adc_sdo_cha_p[ 5]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L15P_*_65}] [get_ports {adc_sdo_chb_p[ 5]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L7P_*_65}] [get_ports {adc_sdo_cha_p[ 6]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L8P_*_65}] [get_ports {adc_sdo_chb_p[ 6]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L4P_*_65}] [get_ports {adc_sdo_cha_p[ 7]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L21P_*_65}] [get_ports {adc_sdo_chb_p[ 7]}]
#5-8 AB
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L8P_*_64}] [get_ports {adc_sdo_cha_p[ 8]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L24P_*_65}] [get_ports {adc_sdo_chb_p[ 8]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L16P_*_64}] [get_ports {adc_sdo_cha_p[ 9]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L23P_*_64}] [get_ports {adc_sdo_chb_p[ 9]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L20P_*_64}] [get_ports {adc_sdo_cha_p[10]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L17P_*_64}] [get_ports {adc_sdo_chb_p[10]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L9P_*_64}] [get_ports {adc_sdo_cha_p[11]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L17P_*_64}] [get_ports {adc_sdo_chb_p[11]}]
#9-12 AB
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L22P_*_64}] [get_ports {adc_sdo_cha_p[12]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L19P_*_64}] [get_ports {adc_sdo_chb_p[12]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L7P_*_65}] [get_ports {adc_sdo_cha_p[13]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L5P_*_65}] [get_ports {adc_sdo_chb_p[13]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L15P_*_65}] [get_ports {adc_sdo_cha_p[14]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L1P_*_65}] [get_ports {adc_sdo_chb_p[14]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L2P_*_65}] [get_ports {adc_sdo_cha_p[15]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L21P_*_65}] [get_ports {adc_sdo_chb_p[15]}]
#17-20 AB
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L7P_*_66}] [get_ports {adc_sdo_cha_p[16]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L8P_*_66}] [get_ports {adc_sdo_chb_p[16]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L5P_*_66}] [get_ports {adc_sdo_cha_p[17]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L12P_*_66}] [get_ports {adc_sdo_chb_p[17]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L9P_*_66}] [get_ports {adc_sdo_cha_p[18]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L15P_*_66}] [get_ports {adc_sdo_chb_p[18]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L14P_*_66}] [get_ports {adc_sdo_cha_p[19]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L16P_*_66}] [get_ports {adc_sdo_chb_p[19]}]
#21-24 AB
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L17P_*_66}] [get_ports {adc_sdo_cha_p[20]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L13P_*_66}] [get_ports {adc_sdo_chb_p[20]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L11P_*_66}] [get_ports {adc_sdo_cha_p[21]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L10P_*_66}] [get_ports {adc_sdo_chb_p[21]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L2P_*_66}] [get_ports {adc_sdo_cha_p[22]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L4P_*_66}] [get_ports {adc_sdo_chb_p[22]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L3P_*_66}] [get_ports {adc_sdo_cha_p[23]}]
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L1P_*_66}] [get_ports {adc_sdo_chb_p[23]}]

set_property IOSTANDARD LVDS [get_ports adc_sdi_p]
set_property IOSTANDARD LVDS [get_ports adc_sck_p]
set_property IOSTANDARD LVDS [get_ports acq_clk_p]
set_property IOSTANDARD LVDS [get_ports adc_cnvst_p]

set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L5P_*_64}] [get_ports adc_sdi_p]
set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L11P_*_64}] [get_ports acq_clk_p]
set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L14P_*_64}] [get_ports adc_sck_p]
set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L4P_*_64}] [get_ports adc_cnvst_p]


set_property IOSTANDARD LVCMOS33 [get_ports carrier_led[*]]
set_property DRIVE 12 [get_ports carrier_led[*]]
set_property SLEW SLOW [get_ports carrier_led[*]]

set_property PACKAGE_PIN AC11 [get_ports carrier_led[0]]
set_property PACKAGE_PIN AB11 [get_ports carrier_led[1]]
set_property PACKAGE_PIN AA10 [get_ports carrier_led[2]]
set_property PACKAGE_PIN AA11 [get_ports carrier_led[3]]


set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN ENABLE [current_design]
