

class env_execute_test_c extends uvm_env;
  `uvm_component_utils(env_execute_test_c);

  execute_scoreboard_c execute_scoreboard;
  cpu_tracer_c         cpu_tracer;
  execute_agent_c      execute_agent;

  function new(string name="env_execute_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    execute_scoreboard = execute_scoreboard_c::type_id::create("execute_scoreboard", this);
    cpu_tracer         = cpu_tracer_c::type_id::create("cpu_tracer", this);
    execute_agent      = execute_agent_c::type_id::create("execute_agent", this);

  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // connect cpu monitor with tracer and scoreboard
    execute_agent.riscv_monitor.cpu_exec_port.connect(execute_scoreboard.rtl_exec_port);
    execute_agent.riscv_monitor.cpu_exec_port.connect(cpu_tracer.rtl_trace_port);

  endfunction

endclass
