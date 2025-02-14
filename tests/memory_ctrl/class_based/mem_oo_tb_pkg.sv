
package mem_oo_tb_pkg;

import opcodes::*;

  typedef enum logic {RX_READ, RX_WRITE} rx_rw_t;

  // class for results
  class results_c;
    rx_rw_t    rw;
    register_t result;
  endclass;

  // class for stimuli
  class stimulus_c;
    instruction_t instr;
    register_t    op1, op2, op3;
  endclass

  // OO testbench components
  // `include "generator_mem_test.sv"
  // `include "generator_random.sv"
  `include "generator.sv"
  `include "driver.sv"
  `include "monitors.sv"
  `include "scoreboard.sv"
  `include "environment.sv"

endpackage
