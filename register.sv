import opcodes::*;
module register_file(
    
    input  logic clk,
    input  logic rst,
    input  logic reg_write,
    input  register_num_t rs1,
    input  register_num_t rs2,
    input  register_num_t rd,
    input  logic [31:0] write_data,
    output logic [31:0] read_data1,
    output logic [31:0] read_data2
);

    logic [31:0] registers [31:0]; // 32 registers

    assign read_data1 = (rs1 == 5'd0) ? 32'd0 : registers[rs1];
    assign read_data2 = (rs2 == 5'd0) ? 32'd0 : registers[rs2];

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            for (int i = 0; i < 32; i++) registers[i] <= 32'd0;
        else if (reg_write && (rd != 5'd0))
            registers[rd] <= write_data;
    end

endmodule
