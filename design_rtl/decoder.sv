import opcodes::*;

module decoder (
  input logic clk, rst,

  input wire instruction_t instr,
  input logic enable,
  input wire register_t register_bank[32],

  output register_t op1, op2, op3, 
  output register_num_t rd);

  instruction_t instr_reg;
  register_t rs1, rs2, imm;

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
        rd  <= get_rd(instr);
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
          op2 = register_bank[rs2];
          op3 = imm;
        end
      is_b_type(instr_reg): begin
          op1 = register_bank[rs1];
          op2 = register_bank[rs2];
          op3 = imm;
        end
      is_u_type(instr_reg): op1 = imm; 
      is_j_type(instr_reg): op1 = imm; 
      (instr_reg == EBREAK) : op1 = '0;
      //  default: $error("invalid opcode in decoder: %x ", instr);
    endcase
  end 

endmodule

