###############################################################################
## Copyright (C) 2014-2023 Analog Devices, Inc. All rights reserved.
### SPDX short identifier: ADIBSD
###############################################################################

source ../../../scripts/adi_env.tcl
source $ad_hdl_dir/projects/scripts/adi_project_xilinx.tcl
source $ad_hdl_dir/projects/scripts/adi_board.tcl

# source src/ip/xdma_id0034/xdma_id0034.tcl 

# project sufix must be one of the know adi boards
adi_project atca_k26_carrier_kv260
adi_project_files atca_k26_carrier_kv260 [list \
  "$ad_hdl_dir/projects/atca_k26_carrier/src/hdl/system_top.v" \
  "$ad_hdl_dir/projects/atca_k26_carrier/src/hdl/shapi_regs.sv" \
  "src/ip/xdma_id0034/xdma_id0034.xci" \
  "$ad_hdl_dir/library/common/ad_iobuf.v" \
  "$ad_hdl_dir/projects/common/kv260/kv260_system_constr.xdc" ]

adi_project_run atca_k26_carrier_kv260
