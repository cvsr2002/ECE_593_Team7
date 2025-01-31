
import opcodes::*;

module branch_unit (
   input logic          clk, rst,

   input wire instruction_t  instr,
   input register_t     op1, op2, op3,
   input logic          enable,        // enable on every execute stage
   output register_t    pc_out,
   output register_t    ret_addr);

   register_t pc;

   assign pc_out = pc;

   always_ff @(posedge clk) begin
     if (rst) pc <= '0;
     else begin
       if (enable) begin
         ret_addr <= pc + 4;
         casez (instr) 
           M_JAL  : pc <= op1;
           M_JALR : pc <= op1 + op2;
           M_BEQ  : pc <= (op1 == op2) ? pc + op3 : pc + 4;
           M_BNE  : pc <= (op1 != op2) ? pc + op3 : pc + 4;
           M_BLT  : pc <= (op1 < op2)  ? pc + op3 : pc + 4;
           M_BLTU : pc <= (unsigned'(op1) < unsigned'(op2)) ? pc + op3 : pc + 4;
           M_BGE  : pc <= (op1 >= op2) ? pc + op3 : pc + 4;
           M_BGEU : pc <= (unsigned'(op1) >= unsigned'(op2)) ? pc + op3 : pc + 4;
           default : pc <= pc + 4;
         endcase
       end
     end
   end
   
endmodule
