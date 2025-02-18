package pkg;

import opcodes::*;
class transaction;
	rand instruction_t instr;
	rand register_t op1,op2,op3;
	logic enable; 
    register_t pc_out, ret_addr;
	
	constraint op_c {
		instr inside {[0:10]};
		op1 inside {[0:31]};
		op2 inside {[0:31]};
		op3 inside {[0:31]};
  }
  
	function void display();
        $display("instr=%0d,op1=%0d,op2=%0d,op3=%0d,enable=%0d", instr, op1, op2, op3,enable);
    endfunction
	
endclass
endpackage