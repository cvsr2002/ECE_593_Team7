
QUESTA_HOME = /pkgs/mentor/questa/2024.2/questasim/
#QUESTA_HOME = /u/release/questa/2024.2/questasim/

HW   = ../../../design_rtl
TB   = ./

VLIB = $(QUESTA_HOME)/bin/vlib
VMAP = $(QUESTA_HOME)/bin/vmap
VLOG = $(QUESTA_HOME)/bin/vlog -lint +acc=all -work work 
VOPT = $(QUESTA_HOME)/bin/vopt 
VSIM = $(QUESTA_HOME)/bin/vsim -voptargs=+acc -work work 

.PHONY: all compile sim gui clean

all: 
	@echo " "
	@echo " make targets are: "
	@echo "   - sim "
	@echo "   - gui "
	@echo "   - fib  = run fibonacci program "
	@echo "   - mem_test = run memory test "
	@echo " "

gui: compile
	$(VSIM) -do run_gui.do cpu_tb

sim: compile
	$(VSIM) -c -do run.do cpu_tb

fib: compile
	$(VSIM) -do run_gui.do cpu_tb -g testname="fibonacci"

mem_test: compile
	$(VSIM) -do run_gui.do cpu_tb -g testname="memory_test"

compile: clean
	rm -rf ./work

	$(VLIB) ./work
	$(VMAP) work ./work

	$(VLOG) $(HW)/opcode_pkg.sv
	$(VLOG) $(HW)/alu.sv
	$(VLOG) $(HW)/decoder.sv
	$(VLOG) $(HW)/branch_ctrl.sv
	$(VLOG) $(HW)/memory_ctrl.sv
	$(VLOG) $(HW)/ssram.sv
	$(VLOG) $(HW)/riscv_rv32i.sv
	$(VLOG) $(HW)/cpu_design.sv
	$(VLOG) $(TB)/cpu_tb.sv

CRUFT  = transcript
CRUFT += *.wlf
CRUFT += work
CRUFT += modelsim.ini

clean:
	rm -rf $(CRUFT)
