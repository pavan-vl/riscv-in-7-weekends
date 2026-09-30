module RISCV_Pipe_TOP #(parameter dataWidth = 32) 
(
    input                                   clk,
    input                                   rstn

);

// Fetch cycle output wires

wire  [ dataWidth - 1 : 0 ]                     Instruction_mem_out_SD_w;
wire  [ dataWidth - 1 : 0 ]                     Program_Counter_SD_w;
wire  [ dataWidth - 1 : 0 ]                     Program_counter_Increamented_SD_w;

// Decode cycle output wires

wire                                            RegWrite_SE_w ;
wire                                            ALUSource_SE_w;
wire                                            MemWrite_SE_w;
wire                                            ResSource_SE_w;
wire [ 4 : 0 ]                                  RD_SE_w;
wire                                            Branch_SE_w;
wire [ 2 : 0 ]                                  ALU_Ctrl_SE_w;
wire [ dataWidth - 1 : 0 ]                      ReadData_1_SE_w;
wire [ dataWidth - 1 : 0 ]                      ReadData_2_SE_w;
wire [ dataWidth - 1 : 0 ]                      Immediate_SE_w;
wire [ dataWidth - 1 : 0 ]                      Program_Counter_SE_w;
wire [ dataWidth - 1 : 0 ]                      Program_counter_Increamented_SE_w;
wire [ 4 : 0 ]                                  RSrc1_E_w;
wire [ 4 : 0 ]                                  RSrc2_E_w;


// Execute Cycle output wires

wire                                           PC_Source_SEF_w;
wire  [ dataWidth - 1 : 0 ]                    PC_Target_SEF_w;
wire  [ dataWidth - 1 : 0 ]                    ALU_Result_SM_w;
wire  [ dataWidth - 1 : 0 ]                    WriteData_SM_w;
wire  [ 4 : 0 ]                                RD_SM_w;
wire  [ dataWidth - 1 : 0 ]                    Program_counter_Increamented_SM_w;
wire                                           RegWrite_SM_w;
wire                                           ResSource_SM_w;
wire                                           MemWrite_SM_w;


// Memory Cycle output wires

wire                                           RegWrite_SW_w;
wire                                           ResSource_SW_w;
wire  [ 4 : 0 ]                                RD_SW_w;
wire  [ dataWidth - 1 : 0 ]                    ALU_Result_SW_w;
wire  [ dataWidth - 1 : 0 ]                    Program_counter_Increamented_SW_w;
wire  [ dataWidth - 1 : 0 ]                    ReadData_SW_w;


// Write back cycle output wires

wire                                          RegWrite_SWD_w;
wire [ 4 : 0 ]                                          RD_SWD_w;
wire [ dataWidth - 1 : 0 ]                    Result_SWD_w;


// Hazard Unit wires

wire  [ 1 : 0 ]                               ForwardA_E_w;
wire  [ 1 : 0 ]                               ForwardB_E_w;



// Fetch cycle out regs

reg  [ dataWidth - 1 : 0 ]                     Instruction_mem_out_SDreg;
reg  [ dataWidth - 1 : 0 ]                     Program_Counter_SDreg;
reg  [ dataWidth - 1 : 0 ]                     Program_counter_Increamented_SDreg;

// Decode Cycle out regs

reg                                            RegWrite_SEreg ;
reg                                            ALUSource_SEreg;
reg                                            MemWrite_SEreg;
reg                                            ResSource_SEreg;
reg [ 4 : 0 ]                                  RD_SEreg;
reg                                            Branch_SEreg;
reg [ 2 : 0 ]                                  ALU_Ctrl_SEreg;
reg [ dataWidth - 1 : 0 ]                      ReadData_1_SEreg;
reg [ dataWidth - 1 : 0 ]                      ReadData_2_SEreg;
reg [ dataWidth - 1 : 0 ]                      Immediate_SEreg;
reg [ dataWidth - 1 : 0 ]                      Program_Counter_SEreg;
reg [ dataWidth - 1 : 0 ]                      Program_counter_Increamented_SEreg;
reg [ 4 : 0 ]                                  RSrc1_Ereg;
reg [ 4 : 0 ]                                  RSrc2_Ereg;



