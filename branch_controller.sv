import opcodes::*;

module branch_controller (
    input  logic          clk,
    input  logic          rst,
    input  wire instruction_t  instr,
    input  logic [31:0]   op1, op2, op3,  
    input  logic [31:0]   pc,            
    input  logic enable,        
    input  logic step,           
    output logic [31:0]  pc_out,        
    output logic [31:0]  ret_addr      
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) 
            pc_out <= 32'h0000_0000; 
         else begin			
            if (step) begin
                if (enable) begin
                    ret_addr <= pc + 4;  
                    casez (instr)
                        M_JAL  : pc_out <= op1;  
                        M_JALR : pc_out <= op1 + op2;  
                        M_BEQ  : pc_out <= (op1 == op2) ? pc + op3 : pc + 4;  
                        M_BNE  : pc_out <= (op1 != op2) ? pc + op3 : pc + 4; 
                        M_BLT  : pc_out <= ($signed(op1) < $signed(op2)) ? pc + op3 : pc + 4;  
                        M_BLTU : pc_out <= (op1 < op2) ? pc + op3 : pc + 4; 
                        M_BGE  : pc_out <= ($signed(op1) >= $signed(op2)) ? pc + op3 : pc + 4;  
                        M_BGEU : pc_out <= (op1 >= op2) ? pc + op3 : pc + 4;  
                        default: pc_out <= pc + 4;  
                    endcase
                end else begin
                    pc_out <= pc + 4;  
                end
            end
        end
    end

endmodule