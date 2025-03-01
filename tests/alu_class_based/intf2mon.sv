
import trans::*;

class alu_mon;
  virtual intf vif;
  mailbox mon2scb;
  transaction tx ;
  
  function new(virtual intf vif, mailbox mon2scb);
    this.vif = vif;
    this.mon2scb = mon2scb;
  endfunction

  task main();
    repeat (10) begin
    tx = new();
      //@(posedge vif.clk);
	  $display("[mon] INF: Received instr=%0d, op1=%0d, op2=%0d, enable = %0d, result=%0d, instr_exec=%0d", tx.instr, tx.op1, tx.op2, tx.enable, tx.result, tx.instr_exec);
	    tx.instr = vif.instr;
        tx.op1 = vif.op1;
        tx.op2 = vif.op2;
		tx.enable = vif.enable;
		#1;
		tx.result = vif.result;
		tx.instr_exec = vif.instr_exec;
		
        mon2scb.put(tx);
		$display("[mon] Received instr=%0d, op1=%0d, op2=%0d, enable = %0d", tx.instr, tx.op1, tx.op2, tx.enable);
    end
    $display("monitor finished");
  endtask
endclass