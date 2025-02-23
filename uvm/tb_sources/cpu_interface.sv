
import opcodes::*;

// interface for memory controller

interface cpu_if_i(input logic clk, rst);
  logic [31:0]    instruction_address;
  logic           instruction_enable;
  instruction_t   instr;
  logic           enable;
  logic           result_valid;
  logic [31:0]    address;
  logic [31:0]    read_data;
  logic           read_enable;
  logic [31:0]    write_data;
  logic [3:0]     byte_enables;
  logic           write_enable;
  logic           halted;
  int             instr_id;
endinterface
