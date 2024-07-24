#-----------------------------------------------------------
# Process ID: 110891
# Current directory: /home/bernardo/git-repos/ad-ipfn-hdl/projects/atca_k26_carrier/kv260
# Command line: vivado -mode tcl
# Log file: /home/bernardo/git-repos/ad-ipfn-hdl/projects/atca_k26_carrier/kv260/vivado.log
# Journal file: /home/bernardo/git-repos/ad-ipfn-hdl/projects/atca_k26_carrier/kv260/vivado.jou
# Running On: kane584, OS: Linux, CPU Frequency: 1200.282 MHz, CPU Physical cores: 6, Host memory: 67039 MB
#-----------------------------------------------------------
open_project atca_k26_carrier_kv260
update_compile_order -fileset sources_1
reset_run synth_1
launch_runs synth_1 -jobs 10
wait_on_run synth_1
puts "synth_1 completed";
# launch_runs impl_1 -jobs 10
# quit
