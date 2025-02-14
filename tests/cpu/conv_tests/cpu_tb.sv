import opcodes::*;

module cpu_tb;

  parameter clock_period = 4;

  logic clk, rst, halted;

  initial begin
    clk = 1;
    forever clk = #(clock_period/2) !clk;
  end

  initial begin
    rst = 0;
    rst = #(clock_period/2) 1;
    rst = #(clock_period*10) 0;
  end

  cpu_design u_cpu_design(
    .clk    (clk),
    .rst    (rst),
    .halted (halted)
  );

  initial begin
    u_cpu_design.u_code_memory.memory[0] = encode_instr(M_ADDI, .rd(1), .rs1(0), .imm(1));
    u_cpu_design.u_code_memory.memory[1] = encode_instr(M_ADDI, .rd(2), .rs1(0), .imm(2));
    u_cpu_design.u_code_memory.memory[2] = encode_instr(M_ADD,  .rd(3), .rs1(1), .rs2(2));
    u_cpu_design.u_code_memory.memory[3] = EBREAK;
  end

  always @(posedge clk) if (halted) begin
    $display("\n\nTest finished ");
    $display("Final register state: ");
    foreach (u_cpu_design.u_cpu.register_bank[i]) begin
      $display("x%0d = %x ", i, u_cpu_design.u_cpu.register_bank[i]);
    end
    $finish;
  end

endmodule
