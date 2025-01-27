package opcodes;

typedef logic [6:0] base_opcode_t;
typedef logic [4:0] register_num_t;
typedef logic [2:0] funct3_t;
typedef logic [6:0] funct7_t;

typedef struct packed {
   funct7_t        opcode3;
   register_num_t  rs2;
   register_num_t  rs1;
   funct3_t        opcode2;
   register_num_t  rd;
   base_opcode_t   opcode1;
} r_type;

typedef struct packed {
   logic [11:0]    imm;
   register_num_t  rs1;
   funct3_t        opcode2;
   register_num_t  rd;
   base_opcode_t   opcode1;
} i_type;

typedef struct packed {
   logic [6:0]     imm1;
   register_num_t  rs2;
   register_num_t  rs1;
   funct3_t        opcode2;
   logic [4:0]     imm0;
   base_opcode_t   opcode1;
} s_type;

typedef struct packed {
   logic           imm3;
   logic [5:0]     imm1;
   register_num_t  rs2;
   register_num_t  rs1;
   funct3_t        opcode2;
   logic [3:0]     imm0;
   logic           imm2;
   base_opcode_t   opcode1;
} b_type;

typedef struct packed {
   logic [19:0]    imm;
   register_num_t  rd;
   base_opcode_t   opcode1;
} u_type;

typedef struct packed {
   logic           imm3;
   logic [9:0]     imm0;
   logic           imm1;
   logic [7:0]     imm2;
   register_num_t  rd;
   base_opcode_t   opcode1;
} j_type;

typedef union packed {
  r_type  r;
  i_type  i;
  s_type  s;
  b_type  b;
  u_type  u;
  j_type  j;
} instruction_t;

const instruction_t HALT = 32'h00010073;

