
import pkg::*;
import opcodes::*;

class branch_scb;
    mailbox mon2scb;
    transaction txn;
    int error_count = 0;
    register_t last_pc = 0;
    register_t expected_ret_addr_reg = 0; 
    register_t expected_pc_out, expected_ret_addr;

    function new(mailbox mon2scb);
        this.mon2scb = mon2scb;
    endfunction

    task run();
        forever begin
            mon2scb.get(txn);
			
            $display("SCB: Received txn - instr=%0d, op1=%0d, op2=%0d, op3=%0d, enable=%0d,pc_out=%0d",txn.instr, txn.op1, txn.op2, txn.op3, txn.enable,txn.pc_out);
            
            // Check for valid enable signal
            if (txn.enable === 1'bx) begin
                error_count++;
                $error("SCB: Enable signal is X!");
                continue;
            end
            
            if (txn.enable) begin
                expected_ret_addr = last_pc + 4;
                case (txn.instr)
                    M_JAL  : expected_pc_out = txn.op1;
                    M_JALR : expected_pc_out = txn.op1 + txn.op2;
                    M_BEQ  : expected_pc_out = (txn.op1 == txn.op2) ? last_pc + txn.op3 : last_pc + 4;
                    M_BNE  : expected_pc_out = (txn.op1 != txn.op2) ? last_pc + txn.op3 : last_pc + 4;
                    M_BLT  : expected_pc_out = (txn.op1 < txn.op2)  ? last_pc + txn.op3 : last_pc + 4;
                    M_BLTU : expected_pc_out = (unsigned'(txn.op1) < unsigned'(txn.op2)) ? last_pc + txn.op3 : last_pc + 4;
                    M_BGE  : expected_pc_out = (txn.op1 >= txn.op2) ? last_pc + txn.op3 : last_pc + 4;
                    M_BGEU : expected_pc_out = (unsigned'(txn.op1) >= unsigned'(txn.op2)) ? last_pc + txn.op3 : last_pc + 4;
                    default: expected_pc_out = last_pc + 4;
                endcase

                // Update tracking variables
                last_pc = expected_pc_out;
                expected_ret_addr_reg = expected_ret_addr;
            end else begin
                expected_pc_out = last_pc; 
                expected_ret_addr = expected_ret_addr_reg; 
            end
             
            // Check for mismatches
            if (txn.pc_out !== expected_pc_out || txn.ret_addr !== expected_ret_addr) begin
                error_count++;
                $error("SCB: Mismatch! Expected PC: %0h, Actual PC: %0h, Expected Ret Addr: %0h, Actual Ret Addr: %0h,txn.instr=%0d",
                       expected_pc_out, txn.pc_out, expected_ret_addr, txn.ret_addr,txn.instr);
            end else begin
                $display("SCB: Match! Expected PC: %0h, Actual PC: %0h, Expected Ret Addr: %0h, Actual Ret Addr: %0h,txn.instr=%0d",
                         expected_pc_out, txn.pc_out, expected_ret_addr, txn.ret_addr,txn.instr);
            end
        end
    endtask

    function void report();
        $display("SCB: Test completed with %0d errors", error_count);
    endfunction
endclass