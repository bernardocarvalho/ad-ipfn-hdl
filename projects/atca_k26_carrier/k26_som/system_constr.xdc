###############################################################################
## Copyright (C) 2023 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

# constraints
# KV260
set_property -dict {PACKAGE_PIN A12 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports fan_en_b]

set_property -dict {PACKAGE_PIN AE10 IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports adc_chop]

# K26_SOM
# Common rules

set_property IOSTANDARD LVDS [get_ports {adc_sdo_cha_p[*]}]
set_property IOSTANDARD LVDS [get_ports {adc_sdo_chb_p[*]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {adc_sdo_cha_p[*]}]
set_property DIFF_TERM_ADV TERM_100 [get_ports {adc_sdo_chb_p[*]}]

set_property PACKAGE_PIN U8 [get_ports {adc_sdo_cha_p[0]}]
set_property PACKAGE_PIN W8 [get_ports {adc_sdo_chb_p[0]}]
set_property PACKAGE_PIN N9 [get_ports {adc_sdo_cha_p[1]}]
set_property PACKAGE_PIN U9 [get_ports {adc_sdo_chb_p[1]}]

set_property PACKAGE_PIN K8 [get_ports {adc_sdo_cha_p[2]}]
set_property PACKAGE_PIN K9 [get_ports {adc_sdo_chb_p[2]}]
set_property PACKAGE_PIN R7 [get_ports {adc_sdo_cha_p[3]}]
set_property PACKAGE_PIN P7 [get_ports {adc_sdo_chb_p[3]}]

#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L19P_*_65}] [get_ports  {adc_sdo_cha_p[4]}]; # 1A
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L10P_*_65}] [get_ports  {adc_sdo_chb_p[4]}]; # 1B
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L9P_*_65}] [get_ports  {adc_sdo_cha_p[5]}]; # 2A
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L15P_*_65}] [get_ports  {adc_sdo_chb_p[5]}]; # 2B
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L7P_*_65}] [get_ports  {adc_sdo_cha_p[6]}]; # 3A
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L8P_*_65}] [get_ports  {adc_sdo_chb_p[6]}]; # 3B
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L4P_*_65}] [get_ports  {adc_sdo_cha_p[7]}]; # 4A
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L21P_*_65}] [get_ports  {adc_sdo_chb_p[7]}]; # 4B

#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L8P_*_64}] [get_ports  {adc_sdo_cha_p[8]}]; # 5A
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L24P_*_65}] [get_ports  {adc_sdo_chb_p[8]}]; # 5B
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L16P_*_64}] [get_ports  {adc_sdo_cha_p[9]}]; # 6A
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L23P_*_64}] [get_ports  {adc_sdo_chb_p[9]}]; # 6B
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L20P_*_64}] [get_ports {adc_sdo_cha_p[10]}]; # 7A
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L17P_*_64}] [get_ports {adc_sdo_chb_p[10]}]; # 7B
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L9P_*_64}] [get_ports {adc_sdo_cha_p[11]}]; # 8A
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L17P_*_64}] [get_ports {adc_sdo_chb_p[11]}]; # 8B

#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L22P_*_64}] [get_ports {adc_sdo_cha_p[12]}]; # 9A
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L19P_*_64}] [get_ports {adc_sdo_chb_p[12]}]; # 9B
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L7P_*_65}] [get_ports {adc_sdo_cha_p[13]}]; #10A
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L5P_*_65}] [get_ports {adc_sdo_chb_p[13]}]; #10B
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L15P_*_65}] [get_ports {adc_sdo_cha_p[14]}]; #11A
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L1P_*_65}] [get_ports {adc_sdo_chb_p[14]}]; #11B
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L2P_*_65}] [get_ports {adc_sdo_cha_p[15]}]; #12A
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L21P_*_65}] [get_ports {adc_sdo_chb_p[15]}]; #12B

#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L7P_*_66}] [get_ports {adc_sdo_cha_p[16]}]; #17A
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L8P_*_66}] [get_ports {adc_sdo_chb_p[16]}]; #17B
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L5P_*_66}] [get_ports {adc_sdo_cha_p[17]}]; #18A
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L12P_*_66}] [get_ports {adc_sdo_chb_p[17]}]; #18B
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L9P_*_66}] [get_ports {adc_sdo_cha_p[18]}]; #19A
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L15P_*_66}] [get_ports {adc_sdo_chb_p[18]}]; #19B
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L14P_*_66}] [get_ports {adc_sdo_cha_p[19]}]; #20A
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L16P_*_66}] [get_ports {adc_sdo_chb_p[19]}]; #20B

#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L17P_*_66}] [get_ports {adc_sdo_cha_p[20]}]; #21A
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L13P_*_66}] [get_ports {adc_sdo_chb_p[20]}]; #21B
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L11P_*_66}] [get_ports {adc_sdo_cha_p[21]}]; #22A
#set_property LOC [get_package_pins -filter {PIN_FUNC =~ *L10P_*_66}] [get_ports {adc_sdo_chb_p[21]}]; #22B
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L2P_*_66}] [get_ports {adc_sdo_cha_p[22]}]; #23A
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L4P_*_66}] [get_ports {adc_sdo_chb_p[22]}]; #23B
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L3P_*_66}] [get_ports {adc_sdo_cha_p[23]}]; #24A
#set_property LOC [get_package_pins -filter {PIN_FUNC =~  *L1P_*_66}] [get_ports {adc_sdo_chb_p[23]}]; #24B


set_property PACKAGE_PIN AB7 [get_ports adc_sdi_p]
set_property PACKAGE_PIN AF7 [get_ports acq_clk_p]
set_property PACKAGE_PIN AC4 [get_ports adc_sck_p]
set_property PACKAGE_PIN AD7 [get_ports adc_cnvst_p]
set_property IOSTANDARD LVDS [get_ports adc_sdi_p]
set_property IOSTANDARD LVDS [get_ports adc_sck_p]
set_property IOSTANDARD LVDS [get_ports acq_clk_p]
set_property IOSTANDARD LVDS [get_ports adc_cnvst_p]

set_property PACKAGE_PIN AG11 [get_ports pll_sdio]
set_property PACKAGE_PIN AH11 [get_ports pll_nreset]
set_property PACKAGE_PIN AH10 [get_ports pll_sclk]
set_property PACKAGE_PIN AF11 [get_ports pll_nCS]
set_property -dict {IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 4} [get_ports pll_*]


set_property -dict {IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports adc_chop]

set_property PACKAGE_PIN AC11 [get_ports {carrier_led[0]}]
set_property PACKAGE_PIN AB11 [get_ports {carrier_led[1]}]
set_property PACKAGE_PIN AA10 [get_ports {carrier_led[2]}]
set_property PACKAGE_PIN AA11 [get_ports {carrier_led[3]}]
set_property -dict {IOSTANDARD LVCMOS33 SLEW SLOW DRIVE 12} [get_ports {carrier_led[*]}]

set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN ENABLE [current_design]

