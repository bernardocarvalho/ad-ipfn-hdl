# https://grittyengineer.com/creating-vivado-ip-the-smart-tcl-way/
# create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_data_fifo_0 -dir /home/bernardo/git-repos/ad-ipfn-hdl/projects/atca_k26_carrier/k26_som/src/ip
#
set path_ip [file dirname [info script]]

# set part "xilinx.com:kv260_som:part0:1.4"
set device "xck26-sfvc784-2LV-c"
## Create project
create_project -in_memory -part $device
#set_property board_part xilinx.com:kv260_som:part0:1.4 [current_project]
# set_property board_connections {som240_1_connector xilinx.com:kv260_carrier:som240_1_connector:1.3} [current_project]

set ip_name axis_data_fifo_0
# Just in case
if { [file exists $path_ip/$ip_name/$ip_name.dcp]} {
    puts "file exist: $path_ip/$ip_name.dcp, delete it."
    file delete -force $path_ip/$ip_name/$ip_name.dcp
}
#
#create_ip -name xdma -vendor xilinx.com -library ip -version 4.1 
create_ip -vlnv xilinx.com:ip:axis_data_fifo:2.0 -module_name $ip_name \
    -dir $path_ip -force

#  CONFIG.HAS_TKEEP {1}  CONFIG.Component_Name {$ip_name} 
set_property -dict [list CONFIG.FIFO_DEPTH {16384} \
  CONFIG.HAS_PROG_FULL {1} \
  CONFIG.HAS_TLAST {1} \
  CONFIG.HAS_WR_DATA_COUNT {1} \
  CONFIG.IS_ACLK_ASYNC {1} \
  CONFIG.PROG_FULL_THRESH {16350} \
  CONFIG.TDATA_NUM_BYTES {16}] [get_ips $ip_name]
     

generate_target all [get_ips]
# convert_ips [get_files  /home/bernardo/fpga/vivado/2022.1/atca-mimo-v2-adc/src/ip/xdma_id0032/xdma_id0032.xci]

# Synthesize all the IP
synth_ip [get_ips]

