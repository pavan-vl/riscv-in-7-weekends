module RISCV_Instruction_Memory #(parameter dataWidth = 32) (
    input   [dataWidth - 1 : 0]          Addr_in,
    input                                rstn,
    output  [dataWidth - 1 : 0]          ReadData
);
    

reg [dataWidth - 1 : 0 ]        Ins_Mem     [1023 : 0] ;


assign  ReadData    =   (!rstn)?  ( { (dataWidth-1) { 1'b0 } } ):  Ins_Mem[Addr_in[31:2]];



endmodule


module RISCV_ProgramCounter #(parameter dataWidth = 32) (
    input          [dataWidth - 1 : 0]     PC_Next,
    input                                  clk,
    input                                  rstn,
    output  reg    [dataWidth - 1 : 0]     PC_o   
);
    always @(posedge clk) 
    begin
        if (!rstn) 
        begin
            PC_o        <=  {(dataWidth - 1){1'b0}};
        end
        else
        begin
            PC_o        <=  PC_Next;
        end 
    end 

endmodule

module RISCV_Register_File #(parameter dataWidth = 32, addrWidth = 5) (
    input                               clk,
    input                               rstn,
    input                               Write_En,
    input   [addrWidth - 1 : 0]         ReadAddr_1,
    input   [addrWidth - 1 : 0]         ReadAddr_2,
    input   [addrWidth - 1 : 0]         WriteAddr,
    input   [dataWidth - 1 : 0]         WriteData,
    output  [dataWidth - 1 : 0]         ReadData_1,
    output  [dataWidth - 1 : 0]         ReadData_2
    
);
integer i = 0;

reg     [dataWidth - 1 : 0]     RegFile_Mem     [31 : 0] ;

assign ReadData_1   =   (!rstn)?    ( { ( dataWidth - 1 ) { 1'b0 } } )  :   RegFile_Mem[ReadAddr_1];
assign ReadData_2   =   (!rstn)?    ( { ( dataWidth - 1 ) { 1'b0 } } )  :   RegFile_Mem[ReadAddr_2];

always @(posedge clk) 
begin
    if (!rstn) 
    begin
        for (i = 0; i<32 ;i=i+1 ) begin
            RegFile_Mem[i]      <=      { ( dataWidth - 1 ) {1'b0} };
        end
    end
    else
    begin
        if (Write_En) 
        begin
            RegFile_Mem[WriteAddr]      <=      WriteData;
        end
        else
        begin
            RegFile_Mem[WriteAddr]      <=      RegFile_Mem[WriteAddr];
        end 
    end
end

endmodule


module RISCV_Data_Memory #(parameter dataWidth = 32, addrWidth = 32) (
    input                                   clk,
    input                                   rstn,
    input                                   Write_En,
    input   [addrWidth - 1 : 0]             Addr_in,
    input   [dataWidth - 1 : 0]             WriteData_i,
    output  [dataWidth - 1 : 0]             ReadData_o
);
reg [dataWidth - 1 : 0 ]    DataMemModMem   [1023:0] ;
assign ReadData_o   =   (Write_En == 1'b0)?    DataMemModMem[ Addr_in ]    :    32'd0;

integer i=0;
always @(posedge clk) 
begin
    if (!rstn) 
    begin
        for ( i = 0 ;i<1024 ;i=i+1 ) 
        begin
            DataMemModMem[i]        <=  { ( dataWidth - 1 ) {1'b0} };
        end
    end
    else
    begin
    
    
    
    if(Write_En)
    begin
        DataMemModMem[  Addr_in ]       <=      WriteData_i;
    end
    end
end
    
endmodule
