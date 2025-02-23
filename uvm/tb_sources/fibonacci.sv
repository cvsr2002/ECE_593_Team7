
import iss_pkg::*;

class iss_c;
  virtual interface cpu_state_i cpu_state_if;

  function new();
    uvm_config_db#(virtual interface cpu_state_i)::get(null, "*", "cpu_state_if", cpu_state_if);
  endfunction

  function void load_program(int size);
    int i;
    for (i=0; i<size; i++) begin
     iss_set_instruction(i, cpu_state_if.code_memory[i]);
    end
  endfunction

  function void reset();
    iss_reset();
  endfunction

  function void step();
    iss_step();
  endfunction

  function void run();
    iss_enable_trace();
    iss_run();
  endfunction

  function void check_state(int size);
    int i;
    int errors = 0;
    string message;

    for (i=1; i<32; i++) begin
      if (iss_get_register(i) != cpu_state_if.register_bank[i]) begin
        message = $sformatf("Register error: hdl register[%0d] = %x iss register[%0d] = %x ",
                             i, cpu_state_if.register_bank[i], i, iss_get_register(i));
        `uvm_error("SCOREBOARD", message);
        errors++;
      end
    end

    for (i=0; i<size; i++) begin
      if (!$isunknown(cpu_state_if.data_memory[i])) begin
        if (iss_get_memory_word(i<<2) != cpu_state_if.data_memory[i]) begin 
          message = $sformatf("Memory error: hdl data_memory[%0d] = %x iss memory[%0d] = %x ",
                               i, cpu_state_if.data_memory[i], i, iss_get_memory_word(i<<2));
          `uvm_error("SCOREBOARD", message);
          errors++;
        end
      end
    end
    if (errors)   `uvm_error("SCOREBOARD", "Reference ISS comparison failed!");
    if (errors==0) `uvm_info("SCOREBOARD", "Reference ISS comparison passed!", UVM_INFO);
  endfunction
endclass


