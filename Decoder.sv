import opcodes::*;
module decoder (
    input instruction_t instr,
    output logic [4:0] rs1, rs2, rd,
    output logic [31:0] imm
);
    assign rs1 = get_rs1(instr);
    assign rs2 = get_rs2(instr);
    assign rd =  get_rd(instr);
    assign imm = get_imm(instr);
endmodule