typedef enum logic [31:0] {

   M_ADDI  = 32'bzzzz_zzzz_zzzz_zzzz_z000_zzzz_z001_0011,
   M_STLI  = 32'bzzzz_zzzz_zzzz_zzzz_z010_zzzz_z001_0011,
   M_STLIU = 32'bzzzz_zzzz_zzzz_zzzz_z011_zzzz_z001_0011,
   M_ANDI  = 32'bzzzz_zzzz_zzzz_zzzz_z111_zzzz_z001_0011,
   M_ORI   = 32'bzzzz_zzzz_zzzz_zzzz_z110_zzzz_z001_0011,
   M_XORI  = 32'bzzzz_zzzz_zzzz_zzzz_z100_zzzz_z001_0011,
   M_SLLI  = 32'b0000_000z_zzzz_zzzz_z001_zzzz_z001_0011,
   M_SRLI  = 32'b0000_000z_zzzz_zzzz_z101_zzzz_z001_0011,
   M_SRAI  = 32'b0100_000z_zzzz_zzzz_z101_zzzz_z001_0011,
   M_LUI   = 32'bzzzz_zzzz_zzzz_zzzz_zzzz_zzzz_z011_0111,
   M_AUIPC = 32'bzzzz_zzzz_zzzz_zzzz_zzzz_zzzz_z001_0111,

   M_ADD   = 32'b0000_000z_zzzz_zzzz_z000_zzzz_z011_0011,
   M_SUB   = 32'b0100_000z_zzzz_zzzz_z000_zzzz_z011_0011,
   M_SLT   = 32'b0000_000z_zzzz_zzzz_z010_zzzz_z011_0011,
   M_SLTU  = 32'b0000_000z_zzzz_zzzz_z011_zzzz_z011_0011,
   M_AND   = 32'b0000_000z_zzzz_zzzz_z111_zzzz_z011_0011,
   M_OR    = 32'b0000_000z_zzzz_zzzz_z110_zzzz_z011_0011,
   M_XOR   = 32'b0000_000z_zzzz_zzzz_z100_zzzz_z011_0011,
   M_SLL   = 32'b0000_000z_zzzz_zzzz_z001_zzzz_z011_0011,
   M_SRL   = 32'b0000_000z_zzzz_zzzz_z101_zzzz_z011_0011,
   M_SRA   = 32'b0100_000z_zzzz_zzzz_z101_zzzz_z011_0011,

   M_JAL   = 32'bzzzz_zzzz_zzzz_zzzz_zzzz_zzzz_z110_1111,
   M_JALR  = 32'bzzzz_zzzz_zzzz_zzzz_z000_zzzz_z110_0111,
   M_BEQ   = 32'bzzzz_zzzz_zzzz_zzzz_z000_zzzz_z110_0011,
   M_BNE   = 32'bzzzz_zzzz_zzzz_zzzz_z001_zzzz_z110_0011,
   M_BLT   = 32'bzzzz_zzzz_zzzz_zzzz_z100_zzzz_z110_0011,
   M_BLTU  = 32'bzzzz_zzzz_zzzz_zzzz_z110_zzzz_z110_0011,
   M_BGE   = 32'bzzzz_zzzz_zzzz_zzzz_z101_zzzz_z110_0011,
   M_BGEU  = 32'bzzzz_zzzz_zzzz_zzzz_z111_zzzz_z110_0011,
   
   M_LW    = 32'bzzzz_zzzz_zzzz_zzzz_z010_zzzz_z000_0011,
   M_LH    = 32'bzzzz_zzzz_zzzz_zzzz_z001_zzzz_z000_0011,
   M_LHU   = 32'bzzzz_zzzz_zzzz_zzzz_z101_zzzz_z000_0011,
   M_LB    = 32'bzzzz_zzzz_zzzz_zzzz_z000_zzzz_z000_0011,
   M_LBU   = 32'bzzzz_zzzz_zzzz_zzzz_z100_zzzz_z000_0011,

   M_SW    = 32'bzzzz_zzzz_zzzz_zzzz_z010_zzzz_z010_0011,
   M_SH    = 32'bzzzz_zzzz_zzzz_zzzz_z001_zzzz_z010_0011,
   M_SB    = 32'bzzzz_zzzz_zzzz_zzzz_z000_zzzz_z010_0011

} opcode_mask_t;

task print_opcode(instruction_t instr);

   casez (instr) 
    M_ADD : $display("ADD  x%0d, x%0d, x%0d ", instr.r.rd, instr.r.rs1, instr.r.rs2);
    M_SUB : $display("SUB  x%0d, x%0d, x%0d ", instr.r.rd, instr.r.rs1, instr.r.rs2);
    M_AND : $display("AND  x%0d, x%0d, x%0d ", instr.r.rd, instr.r.rs1, instr.r.rs2);
    M_OR  : $display("OR   x%0d, x%0d, x%0d ", instr.r.rd, instr.r.rs1, instr.r.rs2);
    default: $display("%b not decoded yet ", instr);
   endcase 

endtask

function instruction_t encode_rtype(opcode_mask_t base_opcode, int dest, int rs1, int rs2);
   instruction_t instr;

   instr = base_opcode;

   // $display("before encoding: opcode_1: %b, opcode_2: %b ocpode_3: %b, rd: %b rs1: %b, rs2: %b", 
   //           instr.r.opcode1, instr.r.opcode2, instr.r.opcode3, instr.r.rd, instr.r.rs1, instr.r.rs2);

   instr.r.rd  = register_num_t'(dest);
   instr.r.rs1 = register_num_t'(rs1);
   instr.r.rs2 = register_num_t'(rs2);
 
   // $display("encoded as opcode_1: %b, opcode_2: %b ocpode_3: %b, rd: %b rs1: %b, rs2: %b", 
   //            instr.r.opcode1, instr.r.opcode2, instr.r.opcode3, instr.r.rd, instr.r.rs1, instr.r.rs2);
   return instr;
endfunction

endpackage