// Execute cycle out regs


reg  [ dataWidth - 1 : 0 ]                    ALU_Result_SMreg;
reg  [ dataWidth - 1 : 0 ]                    WriteData_SMreg;
reg  [ 4 : 0 ]                                RD_SMreg;
reg  [ dataWidth - 1 : 0 ]                    Program_counter_Increamented_SMreg;
reg                                           RegWrite_SMreg;
reg                                           ResSource_SMreg;
reg                                           MemWrite_SMreg;


// Memory Cycle out regs

reg                                           RegWrite_SWreg;
reg                                           ResSource_SWreg;
reg  [ 4 : 0 ]                                RD_SWreg;
reg  [ dataWidth - 1 : 0 ]                    ALU_Result_SWreg;
reg  [ dataWidth - 1 : 0 ]                    Program_counter_Increamented_SWreg;
reg  [ dataWidth - 1 : 0 ]                    ReadData_SWreg;



// Fetch Cycle inst

RISCV_Pipe_Fetch_Cycle fetch_cycle_inst (
    .clk(clk),
    .rstn(rstn),
    .PC_Source_SE(PC_Source_SEF_w),
    .PC_Target_SE(PC_Target_SEF_w),

    .Instruction_mem_out_SF(Instruction_mem_out_SD_w),
    .Program_Counter_SF(Program_Counter_SD_w),
    .Program_counter_Increamented_SF(Program_counter_Increamented_SD_w)
);

// Decode cycle inst

RISCV_Pipe_Decode_Cycle decode_cycle_inst (
    .clk(clk),
    .rstn(rstn),
    .RegWrite_SW(RegWrite_SWD_w),
    .RD_SW(RD_SWD_w), 
    .Program_Counter_SF(Program_Counter_SDreg),
    .Program_counter_Increamented_SF(Program_counter_Increamented_SDreg),
    .Instruction_mem_out_SF(Instruction_mem_out_SDreg),
    .Result_SW(Result_SWD_w),

    .RegWrite_SD (RegWrite_SE_w),
    .ALUSource_SD(ALUSource_SE_w),
    .MemWrite_SD(MemWrite_SE_w),
    .ResSource_SD(ResSource_SE_w),
    .RD_SD(RD_SE_w),
    .ALU_Ctrl_SD(ALU_Ctrl_SE_w),
    .ReadData_1_SD(ReadData_1_SE_w),
    .ReadData_2_SD(ReadData_2_SE_w),
    .Immediate_SD(Immediate_SE_w), 
    .Program_Counter_SD(Program_Counter_SE_w),
    .Program_counter_Increamented_SD(Program_counter_Increamented_SE_w),
    .Branch_SD(Branch_SE_w),
    .RSrc1_D(RSrc1_E_w),
    .RSrc2_D(RSrc2_E_w)
);


// Execute Cycle inst

RISCV_Pipe_Execute_Cycle execute_cycle_inst (
    .clk(clk),
    .rstn(rstn),
    .RegWrite_SD (RegWrite_SEreg),
    .ALUSource_SD(ALUSource_SEreg),
    .MemWrite_SD(MemWrite_SEreg),
    .ResSource_SD(ResSource_SEreg),
    .RD_SD(RD_SEreg),
    .Branch_SD(Branch_SEreg),
    .ALU_Ctrl_SD(ALU_Ctrl_SEreg),
    .ReadData_1_SD(ReadData_1_SEreg),
    .ReadData_2_SD(ReadData_2_SEreg),
    .Immediate_SD(Immediate_SEreg), 
    .Program_Counter_SD(Program_Counter_SEreg),
    .Program_counter_Increamented_SD(Program_counter_Increamented_SEreg),
    .ALU_Result_SM(ALU_Result_SW_w),
    .Result_SW(Result_SWD_w),
    .ForwardA_E_HU(ForwardA_E_w),
    .ForwardB_E_HU(ForwardB_E_w),

    .PC_Source_SE(PC_Source_SEF_w),
    .PC_Target_SE(PC_Target_SEF_w),
    .ALU_Result_SE(ALU_Result_SM_w),
    .WriteData_SE(WriteData_SM_w),
    .RD_SE(RD_SM_w),
    .Program_counter_Increamented_SE(Program_counter_Increamented_SM_w),
    .RegWrite_SE(RegWrite_SM_w),
    .ResSource_SE(ResSource_SM_w),
    .MemWrite_SE(MemWrite_SM_w)
);

