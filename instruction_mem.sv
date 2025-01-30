module InstructionMemory#(parameter n = 16)(input logic [2*n-1:0] Address, input logic Enable, 
                         output logic [2*n-1:0] Data);
    logic [2*n-1:0] instruction_memory [0:2**n-1]; //64 k * 32 bits size memory  
    initial begin
        $readmemh("PATH", instruction_memory);  // Put the absolute path of the machine code that you want to execute. In our case "code.mem".
    end
    assign Data = instruction_memory[addr[31:2]];
endmodule