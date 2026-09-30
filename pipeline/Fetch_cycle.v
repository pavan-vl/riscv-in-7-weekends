module RISCV_Pipe_Fetch_Cycle #(
    parameter dataWidth = 32
) (
    input                                   clk,
    input                                   rstn,
    input                                   PC_Source_SE,
    input   [dataWidth - 1 : 0]             PC_Target_SE,
    output  [dataWidth - 1 : 0]             Instruction_mem_out_SF,
    output  [dataWidth - 1 : 0]             Program_Counter_SF,
    output  [dataWidth - 1 : 0]             Program_counter_Increamented_SF
);
    wire [ dataWidth - 1 : 0 ] ProgramCounter_MuxOut;
    wire [ dataWidth - 1 : 0 ] ProgramCounter_Out;
    wire [ dataWidth - 1 : 0 ] ProgramCounter_Increamenter_Out;

    RISCV_2_to_1_MUX program_counter_mux_inst (
    .In1(ProgramCounter_Increamenter_Out),
    .In2(PC_Target_SE),
    .sel_line(PC_Source_SE),
    .MuxOut_o(ProgramCounter_MuxOut)
);

RISCV_ProgramCounter prog_counter_inst (
    .PC_Next(ProgramCounter_MuxOut),
    .clk(clk),
    .rstn(rstn),
    .PC_o(ProgramCounter_Out)   
);

RISCV_Instruction_Memory instrction_mem_inst (
    .Addr_in(ProgramCounter_Out),
    .rstn(rstn),
    .ReadData(Instruction_mem_out_SF)
);

RISCV_ProgramCounter_Instruction_Increamenter pc_increamenter_inst (
    .In_1(ProgramCounter_Out),
    .In_2(32'h4),
    .Inc_out_o(ProgramCounter_Increamenter_Out)
);

assign      Program_counter_Increamented_SF     =   ProgramCounter_Increamenter_Out;
assign      Program_Counter_SF                  =   ProgramCounter_Out;

endmodule