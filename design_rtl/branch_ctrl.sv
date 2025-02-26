
import opcodes::*;

module branch_unit (
   input logic          clk, rst,

   input wire instruction_t  instr,
   input register_t     op1, op2, op3,
   input logic          enable,        
   output register_t    pc_out,
   output register_t    ret_addr);

   register_t pc;

   assign pc_out = pc;

   always_ff @(posedge clk) begin
     if (rst) pc <= '0;
     else begin
       if (enable) begin
         ret_addr <= pc + 4;
	//	 $display("[DUT] Enable=%0b, instr=%0d, op1=%0d, op2=%0d, op3=%0d", enable, instr, op1, op2, op3);
         casez (instr) 
		   // Standard RISC-V Jump Instructions
           M_JAL  : pc <= op1;
           M_JALR : pc <= op1 + op2;
		   
		   // Standard RISC-V Branch Instructions
           M_BEQ  : pc <= (op1 == op2) ? pc + op3 : pc + 4;
           M_BNE  : pc <= (op1 != op2) ? pc + op3 : pc + 4;
           M_BLT  : pc <= (op1 < op2)  ? pc + op3 : pc + 4;
           M_BLTU : pc <= (unsigned'(op1) < unsigned'(op2)) ? pc + op3 : pc + 4;
           M_BGE  : pc <= (op1 >= op2) ? pc + op3 : pc + 4;
           M_BGEU : pc <= (unsigned'(op1) >= unsigned'(op2)) ? pc + op3 : pc + 4;
           default : pc <= pc + 4;
         endcase
	 //	 $display("[DUT] PC Updated: pc=%0h, ret_addr=%0h", pc, ret_addr);
       end
     end
   end
    opcode_mask_t opcode;
 

   //--------------------------------------------------------------------------
   // Covergroup for branch instructions and resulting PC (pc_out)
   //--------------------------------------------------------------------------
   covergroup branch_cg @(posedge clk);
     
     coverpoint opcode {
       bins instr[] = {M_JAL,M_JALR,M_BEQ,M_BNE,M_BLT,M_BLTU,M_BGE,M_BGEU};
     }
     // Cover the output PC (pc_out).
     coverpoint pc_out {
       bins zero = {0};
       bins positive = { [1:$] };
       bins negative = { [$:-1] };
     }
     // Cross coverage 
     cross opcode, pc_out;
   endgroup

   //--------------------------------------------------------------------------
   // Covergroup for the computed return address (ret_addr)
   //--------------------------------------------------------------------------
   covergroup ret_cg @(posedge clk);
     coverpoint ret_addr {
       bins zero = {0};
       bins positive = { [1:$] };
       bins negative = { [$:-1] };
     }
   endgroup

   // Instantiate the covergroups
   branch_cg branch_cg_inst = new();
   ret_cg ret_cg_inst = new();

endmodule
