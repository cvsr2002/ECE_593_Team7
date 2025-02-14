import opcodes::*;

interface mem_if_i(
    input logic clk, rst);
  instruction_t   instr;
  register_t      op1, op2, op3, result;
  logic           enable;
  logic           result_valid;
  logic [31:0]    address;
  logic [31:0]    read_data;
  logic           read_enable;
  logic [31:0]    write_data;
  logic [3:0]     byte_enables;
  logic           write_enable;
endinterface

class shadow_memory_c;
  parameter memory_size = 'h4000;
  typedef logic [3:0][7:0]  bytes_t;
  typedef logic [1:0][15:0] half_word_t;
  typedef logic [31:0]      word_t;
  typedef union packed {
    bytes_t bytes;
    half_word_t halfs;
    word_t word;
  } memory_t;
  memory_t memory [memory_size];

  /*
  function void new();
    int i;
    for (i=0;i<size;i++) memory[i] = 0;
  endfunction
  */
  function register_t read(input int address, size, input logic is_signed = 0);
    register_t data;
    logic [1:0] offset;
    case (size) 
      4 : begin
            address = address >> 2;
            data = memory[address].word;
            return data;
          end
      2 : begin 
            offset = (address & 2) ? 1 : 0;
            address = address >> 2;
            data = memory[address].halfs[offset];
            if (is_signed) data = signed'(data[15:0]);
            return data;
          end
      1 : begin
            offset = address & 3;
            address = address >> 2;
            data = memory[address].bytes[offset];
            if (is_signed) data = signed'(data[7:0]);
            return data;
          end
      default: $fatal("Verification engineer error: Invalid size in memory access!");
    endcase
  endfunction

  function void write(input int address, size, register_t data);
    logic [1:0] offset;        
    case (size) 
      4 : begin
            address = address >> 2;
            memory[address].word = data;
          end
      2 : begin 
            offset = (address & 2) ? 1 : 0;
            address = address >> 2;
            memory[address].halfs[offset] = data >> (offset * 16);
          end
      1 : begin
            offset = address & 3;
            address = address >> 2;
            memory[address].bytes[offset] = data >> (offset * 8);
          end
      default: $fatal("Verification engineer error: Invalid size in memory access!");
    endcase
  endfunction
endclass

function void mem_ops(
   input instruction_t instr,
   input register_t op1, op2,
   output register_t address, offset,
   output logic [2:0] size,
   output logic read_op, sign_ex);
 
   address = (op1 + op2) >> 2;
   offset  = (op1 + op2) & 32'h00000003;
   casez (instr)
     M_LW   : begin  size = 4;  read_op = 1; sign_ex = 0; end
     M_LH   : begin  size = 2;  read_op = 1; sign_ex = 1; end
     M_LHU  : begin  size = 2;  read_op = 1; sign_ex = 0; end
     M_LB   : begin  size = 1;  read_op = 1; sign_ex = 1; end
     M_LBU  : begin  size = 1;  read_op = 1; sign_ex = 0; end
     M_SW   : begin  size = 4;  read_op = 0; sign_ex = 0; end
     M_SH   : begin  size = 2;  read_op = 0; sign_ex = 0; end
     M_SB   : begin  size = 1;  read_op = 0; sign_ex = 0; end
     EBREAK : begin  size = 1;  read_op = 1; sign_ex = 1; end
     default: $error("Verification Engineer Error, bad input to mem_ops");
   endcase
endfunction

typedef enum logic {RX_READ, RX_WRITE} rx_rw_t;

class results_c;
  rx_rw_t    rw;
  register_t result;
endclass;

class stimulus_c;
  instruction_t instr;
  register_t    op1, op2, op3;
endclass

