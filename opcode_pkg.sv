package opcodes;

typedef logic [6:0] base_opcode_t;
typedef logic [4:0] register_num_t;
typedef logic [2:0] funct3_t;
typedef logic [6:0] funct7_t;
typedef logic signed [11:0] short_imm_t;
typedef logic signed [19:0] long_imm_t;


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

// functions to assemble opcodes

function instruction_t encode_rtype(opcode_mask_t base_opcode, int dest, int rs1, int rs2);
   instruction_t instr;

   instr = base_opcode;

   instr.r.rd  = register_num_t'(dest);
   instr.r.rs1 = register_num_t'(rs1);
   instr.r.rs2 = register_num_t'(rs2);
 
   return instr;
endfunction

function instruction_t encode_itype(opcode_mask_t base_opcode, int dest, int rs1, int imm);
   instruction_t instr;
   
   instr = base_opcode;

   instr.i.rd  = register_num_t'(dest);
   instr.i.rs1 = register_num_t'(rs1);
   set_i_imm(instr, short_imm_t'(imm));

   return instr;
endfunction

function instruction_t encode_stype(opcode_mask_t base_opcode, int rs1, int rs2, int imm);
   instruction_t instr;
   
   instr = base_opcode;

   instr.s.rs1 = register_num_t'(rs1);
   instr.s.rs2 = register_num_t'(rs2);
   set_s_imm(instr, short_imm_t'(imm));

   return instr;
endfunction

function instruction_t encode_btype(opcode_mask_t base_opcode, int rs1, int rs2, int imm);
   instruction_t instr;
   
   instr = base_opcode;

   instr.b.rs1 = register_num_t'(rs1);
   instr.b.rs2 = register_num_t'(rs2);
   set_b_imm(instr, short_imm_t'(imm));

   return instr;
endfunction

function instruction_t encode_utype(opcode_mask_t base_opcode, int dest, int imm);
   instruction_t instr;
   
   instr = base_opcode;

   instr.u.rd = register_num_t'(dest);
   set_u_imm(instr, long_imm_t'(imm));

   return instr;
endfunction

function instruction_t encode_jtype(opcode_mask_t base_opcode, int dest, int imm);
   instruction_t instr;
   
   instr = base_opcode;

   instr.j.rd = register_num_t'(dest);
   set_j_imm(instr, long_imm_t'(imm));

   return instr;
endfunction

// retrieve immediate values from opcodes 

function short_imm_t get_i_imm(input instruction_t instr);
   return (instr.i.imm);
endfunction

function short_imm_t get_s_imm(input instruction_t instr);
   return ({instr.s.imm1, instr.s.imm0});
endfunction

function short_imm_t get_b_imm(input instruction_t instr);
   return({instr.b.imm3, instr.b.imm2, instr.b.imm1, instr.b.imm0});
endfunction

function long_imm_t get_u_imm(input instruction_t instr);
   return(instr.u.imm);
endfunction

function long_imm_t get_j_imm(input instruction_t instr);
   return({instr.j.imm3, instr.j.imm2, instr.j.imm1, instr.j.imm0});
endfunction

// set immediate values in opcodes

function automatic void set_i_imm(ref instruction_t instr, input short_imm_t imm);
   instr.i.imm = imm;
endfunction

function automatic void set_s_imm(ref instruction_t instr, input short_imm_t imm);
   {instr.s.imm1, instr.s.imm0} = imm;
endfunction

function automatic void set_b_imm(ref instruction_t instr, input short_imm_t imm);
   {instr.b.imm3, instr.b.imm2, instr.b.imm1, instr.b.imm0} = imm;   
endfunction

function automatic void set_u_imm(ref instruction_t instr, input long_imm_t imm);
   instr.u.imm = imm;
endfunction

function automatic void set_j_imm(ref instruction_t instr, input long_imm_t imm);
   {instr.j.imm3, instr.j.imm2, instr.j.imm1, instr.j.imm0} = imm;
endfunction

endpackage
