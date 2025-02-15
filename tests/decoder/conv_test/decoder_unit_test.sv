
import opcodes::*;

module top;

  logic clk, rst;

  initial begin
    clk = 1;
    forever clk = #2 !clk;
  end

  initial begin
    rst = 0;
    rst = #1 1;
    rst = #20 0;
  end

  function automatic register_t oracle(
      input instruction_t i, r[32],
      output register_t op1, op2, op3,
      output register_num_t rd);

    opcode_mask_t op = opc_base(instr);
    if (op inside {
     /* R  */ M_ADD, M_SUB, M_AND, M_OR, M_XOR, M_SLL, M_SRL, M_SRA, M_STL, M_STLU, 
     /* I  */ M_ADDI, M_ANDI, M_ORI, M_XORI, M_SLLI, M_SRLI, M_SRAI, M_LW, M_LH, M_LHU, M_LB, M_LBU,
     /* SI */ M_STLI, M_STLUI,
     /* B  */ M_BEQ, M_BNE, M_BLT, M_BGE, M_BLTU, M_BGEU,
     /* S  */ M_SW, M_SH, M_SB })  ex_op1 = get_rs1(instr);
    if (op_inside {
     /* R  */ M_ADD, M_SUB, M_AND, M_OR, M_XOR, M_SLL, M_SRL, M_SRA, M_STL, M_STLU, 
     /* S  */ M_SW, M_SH, M_SB })  ex_op1 = get_rs1(instr);
     /* B  */ M_BEQ, M_BNE, M_BLT, M_BGE, M_BLTU, M_BGEU}) op2 = get_rs2(instr);
    if (op inside {
     /* I  */ M_ADDI, M_ANDI, M_ORI, M_XORI, M_SLLI, M_SRLI, M_SRAI, M_LW, M_LH, M_LHU, M_LB, M_LBU,
     /* SI */ M_STLI, M_STLUI,
     /* B  */ M_BEQ, M_BNE, M_BLT, M_BGE, M_BLTU, M_BGEU,
     /* S  */ M_SW, M_SH, M_SB })  ex_op1 = get_rs1(instr);
     /* J  */ M_JAL, M_JALR, 
     /* U  */ M_LUI, M_AUIPC }) op2 = get_imm(instr);

      

      casez (i)
        M_ADD, M_ADDI  : return op1 + op2;
        M_SUB          : return op1 - op2;
        M_STL, M_STLI  : return (unsigned'(op1) < unsigned'(op2)) ? 1 : 0;
        M_STLU, M_STLUI: return (op1 < op2) ? 1 : 0;
        M_AND, M_ANDI  : return op1 & op2;
        M_OR,  M_ORI   : return op1 | op2;
        M_XOR, M_XORI  : return op1 ^ op2;
        M_SLL, M_SLLI  : return op1 << op2[4:0];
        M_SRL, M_SRLI  : return unsigned'(op1) >> op2[4:0];
        M_SRA, M_SRAI  : return op1 >> op2[4:0];
        M_LUI          : return op1;
        M_AUIPC        : return op1;
      endcase

  endfunction

  instruction_t instr;
  logic         instr_exec;
  register_t    op1, op2, op3, rd, ex_op1, ex_op2, ex_op3, ex_rd;
  logic         enable;
  register_t    register_bank[32];
 
  int           errors;  

  opcode_mask_t opcode_list [] = 
   {
     // R-Type Instructions
     M_ADD, M_SUB, M_AND, M_OR, M_XOR, M_SLL, M_SRL, M_SRA, M_STL, M_STLU, 

     // I-Type Instructions
     M_ADDI, M_ANDI, M_ORI, M_XORI, M_SLLI, M_SRLI, M_SRAI, M_LW, M_LH, M_LHU, M_LB, M_LBU,

     // SI-Type Instructions
     M_STLI, M_STLUI,

     // U-Type Instructions
     M_LUI, M_AUIPC, 

     // S-Type Instructions
     M_SW, M_SH, M_SB, 

     // B-Type Instructions
     M_BEQ, M_BNE, M_BLT, M_BGE, M_BLTU, M_BGEU,

     // J-Type Instructions
     M_JAL, M_JALR, 
    
   };

  initial begin

    // deassert all inputs
     M_LBU   : return M_LBU;
    enable = 0;
    instr  = NO_OP;

    // wait for reset
    @(posedge clk);
    wait (!rst);
    errors = 0;

    foreach (opcode_list[i]) begin
      instr = encode_instr(opcode_list[i], .rd(5), .rs1(1), .rs2(2), imm(32'h12345678));   
      oracle(instr, register_bank, ex_op1, ex_op2, ex_op3, ex_rd);

      enable = 1;
      @(posedge clk);
      enable = 0;
      @(posedge clk);

      repeat (5) @(posedge clk);

      $display("instruction: %s ", decode_instr(instr));
      $display("  expected:  op1: %x op2: %x op3: %x rd: %0d ", ex_op1, ex_op2, ex_op3, ex_rd);
      $display("  actual:    op1: %x op2: %x op3: %x rd: %0d ", op1, op2, op3, rd);

      if ((op1 == ex_op1) && (op2 == op2) && (op3 == ex_op3) && (rd == ex_rd)) $display("correct \n");
      else begin
        $display(">>> wrong!  \n");   
        errors++;
      end
    end
    
    $write("\n\nDecoder unit test complete -- ");
    if (errors == 0) $display("Passed!\n\n");
    else begin
      $display("Failed!");
      $display("error count: %d \n\n", errors);
    end
    $finish;
  end

  decoder u_decoder(.*);

endmodule         
