`timescale 1ns/1ps

module tb_riscv_core;

    reg clk  = 1'b0;
    reg rstn = 1'b0;

    RISCV_Core_top dut (.clk(clk), .rstn(rstn), .result());

    // 10 ns clock
    always #5 clk = ~clk;

    `define IMEM dut.instrction_mem_inst.Ins_Mem
    `define RF   dut.reg_file_inst.RegFile_Mem
    `define DMEM dut.data_memory_inst.DataMemModMem

    integer i;
    integer errors = 0;

    task check(input [255:0] name, input [31:0] got, input [31:0] exp);
        begin
            if (got === exp)
                $display("PASS  %-8s = 0x%08h", name, got);
            else begin
                $display("FAIL  %-8s = 0x%08h  (expected 0x%08h)", name, got, exp);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("tb_riscv_core.vcd");
        $dumpvars(0, tb_riscv_core);

        // 1. Program (supported: lw, sw, R-type add/sub/and/or/slt)
        for (i = 0; i < 1024; i = i + 1) `IMEM[i] = 32'h00000000;
        `IMEM[0] = 32'h015a0c33;   // add  s8, s4, s5
        `IMEM[1] = 32'h413c0933;   // sub  s2, s8, s3
        `IMEM[2] = 32'h018fecb3;   // or   s9, t6, s8
        `IMEM[3] = 32'h007c7bb3;   // and  s7, s8, t2
        `IMEM[4] = 32'h0149a2b3;   // slt  t0, s3, s4
        `IMEM[5] = 32'h01802223;   // sw   s8, 4(x0)
        `IMEM[6] = 32'h00402303;   // lw   t1, 4(x0)

        // 2. Reset (register file and data memory clear on the clock edges)
        #12 rstn = 1'b1;

        // 3. Preload source registers before the first instruction executes
        `RF[20] = 32'd10;          // s4
        `RF[21] = 32'd5;           // s5
        `RF[19] = 32'd3;           // s3
        `RF[31] = 32'h0000_00F0;   // t6
        `RF[7]  = 32'd7;           // t2

        // 4. One instruction per clock: 7 instructions + margin
        repeat (8) @(posedge clk);
        #1;

        $display("---- Results ----");
        check("s8",      `RF[24], 32'd15);          // add  s8, s4, s5  = 10 + 5
        check("s2",      `RF[18], 32'd12);          // sub  s2, s8, s3  = 15 - 3
        check("s9",      `RF[25], 32'h0000_00FF);   // or   s9, t6, s8  = 0xF0 | 0x0F
        check("s7",      `RF[23], 32'd7);           // and  s7, s8, t2  = 15 & 7
        check("t0",      `RF[5],  32'd1);           // slt  t0, s3, s4  = (3 < 10)
        check("mem[4]",  `DMEM[4], 32'd15);         // sw   s8, 4(x0)
        check("t1",      `RF[6],  32'd15);          // lw   t1, 4(x0)

        if (errors == 0) $display("\nALL TESTS PASSED");
        else             $display("\n%0d TEST(S) FAILED", errors);
        $finish;
    end

    // Per-cycle trace (values just before each rising edge)
    always @(negedge clk) if (rstn)
        $display("t=%0t PC=%h instr=%h | ALUctrl=%b a=%h b=%h alu=%h | we=%b rd=%0d wd=%h | memwe=%b",
                 $time,
                 dut.PC_intr, dut.instruction_w,
                 dut.ALU_Control_w, dut.Read_Data_1_w, dut.MuxOut_Immediate_o_ext_w, dut.alu_result_w,
                 dut.Reg_Write_w, dut.instruction_w[11:7], dut.MuxOut_RD_DataMem_w,
                 dut.MemWrite_w);

endmodule
