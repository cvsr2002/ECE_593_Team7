import opcodes::*;

module cpu_core (
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] instruction,
    output logic [31:0] pc
);
   

    logic [31:0] pc_next;
    logic [31:0] ret_addr;
    logic [31:0] read_data1, read_data2;
    logic [31:0] alu_result;
    logic [2:0]  state;
    logic reg_write_en;
    logic [4:0]  rd;
    logic [31:0] write_data;
    logic alu_enable;
    logic branch_enable;
	logic EXECUTE;
	logic WRITEBACK;

    instruction_t decoded_instr;

    // State Machine
    fsm state_machine (
        .clk(clk),
        .rst(rst),
        .instr(decoded_instr),
        .state(state)
    );

    // Program Counter (PC)
    always_ff @(posedge clk or posedge rst)
	begin
        if (rst)
            pc <= 32'h0000_0000;
        else 
            pc <= pc_next;  // Update PC
    end

    // Instruction Decoder
    decoder decoder (
        .instr(instruction),
        .rs1(decoded_instr.r.rs1),
        .rs2(decoded_instr.r.rs2),
        .rd(rd),
        .imm(write_data)
    );

    // Register File
    register_file reg_file (
        .clk(clk),
        .rst(rst),
        .reg_write_en(reg_write_en),
        .rs1(decoded_instr.r.rs1),
        .rs2(decoded_instr.r.rs2),
        .rd(rd),
        .write_data(write_data),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // ALU
    risc_v_alu alu (
        .enable(alu_enable),
        .instr(decoded_instr),
        .pc(pc),
        .alu_result(alu_result),
        .zero_flag()
    );

    // Branch Controller
    branch_controller branch_ctrl (
        .clk(clk),
        .rst(rst),
        .instr(decoded_instr),
        .op1(read_data1),
        .op2(read_data2),
        .op3(write_data),
        .pc(pc),
        .enable(branch_enable),
        .step(1'b1),  // Always step
        .pc_out(pc_next),
        .ret_addr(ret_addr)
    );

    // Control signals
    assign reg_write_en = (state == WRITEBACK);
    assign alu_enable = (state == EXECUTE);
    assign branch_enable = (state == EXECUTE);
    assign rd = decoded_instr.r.rd;
    assign write_data = alu_result;

endmodule