// Memory Cycle inst

RISCV_Pipe_Memory_Cycle memory_cycle_inst (
    .clk(clk),
    .rstn(rstn),

    
    .ALU_Result_SE(ALU_Result_SMreg),
    .WriteData_SE(WriteData_SMreg),
    .RD_SE(RD_SMreg),
    .Program_counter_Increamented_SE(Program_counter_Increamented_SMreg),
    .RegWrite_SE(RegWrite_SMreg),
    .ResSource_SE(ResSource_SMreg),
    .MemWrite_SE(MemWrite_SMreg),

    .RegWrite_SM(RegWrite_SW_w),
    .ResSource_SM(ResSource_SW_w),
    .RD_SM(RD_SW_w),
    .ALU_Result_SM(ALU_Result_SW_w),
    .Program_counter_Increamented_SM(Program_counter_Increamented_SW_w),
    .ReadData_SM(ReadData_SW_w)

);



// Write back cycle inst

RISCV_Pipe_WriteBack_Cycle write_back_cycle_isnt (
    .clk(clk),
    .rstn(rstn),

    .RegWrite_SM(RegWrite_SWreg),
    .ResSource_SM(ResSource_SWreg),
    .RD_SM(RD_SWreg),
    .ALU_Result_SM(ALU_Result_SWreg),
    .Program_counter_Increamented_SM(Program_counter_Increamented_SWreg),
    .ReadData_SM(ReadData_SWreg),


    .RegWrite_SW(RegWrite_SWD_w),
    .Result_SW(Result_SWD_w),
    .RD_SW(RD_SWD_w)
);





// Fetch Cycle Pipeline

