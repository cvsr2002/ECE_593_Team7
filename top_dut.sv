import opcodes::*;
module dut(
    
    input logic clk, rst
);

    // Internal Signals
    logic [31:0] reg_file [31:0];
    logic [31:0] code_memory ['h10000]; // Instruction Memory
    instruction_t instr;
    logic [31:0] alu_result;
	logic enable;
    logic zero_flag;
    logic [2:0] state;
    logic [31:0] pc_in, pc_out;
	logic Enable;
	logic FETCH;
	logic WRITEBACK;

    // Program Counter Instance
    /program_counter PC (
        .clk(clk),
        .rst(rst),
        .pc_enable(1'b1),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

    // Register File Instance
    register_file RF (
        .clk(clk),
        .rst(rst),
        .reg_write(1'b1),
        .rs1(instr.r.rs1),
        .rs2(instr.r.rs2),
        .rd(instr.r.rd),
        .write_data(alu_result),
        .read_data1(instr.r.rs1),
        .read_data2(instr.r.rs2)
    );

    // ALU Instance
    risc_v_alu ALU (.enable(Enable),
        .instr(instr),
        .alu_result(alu_result),
        .zero_flag(zero_flag)
    );

    // FSM Instance
    fsm FSM (
        .clk(clk),
        .rst(rst),
        .instr(instr),
        .state(state)
    );
	
	//Decoder
	decoder Decoder(.instr(instr),.Enable(Enable),.rs1(rs1), .rs2(rs2), .rd(rd),.imm(imm));

    // Instruction Fetch
    always_ff @(posedge clk) begin
        if (state == FETCH) begin
            instr <= code_memory[pc_out >> 2];
            pc_in <= pc_out + 4;
        end
    end
  
    
    // Writeback: Store the ALU result into register
    always_ff @(posedge clk) begin
        if (state == WRITEBACK)
            reg_file[instr.r.rd] <= alu_result;
    end

endmodule
