import opcodes::*;

module risc_v_alu(
    input logic enable,
    input wire instruction_t instr,
    input logic [31:0] pc,  // Program Counter for AUIPC
    output logic [31:0] alu_result,
    output logic zero_flag
);

    always_comb begin
        alu_result = 32'h0;
        if (enable) begin
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
                M_LUI  : alu_result = {instr.u.imm, 12'b0};  // LUI: Load Upper Immediate
                M_AUIPC: alu_result = pc + {instr.u.imm, 12'b0};  // AUIPC: Add Upper Immediate to PC
                default: alu_result = 32'hDEADBEEF; // Invalid opcode
            endcase
        end

        zero_flag = (alu_result == 32'h0);

        // Assert to check if the ALU result is valid
        assert (alu_result != 32'hDEADBEEF)
        else $error("Invalid ALU operation detected for instruction: %h", instr);
    end

endmodule