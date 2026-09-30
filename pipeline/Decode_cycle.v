module RISCV_Pipe_Decode_Cycle #(
    parameter dataWidth =   32
) (
    input                                           clk,
    input                                           rstn,
    input                                           RegWrite_SW,
    input   [ 4 : 0 ]                               RD_SW, 
    input   [ dataWidth - 1 : 0 ]                   Program_Counter_SF,
    input   [ dataWidth - 1 : 0 ]                   Program_counter_Increamented_SF,
    input   [ dataWidth - 1 : 0 ]                   Instruction_mem_out_SF,
    input   [ dataWidth - 1 : 0 ]                   Result_SW,

    output                                          RegWrite_SD ,
    output                                          ALUSource_SD,
    output                                          MemWrite_SD,
    output                                          ResSource_SD,
    output [ 4 : 0 ]                                RD_SD,
    output                                          Branch_SD,
    output [ 2 : 0 ]                                ALU_Ctrl_SD,
    output [ dataWidth - 1 : 0]                     ReadData_1_SD,
    output [ dataWidth - 1 : 0]                     ReadData_2_SD,
    output [ dataWidth - 1 : 0]                     Immediate_SD, 
    output [ dataWidth - 1 : 0 ]                    Program_Counter_SD,
    output [ dataWidth - 1 : 0 ]                    Program_counter_Increamented_SD,
    output [ 4 : 0 ]                                RSrc1_D,
    output [ 4 : 0 ]                                RSrc2_D
);
    
// Assign outputs

assign Program_Counter_SD                   =   Program_Counter_SF;
assign Program_counter_Increamented_SD      =   Program_counter_Increamented_SF;

assign RD_SD                                =   Instruction_mem_out_SF [ 11 : 7 ];


assign  RSrc1_D                             =   Instruction_mem_out_SF [ 19 : 15 ];
assign  RSrc2_D                             =   Instruction_mem_out_SF [ 24 : 20 ];
// Internal Wires

wire [ 1 : 0 ]                      ImmeSourceD_w ;


// Control Unit inst


RISCV_Control_Unit decode_control_unit_inst
(
    // .Z_flag_i(),
    .opCode_i( Instruction_mem_out_SF [ 6 : 0 ] ),
    .func3_i( Instruction_mem_out_SF [ 14 : 12 ] ),
    .func7_5b_i( Instruction_mem_out_SF [ 30 ] ),
    .ALU_Ctrl_o(ALU_Ctrl_SD),
    .RegWrite_o(RegWrite_SD),
    .MemWrite_o(MemWrite_SD),
    .ResSource_o(ResSource_SD),
    .ALUSource_o(ALUSource_SD),
    // .PCSource_o(),
    .ImmeSource_o(ImmeSourceD_w),
    .Branch_o(Branch_SD)

);

// Register File inst

RISCV_Register_File decode_reg_file_inst (
    .clk(clk),
    .rstn(rstn),
    .Write_En(RegWrite_SW),
    .ReadAddr_1( Instruction_mem_out_SF [ 19 : 15 ] ),
    .ReadAddr_2( Instruction_mem_out_SF [ 24 : 20 ] ),
    .WriteAddr(RD_SW),
    .WriteData(Result_SW),
    .ReadData_1(ReadData_1_SD),
    .ReadData_2(ReadData_2_SD)
    
);

// Extender inst

RISCV_Extender_Block decode_sign_extender_block_inst(
    .instrction_i( Instruction_mem_out_SF ),
    .immediate_source_i(ImmeSourceD_w),
    .Immediate_o( Immediate_SD )
);


endmodule