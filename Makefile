
QUESTA_HOME = /pkgs/mentor/questa/2024.2/questasim/

HW   = ./

VLIB = $(QUESTA_HOME)/bin/vlib
VMAP = $(QUESTA_HOME)/bin/vmap
VLOG = $(QUESTA_HOME)/bin/vlog -lint +acc=all -work work 
VOPT = $(QUESTA_HOME)/bin/vopt 
VSIM = $(QUESTA_HOME)/bin/vsim -voptargs=+acc -work work 

.PHONY: all compile sim gui clean

all: 
	@echo " "
	@echo " make targets are: "
	@echo "   - clean   = remove created files and cruft "
	@echo "   - compile = analyze all input hdl files "
	@echo "   - sim     = run simulation in Questa (command line) "
	@echo "   - gui     = run simulation in Questa with GUI "
	@echo "   - broken  = run simulation with injected errors, should fail "
	@echo " "

gui: compile
	$(VSIM) -do run_gui.do top
	$(VSIM) -do run_gui.do alu_unit_test

sim: compile
	$(VSIM) -c -do run.do top
	$(VSIM) -c -do run.do alu_unit_test

broken: compile
	$(VSIM) -g broken=1 -c -do run.do top

compile: clean
	rm -rf ./work

	$(VLIB) ./work
	$(VMAP) work ./work

	$(VLOG) $(HW)/opcode_pkg.sv
	$(VLOG) $(HW)/testbench.sv
	$(VLOG) $(HW)/alu.sv
	$(VLOG) $(HW)/branch_ctrl.sv
	$(VLOG) $(HW)/memory_ctrl.sv
	$(VLOG) $(HW)/ssram.sv
	$(VLOG) $(HW)/alu_unit_test.sv

CRUFT  = transcript
CRUFT += *.wlf
CRUFT += work
CRUFT += modelsim.ini

clean:
	rm -rf $(CRUFT)
