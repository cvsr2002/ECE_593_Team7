import opcodes::*;
module fsm(
    
    input  logic clk,
    input  logic rst,
    input  instruction_t instr,
    output logic [2:0] state
);

    typedef enum logic [2:0] { FETCH, DECODE, EXECUTE, WRITEBACK, BREAK } state_t;
    state_t current_state, next_state;

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= FETCH;
        else
            current_state <= next_state;
    end

    always_comb begin
        next_state = current_state;
        case (current_state)
            FETCH:    next_state = DECODE;
            DECODE:   next_state = EXECUTE;
            EXECUTE:  next_state = WRITEBACK;
            WRITEBACK: next_state = (instr == HALT) ? BREAK : FETCH;
            BREAK:    next_state = BREAK;
        endcase
    end

    assign state = current_state;
endmodule
