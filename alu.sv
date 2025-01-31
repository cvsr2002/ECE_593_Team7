import opcodes::*;

module risc_v_alu(
    input  logic        enable,
    input  instruction_t instr,
    input  logic [31:0] operand1,  // First operand (from decoder)
    input  logic [31:0] operand2,  // Second operand (from decoder)
    input  logic [31:0] pc,        // Program Counter for AUIPC
    output logic [31:0] alu_result
);

    always_comb begin
        alu_result = 32'h0;
        if (enable) begin
            casez (instr)
                M_ADD ,M_ADDI  : alu_result = operand1 + operand2;
                M_SUB          : alu_result = operand1 - operand2;
                M_AND,M_ANDI   : alu_result = operand1 & operand2;
                M_OR, M_ORI    : alu_result = operand1 | operand2;
                M_XOR,M_XORI   : alu_result = operand1 ^ operand2;
                M_SLL,M_SLLI   : alu_result = operand1 << operand2[4:0];
                M_SRL,M_SRLI   : alu_result = operand1 >> operand2[4:0];
                M_SRA,M_SRAI   : alu_result = $signed(operand1) >>> operand2[4:0];
                M_STL,M_STLI   : alu_result = ($signed(operand1) < $signed(operand2)) ? 1 : 0;
                M_STLU,M_STLUI : alu_result = (operand1 < operand2) ? 1 : 0;
                M_LUI          : alu_result = operand1;  // LUI: Load Upper Immediate
                M_AUIPC        : alu_result = pc + operand1;  // AUIPC: Add Upper Immediate to PC
                default: assert (alu_result != 32'hDEADBEEF)
                             else $error("Invalid ALU operation detected for instruction: %h", instr);
            endcase
        end
end
endmodule
 
