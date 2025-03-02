
import opcodes::*;

module alu #(
    parameter trace = 0
  ) (
    input logic clk,
    input logic rst,
    input var instruction_t instr,  // Current instruction
    input register_t op1,           // Operand 1 (from register/immediate)
    input register_t op2,           // Operand 2 (from register/immediate)
    input logic enable,             // enable signal
    output logic instr_exec,        // opcode was executed
    output register_t result        // ALU result
);

always_ff @(posedge clk) begin
    if (rst) result <= 0;
    else if (enable) begin
   
`ifndef SYNTHESIS
        // trace of code execution
        if (trace) if (enable && is_alu_op(instr))
            $display("%t executed: %s ", $time, decode_instr(instr));
`endif 
        instr_exec <= 1;

        casez (instr)
            // Arithmetic Operations
            M_ADD, M_ADDI  : result <= op1 + op2;
            M_SUB          : result <= op1 - op2;
            
            // Comparisons
            M_STLU, M_STLUI: result <= ($unsigned(op1) < $unsigned(op2)) ? 1 : 0;
            M_STL, M_STLI  : result <=   ($signed(op1) <   $signed(op2)) ? 1 : 0;
            
            // Logical Operations
            M_AND, M_ANDI  : result <= op1 & op2;
            M_OR, M_ORI    : result <= op1 | op2;
            M_XOR, M_XORI  : result <= op1 ^ op2;
            
            // Shifts
            M_SLL, M_SLLI  : result <= op1 << op2[4:0];
            M_SRL, M_SRLI  : result <= $unsigned(op1) >>  op2[4:0];
            M_SRA, M_SRAI  : result <=   $signed(op1) >>> op2[4:0];
            
            // Upper Immediate
            M_LUI          : result <= op1;               // op1 = immediate
            M_AUIPC        : result <= op1 + op2;         // op1 = immediate
          
            default: instr_exec <= 0;   // silently ignore bad opcodes, hold prior output

            endcase
        end else instr_exec <= 0;
end
endmodule
 
