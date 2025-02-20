vlib work
vdel -all
vlib work
#vlog alu.sv intf.sv transaction.sv generator.sv driver_v2.sv environment.sv tb_top.sv +acc 
vlog opcodes.sv alu.sv intf.sv transaction.sv generator.sv driver_v2.sv intf2mon.sv scb.sv environment_v2.sv tb_top_v2.sv +acc 
#vsim -coverage top -voptargs="+cover=bcesf"
vsim work.tb_top
#vsim -voptargs=+acc work.top
#add wave -r *
run -all
#coverage report -details -code bcesf -output coverage_report_3.txt
#coverage report -details -code bcesf -cvg -output coverage_report_final.txtddo 