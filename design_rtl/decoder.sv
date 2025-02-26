import opcodes::*;

module decoder #(
   parameter random_errors= 0
 )(
  input logic clk, rst,

  input wire instruction_t instr,
  input logic enable,
  input wire register_t register_bank[32],

  output register_t op1, op2, op3, 
  output register_num_t rd);

  instruction_t instr_reg;
  register_num_t rs1, rs2;
  register_t imm;

  function automatic register_t induce_errors(register_t data);
    if (random_errors) begin
      if ($urandom_range(1,10)==7)   // 10% of the time flip a bit at random
        return data ^ register_t'(32'h1 << $urandom_range(0,31));
    end
    return(data);
  endfunction

  string debug_opcode;

  assign debug_opcode = decode_instr(instr); 

  always_ff @(posedge clk) begin
    if (rst) begin
      rs1 <= '0;
      rs2 <= '0;
      imm <= '0;
      rd <= '0;
      instr_reg <= '0;
    end else begin 
      if (enable) begin
        rs1 <= get_rs1(instr);
        rs2 <= get_rs2(instr);
        imm <= get_imm(instr);
`ifdef SYNTHESIS
        rd  <= get_rd(instr);
`else
        rd  <= register_num_t'(induce_errors(get_rd(instr)));
`endif
        instr_reg <= instr;
      end
    end
  end

  always_comb begin
    op1 = '0;
    op2 = '0;
    op3 = '0;
    case (1)
      is_r_type(instr_reg): begin
          op1 = register_bank[rs1];
          op2 = register_bank[rs2];
        end
      is_i_type(instr_reg): begin
          op1 = register_bank[rs1];
          op2 = imm;
        end
      is_si_type(instr_reg): begin
          op1 = register_bank[rs1];
          op2 = imm;
        end
      is_s_type(instr_reg): begin
          op1 = register_bank[rs1]; 
          op2 = imm;                
          op3 = register_bank[rs2]; 
        end
      is_b_type(instr_reg): begin
          op1 = register_bank[rs1];
          op2 = register_bank[rs2];
          op3 = imm;
        end
      is_u_type(instr_reg): begin
          op1 = imm; 
        end
      is_j_type(instr_reg): begin
          op1 = imm; 
        end
      (instr_reg == EBREAK) : op1 = '0;
      //  default: $error("invalid opcode in decoder: %x ", instr);
    endcase
`ifndef SYNTHESIS
    op1 = induce_errors(op1);
    op2 = induce_errors(op2);
    op3 = induce_errors(op3);
`endif
  end 


   opcode_mask_t opcode;
   assign opcode = opc_base(instr);

   covergroup opcodes_cg @(posedge clk);
     coverpoint opcode {
        bins instr[] = {
             M_ADD, M_SUB, M_AND, M_OR, M_XOR, M_SLL, M_SRA, M_STL, M_STLU, 
             M_ADDI, M_ANDI, M_ORI,  M_XORI, M_SLLI, M_SRAI, M_STL, M_STLU, M_LW, M_LH, M_LHU, M_LB, M_LBU, M_JALR,
             M_STLI, M_STLUI,
             M_LUI, M_AUIPC,
             M_SW, M_SH, M_SB,
             M_BEQ, M_BNE, M_BLT, M_BGE, M_BLTU, M_BGEU,
             M_JAL };
     }
   endgroup

   covergroup regs_cg @(posedge clk);
     coverpoint opcode {
       bins r_type = { M_ADD, M_SUB, M_AND, M_OR, M_XOR, M_SLL, M_SRA, M_STL, M_STLU };
       bins i_type = { M_ADDI, M_ANDI, M_ORI,  M_XORI, M_SLLI, M_SRAI, M_STL, M_STLU, M_LW, M_LH, M_LHU, M_LB, M_LBU, M_JALR };
       bins si_type = { M_STLI, M_STLUI };
       bins u_type = { M_LUI, M_AUIPC };
       bins s_type = { M_SW, M_SH, M_SB };
       bins b_type = { M_BEQ, M_BNE, M_BLT, M_BGE, M_BLTU, M_BGEU };
       bins j_type = { M_JAL };
     }
     cross opcode, rs1, rs2, rd;
   endgroup

   covergroup one_operand_cg @(posedge clk);
     coverpoint opcode {
       bins one_operand = { M_JAL, M_LUI, M_AUIPC };
     }
     coverpoint op1 {
       bins negative = {[$:-1]};
       bins zero     = { 0 };
       bins positive = {[1:$]};
     }
     cross opcode, op1;
   endgroup

   covergroup two_operand_cg @(posedge clk);
     coverpoint opcode {
       bins two_operand = {
              M_ADD, M_SUB, M_AND, M_OR, M_XOR, M_SLL, M_SRA, M_STL, M_STLU,
              M_ADDI, M_ANDI, M_ORI,  M_XORI, M_SLLI, M_SRAI, M_STL, M_STLU, M_LW, M_LH, M_LHU, M_LB, M_LBU, M_JALR,
              M_STLI, M_STLUI };
     }
     coverpoint op1 {
       bins negative = {[$:-1]};
       bins zero     = { 0 };
       bins positive = {[1:$]};
     }
     coverpoint op2 {
       bins negative = {[$:-1]};
       bins zero     = { 0 };
       bins positive = {[1:$]};
     }
     cross opcode, op1, op2;
   endgroup

   covergroup three_operand_cg @(posedge clk);
     coverpoint opcode {
       bins three_operand = { M_SW, M_SH, M_SB, M_BEQ, M_BNE, M_BLT, M_BGE, M_BLTU, M_BGEU };
     }
     coverpoint op1 {
       bins negative = {[$:-1]};
       bins zero     = { 0 };
       bins positive = {[1:$]};
     }
     coverpoint op2 {
       bins negative = {[$:-1]};
       bins zero     = { 0 };
       bins positive = {[1:$]};
     }
     coverpoint op3 {
       bins negative = {[$:-1]};
       bins zero     = { 0 };
       bins positive = {[1:$]};
     }
     cross opcode, op1, op2, op3;
   endgroup

   opcodes_cg        opcodes_inst       = new();
   regs_cg           regs_inst          = new();
   one_operand_cg    one_operand_inst   = new();
   two_operand_cg    two_operand_inst   = new();
   three_operand_cg  three_operand_inst = new();

endmodule

