module program_counter #(parameter ADDR_WIDTH = 32)(
    input  logic clk,
    input  logic rst,
    input  logic pc_enable,
    input  logic [ADDR_WIDTH-1:0] pc_in,
    output logic [ADDR_WIDTH-1:0] pc_out
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            pc_out <= 32'h0;  // Reset PC
        else if (pc_enable)
            pc_out <= pc_in;  // Load new value
    end

endmodule
