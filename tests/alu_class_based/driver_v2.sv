import trans::*;

class driver;
    virtual intf vif;
    mailbox gen2driv;
    transaction tx;
	
	function new (virtual intf vif, mailbox gen2driv);
    this.vif = vif;
    this.gen2driv = gen2driv;
  endfunction

task reset();
    wait(intf_vi.rst);
    $display("[DRV] Reset started");
    intf_vi.op1 <= 0;
    intf_vi.op2 <= 0;
    intf_vi.enable <= 0;
    intf_vi.instr <= 0;
    wait(!intf_vi.rst);
    $display ("[DRV] Reset ended");
  endtask
  
  
   task main();
  $display("[DRV] Driver started");

  forever begin
   $display("[DRV] Waiting for transaction...");
    gen2driv.get(tx);
   
	 // Get transaction from generator
    $display("[DRV] Received :instr=%0d, op1=%0d, op2=%0d, enable = %0d", tx.instr, tx.op1, tx.op2, tx.enable);
   

	// @(posedge vif.clk); 

    vif.instr = tx.instr;
    vif.op1 = tx.op1;
    vif.op2 = tx.op2;
    vif.enable = 1; // Enable signal set
 $display("[DRV] sent: instr=%0d, op1=%0d, op2=%0d, enable = %0d", tx.instr, tx.op1, tx.op2, tx.enable);
   
  end
  
endtask

endclass