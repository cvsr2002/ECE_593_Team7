
import opcodes::*;

module alu (
    input logic clk,
    input logic rst,
    input instruction_t instr,      // Current instruction
    input register_t op1,           // Operand 1 (from register/immediate)
    input register_t op2,           // Operand 2 (from register/immediate)
    input register_t pc,            // Program Counter (for AUIPC)
    input logic enable,             // enable signal
    output register_t result        // ALU result
);

always_ff @(posedge clk) begin
    if (rst) result <= 0;
    else if (enable) begin
        casez (instr)
            // Arithmetic Operations
            M_ADD, M_ADDI  : result <= op1 + op2;
            M_SUB          : result <= op1 - op2;
            
            // Comparisons
            M_STL, M_STLI  : result <= ($unsigned(op1) < $unsigned(op2)) ? 1 : 0;
            M_STLU, M_STLUI: result <= (op1 < op2) ? 1 : 0;
            
            // Logical Operations
            M_AND, M_ANDI  : result <= op1 & op2;
            M_OR, M_ORI    : result <= op1 | op2;
            M_XOR, M_XORI  : result <= op1 ^ op2;
            
            // Shifts
            M_SLL, M_SLLI  : result <= op1 << op2[4:0];
            M_SRL, M_SRLI  : result <= $unsigned(op1) >> op2[4:0];
            M_SRA, M_SRAI  : result <= op1 >> op2[4:0];
            
            // Upper Immediate
            M_LUI          : result <= op1;               // op1 = immediate
            M_AUIPC        : result <= op1 + pc;          // op1 = immediate
          
            default: assert (0) else $error("Invalid ALU operation detected for instruction: %h", instr);
            endcase
        end
end
endmodule
 
