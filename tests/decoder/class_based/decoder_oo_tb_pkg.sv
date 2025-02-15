
package decoder_oo_tb_pkg;

import opcodes::*;

  // class for results
  class results_c;
    register_t op1, op2, op3;
    register_num_t rd;
  endclass;

  // class for stimuli
  class stimulus_c;
    instruction_t instr;
    register_t    register_bank[32];
  endclass

  // OO testbench components
  `include "generator.sv"
  `include "driver.sv"
  `include "monitors.sv"
  `include "scoreboard.sv"
  `include "environment.sv"

endpackage