always @(posedge clk or negedge rstn) 
begin
    if ( !rstn )
    begin
        Instruction_mem_out_SDreg           <=      { ( dataWidth - 1 ) {1'b0}};
        Program_Counter_SDreg               <=      { ( dataWidth - 1 ) {1'b0}};
        Program_counter_Increamented_SDreg  <=      { ( dataWidth - 1 ) {1'b0}};
    end
    else
    begin
        Instruction_mem_out_SDreg           <=      Instruction_mem_out_SD_w;
        Program_Counter_SDreg               <=      Program_Counter_SD_w;
        Program_counter_Increamented_SDreg  <=      Program_counter_Increamented_SD_w;
    end
end

// Decode Cycle Pipeline

always @(posedge clk or negedge rstn) 
begin
    if ( !rstn )
    begin
        RegWrite_SEreg                       <=      1'b0;
        ALUSource_SEreg                      <=      1'b0;
        MemWrite_SEreg                       <=      1'b0;
        ResSource_SEreg                      <=      1'b0;
        RD_SEreg                             <=      { 5 {1'b0}};
        ALU_Ctrl_SEreg                       <=      { 3 {1'b0}};
        ReadData_1_SEreg                     <=      { ( dataWidth - 1 ) {1'b0}};
        ReadData_2_SEreg                     <=      { ( dataWidth - 1 ) {1'b0}};
        Immediate_SEreg                      <=      { ( dataWidth - 1 ) {1'b0}};
        Program_Counter_SEreg                <=      { ( dataWidth - 1 ) {1'b0}};
        Program_counter_Increamented_SEreg   <=      { ( dataWidth - 1 ) {1'b0}};
        Branch_SEreg                         <=      1'b0;      
        RSrc1_Ereg                           <=      { 5 {1'b0}};
        RSrc2_Ereg                           <=      { 5 {1'b0}};
    end
    else
    begin
        RegWrite_SEreg                       <=     RegWrite_SE_w; 
        ALUSource_SEreg                      <=     ALUSource_SE_w;
        MemWrite_SEreg                       <=     MemWrite_SE_w;
        ResSource_SEreg                      <=     ResSource_SE_w;
        RD_SEreg                             <=     RD_SE_w;
        ALU_Ctrl_SEreg                       <=     ALU_Ctrl_SE_w;
        ReadData_1_SEreg                     <=     ReadData_1_SE_w;
        ReadData_2_SEreg                     <=     ReadData_2_SE_w;
        Immediate_SEreg                      <=     Immediate_SE_w;
        Program_Counter_SEreg                <=     Program_Counter_SE_w;
        Program_counter_Increamented_SEreg   <=     Program_counter_Increamented_SE_w;
        Branch_SEreg                         <=     Branch_SE_w;
        RSrc1_Ereg                           <=     RSrc1_E_w;
        RSrc2_Ereg                           <=     RSrc2_E_w;
        
    end
end


// Execute cycle Pipeline

always @(posedge clk or negedge rstn) 
begin
    if ( !rstn )
    begin

        ALU_Result_SMreg                     <=      { ( dataWidth - 1 ) {1'b0}};
        WriteData_SMreg                      <=      { ( dataWidth - 1 ) {1'b0}};
        RD_SMreg                             <=      { 5 {1'b0}};
        Program_counter_Increamented_SMreg   <=      { ( dataWidth - 1 ) {1'b0}};
        RegWrite_SMreg                       <=      1'b0;
        ResSource_SMreg                      <=      1'b0;
        MemWrite_SMreg                       <=      1'b0;  
    end
    else
    begin

        ALU_Result_SMreg                     <=      ALU_Result_SM_w;
        WriteData_SMreg                      <=      WriteData_SM_w;
        RD_SMreg                             <=      RD_SM_w;
        Program_counter_Increamented_SMreg   <=      Program_counter_Increamented_SM_w;
        RegWrite_SMreg                       <=      RegWrite_SM_w;
        ResSource_SMreg                      <=      ResSource_SM_w;
        MemWrite_SMreg                       <=      MemWrite_SM_w; 
        
        
    end
end

// Memory Cycle Pipeline

always @(posedge clk or negedge rstn) 
begin
    if ( !rstn )
    begin
        RegWrite_SWreg                      <=      1'b0;
        ResSource_SWreg                     <=      1'b0;
        RD_SWreg                            <=      { 5 {1'b0}};
        ALU_Result_SWreg                    <=      { ( dataWidth - 1 ) {1'b0}};
        Program_counter_Increamented_SWreg  <=      { ( dataWidth - 1 ) {1'b0}};
        ReadData_SWreg                      <=      { ( dataWidth - 1 ) {1'b0}};
    
    end

    else
    begin
        RegWrite_SWreg                      <=      RegWrite_SW_w;
        ResSource_SWreg                     <=      ResSource_SW_w;
        RD_SWreg                            <=      RD_SW_w;
        ALU_Result_SWreg                    <=      ALU_Result_SW_w;
        Program_counter_Increamented_SWreg  <=      Program_counter_Increamented_SW_w;
        ReadData_SWreg                      <=      ReadData_SW_w;
    end

end





// Hazard Unit inst

RISCV_Hazard_Unit hazard_unit_inst (

    .rstn(rstn),

    .RegWrite_M(RegWrite_SW_w),
    .RegWrite_W(RegWrite_SWD_w),
    .RD_M(RD_SW_w),
    .RD_W(RD_SWD_w),
    .RSrc1_E(RSrc1_Ereg),
    .RSrc2_E(RSrc2_Ereg),

    .ForwardA_E(ForwardA_E_w),
    .ForwardB_E(ForwardB_E_w)
);

endmodule