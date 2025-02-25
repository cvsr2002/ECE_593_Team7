
//`include "transaction_v2.sv"
import trans_v1::*;

class driver;
    virtual intf vif;
    mailbox gen2driv;
    transaction tx;
	
	function new (virtual intf vif, mailbox gen2driv);
    this.vif = vif;
    this.gen2driv = gen2driv;
  endfunction

task reset();
    wait(vif.rst);
    $display("[DRV] Reset started");
    vif.op1 <= 0;
    vif.op2 <= 0;
    vif.enable <= 0;
    vif.instr <= 0;
    wait(!vif.rst);
    $display ("[DRV] Reset ended");
  endtask
  
  
  task main();
  $display("[DRV] Driver started");

  forever begin
    $display("[DRV] Waiting for transaction...");
    gen2driv.get(tx);

    $display("[DRV] Received: instr=%s, op1=%0d, op2=%0d, enable=%0d", tx.instr, tx.op1, tx.op2, tx.enable);

    @(posedge vif.clk); // Ensure values are applied on clock edge

    vif.instr <= tx.instr;
    vif.op1 <= tx.op1;
    vif.op2 <= tx.op2;
    vif.enable <= tx.enable; // Enable signal set

       @(posedge vif.clk); 
        vif.enable = 0;  
    $display("[DRV] Sent: instr=%s, op1=%0d, op2=%0d, enable=%0d", vif.instr, vif.op1, vif.op2, vif.enable);
  end
endtask

endclass