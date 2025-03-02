
class opcode_env_c extends uvm_env;
  `uvm_component_utils(opcode_env_c);

  execute_scoreboard_c execute_scoreboard;
  cpu_tracer_c         cpu_tracer;
  opcode_agent_c       opcode_agent;

  function new(string name="opcode_env_c", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    execute_scoreboard = execute_scoreboard_c::type_id::create("execute_scoreboard", this);
    cpu_tracer         = cpu_tracer_c::type_id::create("cpu_tracer", this);
    opcode_agent       = opcode_agent_c::type_id::create("opcode_agent", this);

  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // connect cpu monitor with tracer and scoreboard
    opcode_agent.riscv_monitor.cpu_exec_port.connect(execute_scoreboard.rtl_exec_port);
    opcode_agent.riscv_monitor.cpu_exec_port.connect(cpu_tracer.rtl_trace_port);

  endfunction

endclass

