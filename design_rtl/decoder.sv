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
  register_t rs1, rs2, imm;

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

endmodule

