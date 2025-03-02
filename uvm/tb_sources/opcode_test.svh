
class opcode_test_c extends uvm_test;
  `uvm_component_utils(opcode_test_c)

  opcode_env_c opcode_env;
  opcode_seq_c opcode_seq;

  function new(string name = "execute_test",uvm_component parent=null);
    super.new(name, parent);
    `uvm_info(get_type_name(), "In the constructor", UVM_DEBUG);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "In the build phase", UVM_DEBUG);
    super.build_phase(phase);

    opcode_env = opcode_env_c::type_id::create("env_execute_test", this);
    opcode_seq = opcode_seq_c::type_id::create("opcode_seq", this);

  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    uvm_top.print_topology();
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info(get_type_name(), "Test run phase", UVM_DEBUG);
    phase.raise_objection(this);

    repeat(100000) begin
      opcode_seq = opcode_seq_c::type_id::create("opcode_seq");
      opcode_seq.start(opcode_env.opcode_agent.opcode_sequencer);
      #4;  // how long to wait??
    end

    phase.drop_objection(this);
  endtask

endclass

