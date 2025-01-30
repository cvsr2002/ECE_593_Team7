import opcodes::*;
module risc_v_alu(
    input logic enable,
    input  instruction_t instr,
    output logic [31:0] alu_result,
    output logic zero_flag
);

    always_comb begin
        alu_result = 32'h0;
        if(enable)		
        casez (instr)
            M_ADD  : alu_result = instr.r.rs1 + instr.r.rs2;
            M_SUB  : alu_result = instr.r.rs1 - instr.r.rs2;
            M_AND  : alu_result = instr.r.rs1 & instr.r.rs2;
            M_OR   : alu_result = instr.r.rs1 | instr.r.rs2;
            M_XOR  : alu_result = instr.r.rs1 ^ instr.r.rs2;
            M_SLL  : alu_result = instr.r.rs1 << instr.r.rs2[4:0];
            M_SRL  : alu_result = instr.r.rs1 >> instr.r.rs2[4:0];
            M_SRA  : alu_result = $signed(instr.r.rs1) >>> instr.r.rs2[4:0];
            M_SLT  : alu_result = ($signed(instr.r.rs1) < $signed(instr.r.rs2)) ? 1 : 0;
            M_SLTU : alu_result = (instr.r.rs1 < instr.r.rs2) ? 1 : 0;
            default: alu_result = 32'hDEADBEEF; // Invalid opcode
        endcase

        zero_flag = (alu_result == 32'h0);
    end

endmodule