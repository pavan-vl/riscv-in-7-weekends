`timescale 1ns/1ps

module tb_riscv_pipe;

    reg clk  = 1'b0;
    reg rstn = 1'b0;

    RISCV_Pipe_TOP dut (.clk(clk), .rstn(rstn));

    // 10 ns clock
    always #5 clk = ~clk;

    // Short hierarchical names
    `define IMEM dut.fetch_cycle_inst.instrction_mem_inst.Ins_Mem
    `define RF   dut.decode_cycle_inst.decode_reg_file_inst.RegFile_Mem

    integer i;
    integer errors = 0;

    task check(input [255:0] name, input [31:0] got, input [31:0] exp);
        begin
            if (got === exp)
                $display("PASS  %-4s = 0x%08h", name, got);
            else begin
                $display("FAIL  %-4s = 0x%08h  (expected 0x%08h)", name, got, exp);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("tb_riscv_pipe.vcd");
        $dumpvars(0, tb_riscv_pipe);

        // 1. Fill instruction memory with NOPs, then write the program directly
        for (i = 0; i < 1024; i = i + 1) `IMEM[i] = 32'h00000013;
        `IMEM[0] = 32'h00500293;   // addi t0, x0, 5
        `IMEM[1] = 32'h00300313;   // addi t1, x0, 3
        `IMEM[2] = 32'h006283B3;   // add  t2, t0, t1
        `IMEM[3] = 32'h00002403;   // lw   s0, 0(x0)
        `IMEM[4] = 32'h00100493;   // addi s1, x0, 1
        `IMEM[5] = 32'h00940533;   // add  a0, s0, s1

        // 2. Reset for 2 cycles
        #12 rstn = 1'b1;

        // 3. Data memory is cleared by reset, so mem[0] = 0 and lw s0 loads 0

        // 4. Run long enough for all 4 instructions to reach write-back
        repeat (14) @(posedge clk);
        #1;

        $display("---- Results ----");
        check("t0",  `RF[5],  32'd5);   // addi t0, x0, 5
        check("t1",  `RF[6],  32'd3);   // addi t1, x0, 3
        check("t2",  `RF[7],  32'd8);   // add  t2, t0, t1
        check("s0",  `RF[8],  32'd0);   // lw   s0, 0(x0)   (mem[0] = 0)
        check("s1",  `RF[9],  32'd1);   // addi s1, x0, 1
        check("a0",  `RF[10], 32'd1);   // add  a0, s0, s1

        if (errors == 0) $display("\nALL TESTS PASSED");
        else             $display("\n%0d TEST(S) FAILED", errors);
        $finish;
    end

    // Per-cycle trace
    always @(posedge clk) if (rstn)
        $display("t=%0t PC=%h instr=%h | FwdA=%b FwdB=%b | WB: we=%b rd=%0d data=%h",
                 $time,
                 dut.Program_Counter_SD_w,
                 dut.Instruction_mem_out_SD_w,
                 dut.ForwardA_E_w, dut.ForwardB_E_w,
                 dut.RegWrite_SWD_w, dut.RD_SWD_w, dut.Result_SWD_w);

endmodule
