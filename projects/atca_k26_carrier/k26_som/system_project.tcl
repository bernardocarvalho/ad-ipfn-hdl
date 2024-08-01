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
  "$ad_hdl_dir/library/common/ad_iobuf.v" \
  "../src/hdl/system_top.sv" \
  "../src/hdl/shapi_regs.sv" \
  "../src/hdl/system_clocks.v" \
  "../src/hdl/chop_gen.v" \
  "../src/hdl/ad4003_deserializer.v" \
  "../src/hdl/xdma_data_producer.sv" \
  "../src/hdl/si5396a_spi_interface.v" \
  "../src/ip/axis_data_fifo_0/xis_data_fifo_0.xci" \
  "../src/ip/pll_config_rom/pll_config_rom.xci" \
  "src/ip/xdma_id0034/xdma_id0034.xci" \
  "xilinx_pcie_xdma_ref_board.xdc" \
  "system_constr.xdc" ]

#  "$ad_hdl_dir/projects/common/kv260/kv260_system_constr.xdc" ]

adi_project_run atca_k26_carrier_kv260
