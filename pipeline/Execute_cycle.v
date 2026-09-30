module RISCV_Pipe_Execute_Cycle #(
    parameter dataWidth    =   32
) (
    input                                            clk,
    input                                            rstn,
    input                                            RegWrite_SD ,
    input                                            ALUSource_SD,
    input                                            MemWrite_SD,
    input                                            ResSource_SD,
    input   [ 4 : 0 ]                                RD_SD,
    input                                            Branch_SD,
    input   [ 2 : 0 ]                                ALU_Ctrl_SD,
    input   [ dataWidth - 1 : 0 ]                    ReadData_1_SD,
    input   [ dataWidth - 1 : 0 ]                    ReadData_2_SD,
    input   [ dataWidth - 1 : 0 ]                    Immediate_SD, 
    input   [ dataWidth - 1 : 0 ]                    Program_Counter_SD,
    input   [ dataWidth - 1 : 0 ]                    Program_counter_Increamented_SD,
    input   [ dataWidth - 1 : 0 ]                    Result_SW,
    input   [ dataWidth - 1 : 0 ]                    ALU_Result_SM,
    input   [ 1 : 0 ]                                ForwardA_E_HU,
    input   [ 1 : 0 ]                                ForwardB_E_HU,

    output                                           PC_Source_SE,
    output  [ dataWidth - 1 : 0 ]                    PC_Target_SE,
    output  [ dataWidth - 1 : 0 ]                    ALU_Result_SE,
    output  [ dataWidth - 1 : 0 ]                    WriteData_SE,
    output  [ 4 : 0 ]                                RD_SE,
    output  [ dataWidth - 1 : 0 ]                    Program_counter_Increamented_SE,
    output                                           RegWrite_SE,
    output                                           ResSource_SE,
    output                                           MemWrite_SE
);


assign  RegWrite_SE             =   RegWrite_SD;
assign  ResSource_SE            =   ResSource_SD;
assign  MemWrite_SE             =   MemWrite_SD;

assign  RD_SE                   =   RD_SD;
assign  Program_counter_Increamented_SE = Program_counter_Increamented_SD;


wire [ dataWidth - 1 : 0 ]              MuxOut_ALU_Ew;
wire [ dataWidth - 1 : 0 ]              PC_Target_Ew;
wire [ dataWidth - 1 : 0 ]              Hazard_MuxOut_1;
wire [ dataWidth - 1 : 0 ]              Hazard_MuxOut_2;
wire                                    Zero_Flag_Ew;

assign  PC_Source_SE            =   Zero_Flag_Ew    &    Branch_SD;
assign  WriteData_SE            =   Hazard_MuxOut_2;
assign  PC_Target_SE            =   PC_Target_Ew;


// Modules Instantiation

RISCV_3_to_1_MUX execute_hazard_mux_alu_in1_inst (
    .In1(ReadData_1_SD),
    .In2(Result_SW),
    .In3(ALU_Result_SM),
    .sel_line(ForwardA_E_HU),
    .MuxOut_o(Hazard_MuxOut_1)

);

RISCV_3_to_1_MUX execute_hazard_mux_alu_in2_inst (
    .In1(ReadData_2_SD),
    .In2(Result_SW),
    .In3(ALU_Result_SM),
    .sel_line(ForwardB_E_HU),
    .MuxOut_o(Hazard_MuxOut_2)

);


RISCV_2_to_1_MUX execute_alu_mux_inst (
    .In1(Hazard_MuxOut_2),
    .In2(Immediate_SD),
    .sel_line(ALUSource_SD),
    .MuxOut_o(MuxOut_ALU_Ew)

);



RISCV_ALU    execute_ALU_inst (
    .a(Hazard_MuxOut_1),
    .b(MuxOut_ALU_Ew),
    .alu_ctrl(ALU_Ctrl_SD),
    .alu_out(ALU_Result_SE),
    .Z_flag_o(Zero_Flag_Ew)
);

RISCV_ProgramCounter_Instruction_Increamenter execute_pc_increamenter_inst (
    .In_1(Program_Counter_SD),
    .In_2(Immediate_SD),
    .Inc_out_o(PC_Target_Ew)
);

    
endmodule