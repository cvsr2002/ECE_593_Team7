module register_file (
    input  logic        clk,
    input  logic        rst,
    input  logic        reg_write_en,
    input  logic [4:0]  rs1,
    input  logic [4:0]  rs2,
    input  logic [4:0]  rd,
    input  logic [31:0] write_data,
    output logic [31:0] read_data1,
    output logic [31:0] read_data2
);
    logic [31:0] registers [31:0];  // 32 registers

    always_ff @(posedge clk or posedge rst)
	begin
        if (rst) 
		begin
            for (int i = 0; i < 32; i++) 
			begin
                registers[i] <= 32'h0000_0000; 
            end
        end 
		else if (reg_write_en && rd != 0)
		begin
            registers[rd] <= write_data;  // Write to register (except x0)
        end
    end

    assign read_data1 = registers[rs1];  // Read from rs1
    assign read_data2 = registers[rs2];  // Read from rs2
endmodule