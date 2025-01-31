import opcodes::*;

module decoder (
    input  wire instruction_t instr,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [4:0]  rd,
    output logic [31:0] imm
);

    // Extract fields from the instruction
    assign rs1 = get_rs1(instr);  // Source register 1
    assign rs2 = get_rs2(instr);  // Source register 2
    assign rd  = get_rd(instr);   // Destination register
    assign imm = get_imm(instr);  // Immediate value

    // Assert to check if the instruction is valid
    always_comb 
	begin
        assert (is_r_type(instr) || is_i_type(instr) || is_s_type(instr) || 
                is_b_type(instr) || is_u_type(instr) || is_j_type(instr))
        else $error("Invalid instruction detected: %h", instr);
    end

endmodule