class rand_testcase_c;
  rand logic signedness;
  rand logic[2:0] size;
  rand register_t base, offset, w_data, imm;
  rand register_num_t rs1, rs2, rd;
  opcode_mask_t rd_opcode, wr_opcode;
  instruction_t rd_instr,  wr_instr;
  logic [3:0] byte_enables;
  logic chatty = 1;
  int i;
  
  constraint c0 { size inside {1, 2, 4};}
  constraint c2 { base inside {[0:'h8000]}; }
  constraint c3 { offset inside {[0:'h8000]}; }
  constraint c4 { base + offset inside { [0:'hFFFF]}; }  // note: this does not work

  function void post_randomize(); 

    // align on words for word access
    if (size == 4) begin
      offset = offset & 32'hFFFFFFFC;
      base   = base   & 32'hFFFFFFFC;
      imm    = imm    & 32'hFFFFFFFC;
    end

    // align on half-word for half-word access
    if (size == 2) begin
      offset = offset & 32'hFFFFFFFE;
      base   = base   & 32'hFFFFFFFE;
      imm    = imm    & 32'hFFFFFFFE;
    end

    // set byte_enables based on access size and offset
    casex (size)
     4 : byte_enables = 4'b1111;
     2 : byte_enables = 4'b0011 << ((base + offset) & 2);
     1 : byte_enables = 4'b0001 << ((base + offset) & 3);
    endcase

    case (size)
     4: wr_opcode = M_SW;
     2: wr_opcode = M_SH;
     1: wr_opcode = M_SB;
    endcase;

    case (size)
     4: rd_opcode = M_LW;
     2: case (signedness) 
         0: rd_opcode = M_LHU;
         1: rd_opcode = M_LH;
        endcase
     1: case (signedness)
         0: rd_opcode = M_LBU;
         1: rd_opcode = M_LB;
        endcase
    endcase

    wr_instr = encode_instr(wr_opcode, .rd(rd), .rs1(rs1), .rs2(rs2), .imm(imm));
    rd_instr = encode_instr(rd_opcode, .rd(rd), .rs1(rs1), .rs2(rs2), .imm(imm));

    if (chatty) begin
      $display("New instruction created: %s ", decode_instr(wr_instr));
      $display("                         %s ", decode_instr(rd_instr));
      $display("base = %x offset = %x address = %x  ", base, offset, base + offset);
    end

  endfunction
endclass

function results_c oracle(
    input instruction_t instr,
    input register_t op1, op2, op3);
  
  register_t address, data;
  logic [2:0] size, offset;
  logic read_op, write_op, sign_ex;
  static shadow_memory_c memory = new();
  static results_c ret = new();

  mem_ops(instr, op1, op2, address, offset, size, read_op, sign_ex);

  address = op1 + op2;
  if (read_op) data = memory.read(address, size, sign_ex);
  else begin 
    data = (size==4) ? op3 : 
           (size==2) ? ((op3 & 32'h0000FFFF) << (offset * 8)) :
           (size==1) ? ((op3 & 32'h000000FF) << (offset * 8)) : 0;
    memory.write(address, size, data);
  end

  ret.result = data;
  ret.rw = (read_op) ? RX_READ : RX_WRITE;
  return ret;
endfunction  

class monitor_in_c;
  virtual mem_if_i  vif;
  mailbox           mon_in2scb;
  stimulus_c        inputs;

  logic             chatty = 0;

  function new(virtual mem_if_i i, mailbox m);
    vif         = i;
    mon_in2scb  = m;
    inputs      = new();
  endfunction

  task main;
    if (chatty) $display("monitor_in: started %t ", $time);
    forever begin
      @(posedge vif.clk);
      #1; // ensure signals settled
      if (vif.enable) begin
        inputs.instr   = vif.instr;
        inputs.op1     = vif.op1;
        inputs.op2     = vif.op2;
        inputs.op3     = vif.op3;
        mon_in2scb.put(inputs);
        if (chatty) begin
          $write("time: %t stimulus sent: %s ", 
                    $time, decode_instr(vif.instr));
        end
        @(posedge vif.clk);
      end
    end
  endtask
endclass

class monitor_out_c;
  virtual mem_if_i   vif;
  mailbox            mon_out2scb;
  results_c          rx;
  register_t         write_data;

  logic              chatty = 0;

  function new(virtual mem_if_i i, mailbox m);
    vif           = i;
    mon_out2scb   = m;
  endfunction

  task main;
    if (chatty) $display("monitor_out: started");

    forever begin
      @(posedge vif.clk);
      #1;
      if (vif.result_valid) begin
        rx = new();
        rx.rw = RX_READ;
        rx.result = vif.result;
        mon_out2scb.put(rx);
      end
      if (vif.write_enable) begin
        case (vif.byte_enables) 
          4'b1111: write_data = (vif.write_data >>  0) & 32'hFFFFFFFF;
          4'b0011: write_data = (vif.write_data >>  0) & 32'h0000FFFF;
          4'b1100: write_data = (vif.write_data >> 16) & 32'h0000FFFF;
          4'b0001: write_data = (vif.write_data >>  0) & 32'h000000FF;
          4'b0010: write_data = (vif.write_data >>  8) & 32'h000000FF;
          4'b0100: write_data = (vif.write_data >> 16) & 32'h000000FF;
          4'b1000: write_data = (vif.write_data >> 24) & 32'h000000FF;
          default: $error("%t Invalid write byte enable pattern %x (%d) ", $time, vif.byte_enables, vif.write_enable);
        endcase
        rx = new();
        rx.rw = RX_WRITE;
        rx.result = vif.write_data;
        mon_out2scb.put(rx);
      end
      if (vif.instr == EBREAK) begin
        rx = new();
        rx.rw = RX_READ;
        rx.result = '0;
        mon_out2scb.put(rx);
      end
    end
  endtask

endclass

class scoreboard_c;
  mailbox      mon_in2scb, mon_out2scb;
  stimulus_c   stim;
  results_c    resp;
  results_c    expected_result;
  int          errors;
  int          instruction_count;
  string       testname;
  logic        done;

  logic        chatty = 1;
  logic        very_chatty = 0;

  function new(mailbox i, o, string tn="Memory Test");
    mon_in2scb         = i;
    mon_out2scb        = o;
    stim               = new;
    resp               = new;
    errors             = 0;
    instruction_count  = 0;
    done               = 0;
    testname           = tn;
  endfunction

  task get_stim(ref stimulus_c stim);
    mon_in2scb.get(stim);
    if (very_chatty) begin
      $display("time: %t Stimulus received: op1=%x op2=%x op3=%x", $time, stim.op1, stim.op2, stim.op3);
    end
  endtask;

  task get_resp(ref results_c resp);
    mon_out2scb.get(resp);
    if (very_chatty) begin
      $display("time: %t Response received: %s response: %x ", 
                  $time, (resp.rw == RX_READ) ? "Read" : "Write", resp.result);
    end
  endtask;

  task main;
    forever begin
    
      // get stim and responses
      fork
        get_stim(stim);
        get_resp(resp);
      join

      if (stim.instr == EBREAK) begin
        done = 1;
        report_results;
        $display("end of test reached ");
        break;
      end

      // compute expected results 
      expected_result = oracle(stim.instr, stim.op1, stim.op2, stim.op3);

      // record errors
      if ((expected_result.rw     != resp.rw) ||
          (expected_result.result != resp.result)) begin
        errors++;
        $display("Error: %-28s op1=%x op2=%x op3=%x result=%x exp_result=%x rw=%0d ex_rw=%0d ", 
                    decode_instr(stim.instr), stim.op1, stim.op2, stim.op3, resp.result, expected_result.result, resp.rw, expected_result.rw);
      end else if (chatty) begin
        $display("Success: %-28s op1=%x op2=%x result=%x ", 
                    decode_instr(stim.instr), stim.op1, stim.op2, resp.result);
      end
      instruction_count++;
      #1;
    end
  endtask

  task report_results;
    $display("==================================================");
    $display("||                                              ||");
    $display("|| Mem_Ctrl Object Oriented Test Case Complete  ||");
    $display("|| Test Name: %-20s              ||", testname);
    $display("||                                              ||");
    $display("|| Tests Run: %7d                           ||", instruction_count);
    $display("|| Errors:    %7d                           ||", errors);  
    $display("||                                              ||");
    $display("||  >>> Test %-6s! <<<                        ||", (errors==0) ? "Passed" : "Failed"); 
    $display("||                                              ||");
    $display("==================================================");
  endtask

endclass

class random_generator_c;
  rand rand_testcase_c testcase;
  stimulus_c       inputs;
  mailbox#(stimulus_c) gen2drv;
  int              instruction_count;
  logic            done = 0;

  logic            chatty = 0;

  function new(mailbox#(stimulus_c) mb, int num_tests);
    if (chatty) $display("generator: started");

    gen2drv           = mb;
    instruction_count = num_tests; 
    testcase          = new;
  endfunction

  task main;
    int i = 0;

    if (chatty) $display("generator: in main");

    // generate random testcase
    // perform a write, then a read 
    // from the same location

    repeat(instruction_count) begin
      
      assert(testcase.randomize());

      inputs = new();

      inputs.instr        = testcase.wr_instr;
      inputs.op1          = testcase.base;
      inputs.op2          = testcase.offset;
      inputs.op3          = testcase.w_data;

      gen2drv.put(inputs);

      inputs = new();

      inputs.instr        = testcase.rd_instr;
      inputs.op1          = testcase.base;
      inputs.op2          = testcase.offset;
      inputs.op3          = '0;

      gen2drv.put(inputs);

    end

    done = 1;

    if (chatty) $display("generator: finished");
  endtask
endclass

class generator_c;
  stimulus_c       inputs;
  mailbox#(stimulus_c) gen2drv;
  int              instruction_count;
  logic            done = 0;

  logic            chatty = 0;

  function new(mailbox#(stimulus_c) mb, int num_tests);
    if (chatty) $display("generator: started");

    gen2drv           = mb;
    instruction_count = num_tests; 
  endfunction

  task memory_loop(
      input instruction_t instr,
      input int base, size, count);

    stimulus_c inputs;
    int i;

    for (i=0; i<count; i++) begin
      inputs = new();

      inputs.instr = instr;
      inputs.op1 = '0;
      inputs.op2 = base + i * size;
      inputs.op3 = i;

      gen2drv.put(inputs);
    end
  endtask

  task done_stim;
    stimulus_c inputs = new();

    inputs.instr = EBREAK;
    inputs.op1   = '0;
    inputs.op2   = '0;
    inputs.op3   = '0;
    
    gen2drv.put(inputs);
  endtask

  task main;
    int i = 0;

    if (chatty) $display("generator: in main");

    // store bytes, then read as bytes and signed bytes
    memory_loop(encode_instr(M_SB, 1, 2, 3, 4), 0, 1, 256);
    memory_loop(encode_instr(M_LB, 1, 2, 3, 4), 0, 1, 256);
    memory_loop(encode_instr(M_LBU, 1, 2, 3, 4), 0, 1, 256);

    // store halfword and then read back as unsigned and signed
    memory_loop(encode_instr(M_SH, 1, 2, 3, 4), 32'h1000, 2, 256);
    memory_loop(encode_instr(M_LH, 1, 2, 3, 4), 32'h1000, 2, 256);
    memory_loop(encode_instr(M_LHU, 1, 2, 3, 4), 32'h1000, 2, 256);

    // store word then read back
    memory_loop(encode_instr(M_SW, 1, 2, 3, 4), 32'h2000, 4, 256);
    memory_loop(encode_instr(M_LW, 1, 2, 3, 4), 32'h2000, 4, 256);
 
    done_stim;

    if (chatty) $display("generator: finished");
  endtask

endclass

class driver_c;
  int               instruction_count;
  virtual mem_if_i  vif;
  mailbox#(stimulus_c)  gen2drv;
  int               pause = 5; // delay between instructions sent to DUT

  logic             chatty  = 0;

  function new(virtual mem_if_i i, mailbox#(stimulus_c) m);
    if (chatty) $display("driver: in constructor for driver");

    instruction_count = 0;
    gen2drv           = m;
    vif               = i;
  endfunction

  task reset;
    if (chatty) $display("driver: in reset");

    // deassert/initialize all signals
    vif.op1          = '0;
    vif.op2          = '0;
    vif.op3          = '0;
    vif.instr        = NO_OP;
    vif.enable       = 0;
    vif.byte_enables = 0;

    // wait for reset 
    wait(vif.rst);
    wait(!vif.rst);

    if (chatty) $display("driver: reset completed");
  endtask

  task main;
    if (chatty) $display("driver: started");

    @(posedge vif.clk); // sync to rising edge of clock
    forever begin

      stimulus_c inputs = new();
      instruction_count++;

      // get inputs from generator
      gen2drv.get(inputs);

      // drive inputs
      vif.instr       = inputs.instr;
      vif.op1         = inputs.op1;
      vif.op2         = inputs.op2;
      vif.op3         = inputs.op3;

      // toggle enable
      vif.enable = 1;
      @(posedge vif.clk);
      vif.enable = 0;

      // wait a bit
      repeat (pause) @(posedge vif.clk);
    end

    if (chatty) $display("driver: finished");
  endtask : main

endclass

class environment_c;
  generator_c      gen;
  driver_c         drv;
  monitor_in_c     mon_in;
  monitor_out_c    mon_out;
  scoreboard_c     scb;

  mailbox#(stimulus_c)  gen2drv;
  mailbox          mon_in2scb;
  mailbox          mon_out2scb;

  virtual mem_if_i vif;
  int              num_tests;

  logic chatty = 0;

  function new(virtual mem_if_i m, int n=100);

    if (chatty) $display("environment: starting, running %d tests ", n);
    num_tests    = n;

    // make new mailboxes

    gen2drv      = new();
    mon_in2scb   = new();
    mon_out2scb  = new();

    // connect virtual interface
    vif          = m;

    // make new classes for agent and scoreboard
    drv          = new(vif, gen2drv);
    gen          = new(gen2drv, num_tests);
    mon_in       = new(vif, mon_in2scb);
    mon_out      = new(vif, mon_out2scb);
    scb          = new(mon_in2scb, mon_out2scb);

  endfunction

  task pre_test;
    drv.reset();
  endtask

  task test;
    if (chatty) $display("starting test ");
    fork
      gen.main();
      mon_in.main();   // forever thread
      mon_out.main();  // forever thread
      drv.main();      // forever thread
      scb.main();      // forever thread
    join_any
    if (chatty) $display("test done ");
    wait (scb.done);
  endtask

  task post_test;
    // perform any clean-up here
  endtask

  task run;
    pre_test();
    test();
    post_test();
    $finish;
  endtask

endclass

module top;

   parameter CLOCK_PERIOD = 4;
   parameter BROKEN       = 0;

   logic clk, rst;

   // DUT signals

   instruction_t instr;
   register_t    op1, op2, op3;
   register_t    result;
   logic         result_valid;

   logic [31:0]  address;
   logic         read_enable;
   logic [31:0]  read_data;
   logic         write_enable;
   logic [3:0]   byte_enables;
   logic [31:0]  write_data;

   initial begin
     clk = 1;
     forever clk = #(CLOCK_PERIOD/2) !clk;
   end

   initial begin
     rst = 0;
     rst = #(CLOCK_PERIOD/2) 1;
     rst = #(CLOCK_PERIOD*10) 0;
   end

   mem_if_i mem_if(clk, rst); 

   environment_c env = new(mem_if);

   initial env.run();

   assign instr                = mem_if.instr;
   assign op1                  = mem_if.op1;
   assign op2                  = mem_if.op2;
   assign op3                  = mem_if.op3;
   assign enable               = mem_if.enable;
   assign mem_if.result        = result;
   assign mem_if.result_valid  = result_valid;

   assign mem_if.address       = address;
   assign mem_if.read_enable   = read_enable;
   assign mem_if.read_data     = read_data;
   assign mem_if.write_enable  = write_enable;
   assign mem_if.write_data    = write_data;
   assign mem_if.byte_enables  = byte_enables;

   always @(posedge clk) if (instr == EBREAK) $display("End of test signaled");
   memory_ctrl #(.random_errors(BROKEN))
    DUT(
     .clk                (clk),
     .rst                (rst),

     .instr              (instr),
     .op1                (op1),
     .op2                (op2),
     .op3                (op3),
     .enable             (enable),
     .result             (result),
     .result_valid       (result_valid),

     .address            (address),
     .read_enable        (read_enable),
     .read_data          (read_data),
     .read_ack           (1'b1),
     .write_enable       (write_enable),
     .write_byte_enable  (byte_enables),

     .write_data         (write_data),
     .write_ack          (1'b1));

  ssram MEM(
     .clk                (clk),
     .rst                (rst),

     .address            (address),
     .read_enable        (read_enable),
     .read_data          (read_data),
     .write_enable       (write_enable),
     .write_byte_enable  (byte_enables),
     .write_data         (write_data));

endmodule
