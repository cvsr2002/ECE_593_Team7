# ECE_593_Team7

🚀 RISC-V RV32I Core Verification - Team 7

📝 Project Overview
This project implements and verifies a RISC-V RV32I core, focusing on executing arithmetic, logic, load/store, and branch instructions. The core follows a Harvard architecture, uses a state machine-based execution model, and omits features like pipelines, caches, and privilege modes.

🎯 Verification Objectives
Unit Testing of core modules: ALU, Memory Controller, and Branch Controller.
Functional Verification to ensure correct execution of the RV32I instruction subset.
Coverage-Driven Testing for code and functional coverage.
System-Level Testing using short programs executed on the core.

🛠️ Key Components
ALU: Performs arithmetic and logic operations.
Memory Controller: Handles data memory access.
Branch Controller: Manages program control flow.
Register File: Stores general-purpose registers.
State Machine: Controls instruction execution flow.

✅ Verification Strategy

We employed a two-tier testing approach:

Unit Tests (Independent Module Testing)

✅ ALU Test: Verified all arithmetic and logic operations.
✅ Memory Controller Test: Ensured correct memory reads/writes.
✅ Branch Controller Test: Confirmed correct execution of branch/jump operations.

Core-Level Tests (Integrated Testing)

✅ Opcode Tests: Validated individual instruction execution.
✅ Multiple Instruction Sequences: Ensured instruction sequencing.
✅ Random Tests: Stressed the core with randomized execution.


🔧 Tools Used
Logic Simulator: QuestaSim for SystemVerilog testbenches.
Compiler Toolchain: GNU RISC-V GCC.
Version Control: GitHub Repository - GitHub Link.

📌 Block Diagram
Here’s a high-level block diagram of our RISC-V core verification framework:

![WhatsApp Image 2025-01-31 at 20 23 49_56f27c75](https://github.com/user-attachments/assets/2ef604e1-2773-44d2-88d1-07e3870e5216)


📅 Project Timeline

Milestone	Tasks Completed
M1	Designed ALU, Branch Controller, Memory Controller
  M2	Implemented Unit Tests, Integrated Core-Level Tests
  M3	Completed Opcode Tests, Added Functional Coverage
  M4	Executed Short Programs, Debugged State Machine
  M5	Achieved 100% Coverage, Finalized UVM Testbenches

🔍 Key Findings

The ALU and Memory Controller were independently tested and verified before integration.
Directed and random tests confirmed correct execution of all instructions.
The state machine was fully exercised, ensuring all instruction paths were covered.

📢 Conclusion
This project successfully verified a RISC-V RV32I core using comprehensive unit and core-level testing. The core meets the functional requirements and is ready for further development.

-------------------

To Build and Run:

  make alu_test
      - builds and runs ALU standalone unit test

  make mem_test
      - builds and runs Load/Store instruction unit test

  make jump_test
      - builds and runs branch control unit test
