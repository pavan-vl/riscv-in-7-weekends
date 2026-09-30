`define dataWidth   32
`include    "alu.v"
`include    "cu.v"
`include    "proc_comps.v"
module RISCV_Core_top (
    input                                       clk,
    input                                       rstn,
    output                                      result
);  

wire [2 : 0]                 ALU_Control_w ;
wire [`dataWidth - 1 : 0]    instruction_w ;
wire [`dataWidth - 1 : 0]    Read_Data_1_w ;
wire [`dataWidth - 1 : 0]    Read_Data_2_w ;
wire [`dataWidth - 1 : 0]    PC_intr;
wire [`dataWidth - 1 : 0]    Immediate_o_ext;
wire [`dataWidth - 1 : 0]    alu_result_w;
wire [`dataWidth - 1 : 0]    RD_DataMem_w;
wire [`dataWidth - 1 : 0]    MuxOut_RD_DataMem_w;
wire [`dataWidth - 1 : 0]    MuxOut_Immediate_o_ext_w ;
wire [`dataWidth - 1 : 0]    Inc_PCNext_w ;
wire                         ResSource_w;
wire                         Zero_Flag_w;
wire                         ALUSource_w;
wire                         Reg_Write_w;
wire                         MemWrite_w;
wire [ 1 : 0 ]               ImmeSource_w;
RISCV_ProgramCounter prog_counter_inst (
    .PC_Next(Inc_PCNext_w),
    .clk(clk),
    .rstn(rstn),
    .PC_o(PC_intr)   
);



RISCV_Instruction_Memory instrction_mem_inst (
    .Addr_in(PC_intr),
    .rstn(rstn),
    .ReadData(instruction_w)
);



RISCV_Register_File reg_file_inst (
    .clk(clk),
    .rstn(rstn),
    .Write_En(Reg_Write_w),
    .ReadAddr_1(instruction_w [ 19 : 15 ] ),
    .ReadAddr_2(instruction_w [ 24 : 20 ]),
    .WriteAddr(instruction_w [ 11 : 7 ]),
    .WriteData(MuxOut_RD_DataMem_w),
    .ReadData_1(Read_Data_1_w),
    .ReadData_2(Read_Data_2_w)
    
);



RISCV_Extender_Block sign_extender_block_inst(
    .instrction_i(instruction_w),
    .immediate_source_i(ImmeSource_w[0]),
    .Immediate_o(Immediate_o_ext)
);



RISCV_Control_Unit control_unit_inst
(
    .Z_flag_i(Zero_Flag_w),
    .opCode_i(instruction_w [ 6 : 0 ]),
    .func3_i(instruction_w [ 14 : 12 ]),
    .func7_5b_i(instruction_w [ 30 ] ),
    .ALU_Ctrl_o(ALU_Control_w),
    .RegWrite_o(Reg_Write_w),
    .MemWrite_o(MemWrite_w),
    .ResSource_o(ResSource_w),
    .ALUSource_o(ALUSource_w),
    .PCSource_o(),
    .ImmeSource_o(ImmeSource_w)

);


RISCV_2_to_1_MUX register_file_mux_inst (
    .In1(Read_Data_2_w),
    .In2(Immediate_o_ext),
    .sel_line(ALUSource_w),
    .MuxOut_o(MuxOut_Immediate_o_ext_w)

);

RISCV_ALU    ALU_inst (
    .a(Read_Data_1_w),
    .b(MuxOut_Immediate_o_ext_w),
    .alu_ctrl(ALU_Control_w),
    .alu_out(alu_result_w),
    .Z_flag_o(Zero_Flag_w)
);




RISCV_Data_Memory data_memory_inst (
    .clk(clk),
    .rstn(rstn),
    .Write_En(MemWrite_w),
    .Addr_in(alu_result_w),
    .WriteData_i(Read_Data_2_w),
    .ReadData_o(RD_DataMem_w)
);


RISCV_2_to_1_MUX data_mem_mux_inst (
    .In1(alu_result_w),
    .In2(RD_DataMem_w),
    .sel_line(ResSource_w),
    .MuxOut_o(MuxOut_RD_DataMem_w)

);



RISCV_ProgramCounter_Instruction_Increamenter pc_increamenter_inst (
    .In_1(PC_intr),
    .In_2(32'h4),
    .Inc_out_o(Inc_PCNext_w)
);


endmodule


module RISCV_Extender_Block #(parameter dataWidth = 32) (
    input   [dataWidth - 1 : 0]     instrction_i,
    input                           immediate_source_i,
    output  [dataWidth - 1 : 0]     Immediate_o
);
    assign Immediate_o = (immediate_source_i == 1'b1) ?
    { {20{instrction_i[dataWidth-1]}}, instrction_i[dataWidth-1:25], instrction_i[11:7] } :
    { {20{instrction_i[dataWidth-1]}}, instrction_i[dataWidth-1:20] };
endmodule


module RISCV_ProgramCounter_Instruction_Increamenter #(parameter dataWidth = 32) (
    input   [dataWidth - 1 : 0]     In_1,
    input   [dataWidth - 1 : 0]     In_2,
    output  [dataWidth - 1 : 0]     Inc_out_o
);
    assign   Inc_out_o  =   In_1    +   In_2 ;
endmodule


module RISCV_2_to_1_MUX #(parameter dataWidth = 32) (
    input   [dataWidth - 1 : 0]   In1,
    input   [dataWidth - 1 : 0]   In2,
    input                         sel_line,
    output  [dataWidth - 1 : 0]   MuxOut_o

);

assign  MuxOut_o    =   (sel_line)?     In2     :       In1 ;

endmodule