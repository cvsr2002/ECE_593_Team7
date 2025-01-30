
import opcodes::*;

module branch_unit (
   input logic          clk, rst,

   input wire instruction_t  instr,
   input register_t     op1, op2, op3, pc,
   input logic          enable,
   input logic          step,
   output register_t    pc_out,
   output register_t    ret_addr);

   always @(posedge clk) begin
     if (rst) pc_out <= '0;
     else begin
       if (step) begin
         if (enable) begin
           ret_addr <= pc + 4;
           casez (instr) 
             M_JAL  : pc_out <= op1;
             M_JALR : pc_out <= op1 + op2;
             M_BEQ  : pc_out <= (op1 == op2) ? pc + op3 : pc + 4;
             M_BNE  : pc_out <= (op1 != op2) ? pc + op3 : pc + 4;
             M_BLT  : pc_out <= (op1 < op2)  ? pc + op3 : pc + 4;
             M_BLTU : pc_out <= (unsigned'(op1) < unsigned'(op2)) ? pc + op3 : pc + 4;
             M_BGE  : pc_out <= (op1 >= op2) ? pc + op3 : pc + 4;
             M_BGEU : pc_out <= (unsigned'(op1) >= unsigned'(op2)) ? pc + op3 : pc + 4;
           endcase
         end else begin
           pc_out <= pc + 4;
         end
       end
     end
   end
   
endmodule
