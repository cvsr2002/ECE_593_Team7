
// oracle for expected results 
function automatic void oracle(
    input  instruction_t   instr,
    input  register_t      r[32],
    output register_t      ex_op1, ex_op2, ex_op3,
    output register_num_t  ex_rd);

  opcode_mask_t op;

  ex_op1 = '0;
  ex_op2 = '0;
  ex_op3 = '0;
  ex_rd  = '0;

  // do not copy or reuse decode routines (does not really test anything)
  op = opc_base(instr);
  if (op inside {
    /* R  */ M_ADD, M_SUB, M_AND, M_OR, M_XOR, M_SLL, M_SRL, M_SRA, M_STL, M_STLU,
    /* I  */ M_ADDI, M_ANDI, M_ORI, M_XORI, M_SLLI, M_SRLI, M_SRAI, M_LW, M_LH, M_LHU, M_LB, M_LBU, M_JALR,
    /* SI */ M_STLI, M_STLUI,
    /* S  */ M_SW, M_SH, M_SB,
    /* B  */ M_BEQ, M_BNE, M_BLT, M_BGE, M_BLTU, M_BGEU }) ex_op1 = r[get_rs1(instr)];
  if (op inside {
    /* J  */ M_JAL,
    /* U  */ M_LUI, M_AUIPC }) ex_op1 = get_imm(instr);
  if (op inside {
    /* R  */ M_ADD, M_SUB, M_AND, M_OR, M_XOR, M_SLL, M_SRL, M_SRA, M_STL, M_STLU,
    /* S  */ M_SW, M_SH, M_SB,
    /* B  */ M_BEQ, M_BNE, M_BLT, M_BGE, M_BLTU, M_BGEU}) ex_op2 = r[get_rs2(instr)];
  if (op inside {
    /* I  */ M_ADDI, M_ANDI, M_ORI, M_XORI, M_SLLI, M_SRLI, M_SRAI, M_LW, M_LH, M_LHU, M_LB, M_LBU, M_JALR,
    /* SI */ M_STLI, M_STLUI })  ex_op2 = get_imm(instr);
  if (op inside {
    /* B  */ M_BEQ, M_BNE, M_BLT, M_BGE, M_BLTU, M_BGEU,
    /* S  */ M_SW, M_SH, M_SB })  ex_op3 = get_imm(instr);

  if (op inside {
    /* R  */ M_ADD, M_SUB, M_AND, M_OR, M_XOR, M_SLL, M_SRL, M_SRA, M_STL, M_STLU,
    /* I  */ M_ADDI, M_ANDI, M_ORI, M_XORI, M_SLLI, M_SRLI, M_SRAI, M_LW, M_LH, M_LHU, M_LB, M_LBU, M_JALR,
    /* SI */ M_STLI, M_STLUI,
    /* J  */ M_JAL,
    /* U  */ M_LUI, M_AUIPC }) ex_rd = get_rd(instr);
endfunction


// scoreboard class

class scoreboard_c;
  mailbox      mon_in2scb, mon_out2scb;
  stimulus_c   stim;
  results_c    resp;
  results_c    expected_result;
  int          errors;
  int          instruction_count;
  logic        done;

  logic        chatty = 1;
  logic        very_chatty = 0;

  function new(mailbox i, o); 
    mon_in2scb         = i;
    mon_out2scb        = o;
    stim               = new;
    resp               = new;
    errors             = 0;
    instruction_count  = 0;
    done               = 0;
  endfunction
/*
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
*/
  task main(decoder_test_t decoder_test=0);
    register_t ex_op1, ex_op2, ex_op3;
    register_num_t ex_rd;
    logic oops;
    logic chatty = 0;

    forever begin
    
      // get stim and responses
      fork
        mon_in2scb.get(stim);
        mon_out2scb.get(resp);
        //get_stim(stim);
        //get_resp(resp);
      join

      if (stim.instr == EBREAK) begin
        done = 1;
        report_results(decoder_test);
        $display("end of test reached ");
        break;
      end

      // compute expected results 
      oracle(stim.instr, stim.register_bank, ex_op1, ex_op2, ex_op3, ex_rd);

      oops = ((resp.op1 != ex_op1) || 
              (resp.op2 != ex_op2) || 
              (resp.op3 != ex_op3) || 
              (resp.rd != ex_rd)) ? 1 : 0;

      if (oops || chatty) begin
        $display("instruction: %s ", decode_instr(stim.instr));
        $display("  expected:  op1: %x op2: %x op3: %x rd: %0d ", ex_op1, ex_op2, ex_op3, ex_rd);
        $display("  actual:    op1: %x op2: %x op3: %x rd: %0d ", resp.op1, resp.op2, resp.op3, resp.rd);
      end
      if (oops) begin
        $display(">>> wrong!  \n");
        errors++;
      end else begin
        if (chatty) $display(">>> correct! \n");
      end

      instruction_count++;
    end
  endtask

  task report_results(decoder_test_t decoder_test);
    $display("==================================================");
    $display("||                                              ||");
    $display("|| Decoder Object Oriented Test Case Complete   ||");
    $display("|| Test Name: %-20s              ||", decoder_test.name);
    $display("||                                              ||");
    $display("|| Tests Run: %7d                           ||", instruction_count);
    $display("|| Errors:    %7d                           ||", errors);  
    $display("||                                              ||");
    $display("||  >>> Test %-6s! <<<                        ||", (errors==0) ? "Passed" : "Failed"); 
    $display("||                                              ||");
    $display("==================================================");
  endtask

endclass

