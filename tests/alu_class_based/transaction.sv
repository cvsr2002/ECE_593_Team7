
package trans;
import opcodes::*;


class transaction;
  rand register_t op1;
  rand register_t op2;
  rand var instruction_t instr;
  rand int op_index;
   register_t result;
   logic instr_exec;
   logic enable;
  
  constraint op_c {
    instr inside {[0:7]};
    op1 inside {[0:31]};
    op2 inside {[0:31]};
  }
   
  function void print ();
    $display("inputs op1 = %0d | op2 = %0d |instr = %0d|instr_exec = %0d|enable = %0d| result = %0h",op1,op2,instr,instr_exec,enable,result);
  endfunction

endclass

endpackage