class fibonacci extends uvm_test;
  `uvm_component_utils(fibonacci)
  int program_size;
  int data_size = 'h10000;

  function void set_instr(int address, instruction_t instr,
       input virtual interface code_memory_i cm_vif); 
    string message;

    message = $sformatf("Load instruction: %x: %x : %-25s ", address, instr, decode_instr(instr)); 
    `uvm_info("LOAD", message, UVM_INFO);

    cm_vif.set(address, instr);
    // top.u_cpu_design.u_code_memory.memory[address] = instr;

  endfunction

  function int load_program(
     input virtual interface code_memory_i cm_vif);
    
   // fiboancci program
   //  computes 12 iterations of a fibbonacci series
   // 
   //        x4 = first term
   //        x5 = second term
   //        x6 = sum
   //        x8 = address 
   //        x9 = interation count
   //        x10: test result
   //
   //     00:   addi x1, x0, 0      // x1 = 0
   //     01:   sw x1, 0(x0)        // store x1 @ 0
   //     02:   sw x1, 4(x0)        // store x1 @ 4
   //     03:   addi x8, x0, 0      // x8 = 0
   //     04:   addi x9, x0, 12     // x9 = 12
   //      loop:
   //     05:   lw x4, 0(x8)        // load x4 @(0+x8)
   //     06:   lw x5, 4(x8)        // load x5 @(4+x8)
   //     07:   add x6, x5, x4      // x6 = a5 + x4
   //     08:   sw x6, 8(x8)        // store x6 @(8+x8)
   //     09:   addi x8, x8, 4      // x8 += 4
   //     10:   ble x8, x9, -20(x0) // if (x8<12) jump loop
   //      done: 
   //     11:   addi x10, x0, 377   // x10 = 377
   //     12:   bne x6, x10, 20     // if (x6 != x10) jump bad
   //      good 
   //     13:   lui x10, 0x600D0    // x10 = 0x600D0000
   //     14:   srli x9, x10, 16    // x9 = x10 >> 16
   //     15:   or x10, x10, x9     // x10 = x10 | x9
   //     16:   break
   //      bad:
   //     18:   lui x10, 0xDEAD0    // x10 = 0xDEAD0000
   //     19:   slri x9, x10, 16    // x9 = x10 >> 16
   //     20:   or x10, x10, x9     // x10 = x10 | x9
   //     21:   break

   // init:
       set_instr(0,  encode_instr(M_ADDI, .rd(1),  .rs1(0), .imm(1)), cm_vif);    // x1 = 1
       set_instr(1,  encode_instr(M_SW,   .rs1(0), .rs2(1), .imm(0)), cm_vif);    // store x1 @0
       set_instr(2,  encode_instr(M_SW,   .rs1(0), .rs2(1), .imm(4)), cm_vif);    // store x1 @4
       set_instr(3,  encode_instr(M_ADDI, .rd(8),  .rs1(0), .imm(0)), cm_vif);    // x8 = 0
       set_instr(4,  encode_instr(M_ADDI, .rd(9),  .rs1(0), .imm(48)), cm_vif);   // x9 = 48
   // loop: 
       set_instr(5,  encode_instr(M_LW,   .rd(4),  .rs1(8), .imm(0)), cm_vif);    // load r4, @(x8)
       set_instr(6,  encode_instr(M_LW,   .rd(5),  .rs1(8), .imm(4)), cm_vif);    // load r5, @(x8)+4
       set_instr(7,  encode_instr(M_ADD,  .rd(6),  .rs1(5), .rs2(4)), cm_vif);    // add x6, x5 + x4
       set_instr(8,  encode_instr(M_SW,   .rs1(8), .rs2(6), .imm(8)), cm_vif);    // store x8 @(x8)+8
       set_instr(9,  encode_instr(M_ADDI, .rd(8),  .rs1(8), .imm(4)), cm_vif);    // add r8, r8 + 4
       set_instr(10, encode_instr(M_BLT,  .rs1(8), .rs2(9), .imm(-20)), cm_vif);  // if x8<x9 jump loop
   // check result
       set_instr(11, encode_instr(M_ADDI, .rd(10), .rs1(0), .imm(377)), cm_vif);  // x10 = 377
       set_instr(12, encode_instr(M_BNE,  .rs1(6), .rs2(10),.imm(5<<2)), cm_vif); // if (x6 != x10) jump BAD
   // good
       set_instr(13, encode_instr(M_LUI,  .rd(10), .imm('h600D0)), cm_vif);       // x10 = 600D0
       set_instr(14, encode_instr(M_SRLI, .rd(9),  .rs1(10), .imm(16)), cm_vif);  // x9 = x10 >> 16 
       set_instr(15, encode_instr(M_OR,   .rd(10), .rs1(10), .rs2(9)), cm_vif);   // x10 = x10 | x9
       set_instr(16, EBREAK, cm_vif);                                             // done
   //bad
       set_instr(17, encode_instr(M_LUI,  .rd(10), .imm('hDEAD0)), cm_vif);       // x10 = DEAD0
       set_instr(18, encode_instr(M_SRLI, .rd(9),  .rs1(10), .imm(16)), cm_vif);  // x9 = x10 >> 16 
       set_instr(19, encode_instr(M_OR,   .rd(10), .rs1(10), .rs2(9)), cm_vif);   // x10 = x10 | x9
       set_instr(20, EBREAK, cm_vif);                                             // done
   // done

    return (20); // size of program
  endfunction

  function new(string name = "riscv_program",uvm_component parent=null);
    super.new(name, parent);
    `uvm_info("FIB", "In the contructor", UVM_INFO);
  endfunction : new

  function virtual interface code_memory_i get_memory_interface();
    virtual interface code_memory_i code_memory_if;
    uvm_config_db#(virtual interface code_memory_i)::get(null, "*", "code_memory_if", code_memory_if);
    return code_memory_if;
  endfunction

  function automatic string print_write(input int address, data, logic [3:0] byte_enable);
    string message;
    case (byte_enable)
      'hf: message = $sformatf(" write @%x = %x ",  address<<2, data);
      'hc: message = $sformatf(" write @%x = %4x ", address<<2, (data >> 16));
      'h3: message = $sformatf(" write @%x = %4x ", address<<2, (data & 'hFFFF));
      'h8: message = $sformatf(" write @%x = %2x ", address<<2, (data >> 24) & 'hFF);
      'h4: message = $sformatf(" write @%x = %2x ", address<<2, (data >> 16) & 'hFF);
      'h2: message = $sformatf(" write @%x = %2x ", address<<2, (data >>  8) & 'hFF);
      'h1: message = $sformatf(" write @%x = %2x ", address<<2, (data >>  0) & 'hFF);
      default: message = $sformatf(" *** illegal write operation ");
    endcase
    return message;
  endfunction

  task cpu_trace;
    virtual interface cpu_trace_i tr_vif;
    string message;

    uvm_config_db#(virtual interface cpu_trace_i)::get(null, "*", "cpu_trace_if", tr_vif);

    forever @(posedge tr_vif.clk) begin
      if (tr_vif.execute) begin
        message = $sformatf("%x: %x : %-25s ", 
            tr_vif.pc, tr_vif.instr, 
            decode_instr(tr_vif.instr)); 
        `uvm_info("CPU_TRACE", message, UVM_INFO);
      end
      if (tr_vif.write_back) begin
        if (tr_vif.rd != 0) begin
          message = $sformatf("x%0d = %x ", 
             tr_vif.rd,
             tr_vif.result);
          `uvm_info("CPU_STATE_CHANGE", message, UVM_INFO);
        end
        if (is_s_type(tr_vif.instr)) begin
          message = print_write(
             tr_vif.address,
             tr_vif.write_data,
             tr_vif.byte_enable);
          `uvm_info("CPU_STATE_CHANGE", message, UVM_INFO)
        end
      end
    end
  endtask

  task configure_phase(uvm_phase phase);
    int i;

    super.configure_phase(phase);
    `uvm_info("FIB", "In the config phase", UVM_INFO);     

  endtask : configure_phase

  function void start_of_simulation_phase(uvm_phase phase);
    virtual interface code_memory_i cm_vif;

    // super.configure_phase(phase); Why? Why? Why????

    `uvm_info("FIB", "In the end_of_simulation_phase", UVM_INFO);

    uvm_config_db#(virtual interface code_memory_i)::get(null, "*", "code_memory_if", cm_vif);

    program_size = load_program(cm_vif);
    fork cpu_trace;
    join_none;
  endfunction
  
  function void end_of_elaboration_phase(uvm_phase phase); // (uvm_phase phase);
    //super.configure_phase();  this inconsistency is inexcuable!
  
    `uvm_info("FIB", "In the end_of_elaboration_phase", UVM_INFO);
  endfunction

  task reset_phase(uvm_phase phase);
    super.configure_phase(phase);

    `uvm_info("FIB", "In the reset_phase ", UVM_INFO);

  endtask

  task run_phase(uvm_phase phase);
    virtual interface cpu_if_i cpu_if;

    super.configure_phase(phase);

    `uvm_info("FIB", "In the run phase", UVM_INFO);     

    // get cpu interface
    uvm_config_db#(virtual interface cpu_if_i)::get(null, "*", "cpu_if", cpu_if);
    
    phase.raise_objection(this);

    @(posedge cpu_if.halted);

    phase.drop_objection(this);
  endtask

  function void extract_phase(uvm_phase phase);
    virtual interface code_memory_i code_memory_if;
    iss_c iss = new();

    super.configure_phase(phase);

    uvm_config_db#(virtual interface code_memory_i)::get(null, "*", "code_memory_if", code_memory_if);
    `uvm_info("FIB", "In the extract phase", UVM_INFO);

    iss.load_program(program_size);
    iss.run();
    iss.check_state(data_size);

  endfunction

endclass : fibonacci

