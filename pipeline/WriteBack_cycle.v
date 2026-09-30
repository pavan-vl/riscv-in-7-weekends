module RISCV_Pipe_WriteBack_Cycle #(
    parameter   dataWidth  =    32
) (
    input                                           clk,
    input                                           rstn,

    input                                           RegWrite_SM,
    input                                           ResSource_SM,
    input  [ 4 : 0 ]                                RD_SM,
    input  [ dataWidth - 1 : 0 ]                    ALU_Result_SM,
    input  [ dataWidth - 1 : 0 ]                    Program_counter_Increamented_SM,
    input  [ dataWidth - 1 : 0 ]                    ReadData_SM,


    output                                          RegWrite_SW,
    output [ 4 : 0 ]                                RD_SW,
    output [ dataWidth - 1 : 0 ]                    Result_SW
);
    
// Internal wires


// Module instantiation 

RISCV_3_to_1_MUX writeback_data_mem_mux_inst (
    .In1(ALU_Result_SM),
    .In2(ReadData_SM),
    .In3(Program_counter_Increamented_SM),
    .sel_line({1'b0,ResSource_SM}),
    .MuxOut_o(Result_SW)
);

assign  RegWrite_SW         =   RegWrite_SM;
assign  RD_SW               =   RD_SM;


endmodule