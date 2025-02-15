
// monitor for inputs to memory controller

class monitor_in_c;
  virtual decoder_if_i  vif;
  mailbox           mon_in2scb;
  stimulus_c        inputs;

  logic             chatty = 0;

  function new(virtual decoder_if_i i, mailbox m);
    vif         = i;
    mon_in2scb  = m;
  endfunction

  task main;
    if (chatty) $display("monitor_in: started %t ", $time);
    forever begin

      @(posedge vif.clk);

      #1; // ensure signals settled

      if (vif.enable) begin

        inputs         = new();

        inputs.instr   = vif.instr;
        foreach (inputs.register_bank[i]) inputs.register_bank[i] = vif.register_bank[i];

        mon_in2scb.put(inputs);

        if (chatty) begin
          $write("time: %t stimulus sent: %s ", 
                    $time, decode_instr(vif.instr));
        end
      end
    end
  endtask
endclass

// monitor for output from decoder 

class monitor_out_c;
  virtual decoder_if_i   vif;
  mailbox            mon_out2scb;
  results_c          rx;
  register_t         write_data;

  logic              chatty = 0;

  function new(virtual decoder_if_i i, mailbox m);
    vif           = i;
    mon_out2scb   = m;
  endfunction

  task main;
    logic enable_delayed;

    if (chatty) $display("monitor_out: started");

    forever begin

      @(posedge vif.clk);

      #1; // ensure signals settle

      // capture memory reads
      if (enable_delayed) begin

        rx = new();

        rx.op1 = vif.op1;
        rx.op2 = vif.op2;
        rx.op3 = vif.op3;
        rx.rd  = vif.rd;

        mon_out2scb.put(rx);

      end

      enable_delayed = vif.enable;

      // send on break instruction with null data when received
      // signals end of test
      if (vif.instr == EBREAK) begin

        rx = new();

        rx.op1 = '0;
        rx.op2 = '0;
        rx.op3 = '0;
        rx.rd  = '0;

        mon_out2scb.put(rx);

      end
    end
  endtask

endclass

