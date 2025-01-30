
import opcodes::*;

module memory_ctrl (
   input logic          clk, rst,

   input wire instruction_t  instr,
   input register_t     op1, op2, op3, pc,
   input logic          enable,
   output register_t    result,
   output logic         result_valid,

   output logic [31:0]  address,
   output logic         read_enable,
   input  logic [31:0]  read_data,
   input  logic         read_ack,
   output logic         write_enable,
   output logic [3:0]   write_byte_enable,
   output logic [31:0]  write_data,
   input  logic         write_ack);

   typedef enum logic[2:0] { IDLE, ADDR_PHASE, DATA_PHASE, DONE } state_t;

   typedef logic unsigned [15:0]  unsigned_short;
   typedef logic signed   [15:0]  signed_short;
   typedef logic unsigned  [7:0]  unsigned_byte;
   typedef logic signed    [7:0]  signed_byte; 

   state_t state, next_state;
   logic read_op, write_op;
   logic read_instr, write_instr;
   logic sign_ex;
   logic [1:0] offset;
   logic [2:0] size;
   register_t wdata;

   always @(posedge clk) 
     if (rst) next_state <= IDLE;
     else state <= next_state;

   always_comb begin
     case (state) 
       IDLE       : if (enable) next_state = ADDR_PHASE;
       ADDR_PHASE : next_state = DATA_PHASE;
       DATA_PHASE : if ((read_op & read_ack) || (!read_op & write_ack)) next_state = DONE;
       DONE       : next_state = IDLE;
     endcase
   end

   always_ff @(posedge clk) begin
     if (rst) result <= '0;
     else if ((state == DATA_PHASE) & (read_op & read_ack)) begin 
       if (sign_ex) begin
         if (size == 4) result <= read_data;
         if (size == 2) result <= signed_short'((read_data >> (8 * offset)) & 32'h0000FFFF);
         if (size == 1) result <= signed_byte'((read_data >> (8 * offset)) & 32'h000000FF);
       end else begin
         if (size == 4) result <= read_data;
         if (size == 2) result <= unsigned_short'((read_data >> (8 * offset)) & 32'h0000FFFF);
         if (size == 1) result <= unsigned_byte'((read_data >> (8 * offset)) & 32'h000000FF);
       end
     end
   end

   assign result_valid = (read_op & read_ack) || (write_op & write_ack);
   assign read_enable = (read_op & (state == ADDR_PHASE));
   assign write_enable = (write_op & (state == ADDR_PHASE));
   assign write_byte_enable = (!write_op) ? '0 :
                              (size == 4) ? 4'hF :
                              (size == 2) ? 4'h3 << offset :
                              (size == 1) ? 4'h1 << offset : '0;


   assign write_data = (!write_op) ? '0 :
                       (size == 4) ? wdata :
                       (size == 2) ? (wdata & 32'h0000FFFF) << (offset * 8) :
                       (size == 1) ? (wdata & 32'h000000FF) << (offset * 8) : '0;

   always_ff @(posedge clk) begin
     if (rst) begin 
       size <= '0;
       offset <= '0;
       address <= '0;
       read_op <= 0;
       write_op <= 0;
       wdata <= '0;
     end else begin
       if (state == DONE) begin
         size <= '0;
         offset <= '0;
         address <= '0;
         read_op <= 0;
         write_op <= 0;
         wdata <= '0;
       end
       if (enable) begin
         address <= op1 + op2 & 32'hFFFFFFFC;
         offset  <= op1 + op2 & 32'h00000003;
         write_data <= op3;
         casez (instr) 
           M_LW   : begin  size <= 4;  read_op  <= 1; sign_ex <= 0; end
           M_LH   : begin  size <= 2;  read_op  <= 1; sign_ex <= 1; end
           M_LHU  : begin  size <= 2;  read_op  <= 1; sign_ex <= 0; end
           M_LB   : begin  size <= 1;  read_op  <= 1; sign_ex <= 1; end
           M_LBU  : begin  size <= 1;  read_op  <= 1; sign_ex <= 0; end
           M_SW   : begin  size <= 4;  write_op <= 1; sign_ex <= 0; end
           M_SH   : begin  size <= 2;  write_op <= 1; sign_ex <= 0; end
           M_SB   : begin  size <= 1;  write_op <= 1; sign_ex <= 0; end
         endcase
       end
     end
   end
   
endmodule
