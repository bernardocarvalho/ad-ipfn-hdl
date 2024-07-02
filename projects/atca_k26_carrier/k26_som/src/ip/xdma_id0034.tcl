# https://grittyengineer.com/creating-vivado-ip-the-smart-tcl-way/
#
set path_ip [file dirname [info script]]

# source $path_ip/../scripts/part.tcl

# set part "xilinx.com:kv260_som:part0:1.4"
# set part xck26
set device "xck26-sfvc784-2LV-c"
## Create project
create_project -in_memory -part $device
set_property board_part xilinx.com:kv260_som:part0:1.4 [current_project]
# set_property board_connections {som240_1_connector xilinx.com:kv260_carrier:som240_1_connector:1.3} [current_project]


set ip_name xdma_id0034
# Just in case
if { [file exists $path_ip/$ip_name/$ip_name.dcp]} {
    puts "file exist: $path_ip/$ip_name.dcp, delete it."
    file delete -force $path_ip/$ip_name/$ip_name.dcp
}
#
#create_ip -name xdma -vendor xilinx.com -library ip -version 4.1 
create_ip -vlnv xilinx.com:ip:xdma:4.1 -module_name $ip_name \
    -dir $path_ip -force

set_property -dict [list CONFIG.Component_Name {$ip_name} \
    CONFIG.pl_link_cap_max_link_width {X4} CONFIG.pl_link_cap_max_link_speed {5.0_GT/s} \
    CONFIG.axi_data_width {128_bit} CONFIG.axisten_freq {125} \
    CONFIG.pf0_device_id {0034} CONFIG.pf0_subsystem_id {0035} \
    CONFIG.pf0_base_class_menu {Intelligent_I/O_controllers} \
    CONFIG.pf0_class_code_base {0E} \
    CONFIG.pf0_sub_class_interface_menu {Message_FIFO_at_offset_040h} \
    CONFIG.pf0_class_code_sub {00} CONFIG.pf0_class_code_interface {00} \
    CONFIG.pf0_class_code {0E0000} CONFIG.axilite_master_en {true} \
    CONFIG.xdma_wnum_chnl {2} CONFIG.xdma_wnum_rids {32} CONFIG.plltype {QPLL1} \
    CONFIG.xdma_axi_intf_mm {AXI_Stream} CONFIG.pf0_msix_cap_table_bir {BAR_1} \
    CONFIG.pf0_msix_cap_pba_bir {BAR_1} CONFIG.cfg_mgmt_if {false} \
    CONFIG.PF0_DEVICE_ID_mqdma {9024} CONFIG.PF2_DEVICE_ID_mqdma {9024} \
    CONFIG.PF3_DEVICE_ID_mqdma {9024} CONFIG.disable_gt_loc {true}] [get_ips $ip_name]
     


generate_target all [get_ips]
# convert_ips [get_files  /home/bernardo/fpga/vivado/2022.1/atca-mimo-v2-adc/src/ip/xdma_id0032/xdma_id0032.xci]

# Synthesize all the IP
synth_ip [get_ips]

