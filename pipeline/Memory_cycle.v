module RISCV_Pipe_Memory_Cycle #(
                            parameter dataWidth = 32
) (
    input                                            clk,
    input                                            rstn,

    
    input   [ dataWidth - 1 : 0 ]                    ALU_Result_SE,
    input   [ dataWidth - 1 : 0 ]                    WriteData_SE,
    input   [ 4 : 0 ]                                RD_SE,
    input   [ dataWidth - 1 : 0 ]                    Program_counter_Increamented_SE,
    input                                            RegWrite_SE,
    input                                            ResSource_SE,
    input                                            MemWrite_SE,

    output                                           RegWrite_SM,
    output                                           ResSource_SM,
    output  [ 4 : 0 ]                                RD_SM,
    output  [ dataWidth - 1 : 0 ]                    ALU_Result_SM,
    output  [ dataWidth - 1 : 0 ]                    Program_counter_Increamented_SM,
    output  [ dataWidth - 1 : 0 ]                    ReadData_SM

);

// Internal wires


// Module Instatiations


RISCV_Data_Memory data_memory_inst (
    .clk(clk),
    .rstn(rstn),
    .Write_En(MemWrite_SE),
    .Addr_in(ALU_Result_SE),
    .WriteData_i(WriteData_SE),
    .ReadData_o(ReadData_SM)
);


// Output pass ons

assign  RegWrite_SM     =   RegWrite_SE;
assign  ResSource_SM    =   ResSource_SE;
assign  RD_SM           =   RD_SE;

assign  ALU_Result_SM                        =   ALU_Result_SE;
assign  Program_counter_Increamented_SM      =   Program_counter_Increamented_SE;
// genvar i = 0;

// generate
//     for (i=0 ; i < dataWidth; i=i+1 ) 
//     begin
//         assign  ALU_Result_SM[i]                        =   ALU_Result_SE[i];
//         assign  Program_counter_Increamented_SM[i]      =   Program_counter_Increamented_SE[i];
//     end
// endgenerate

    
endmodule