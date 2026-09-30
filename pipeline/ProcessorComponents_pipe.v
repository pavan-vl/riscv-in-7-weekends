module RISCV_ALU  #(parameter dataWidth = 32 )  (
input   [ dataWidth - 1 : 0 ]             a,
input   [ dataWidth - 1 : 0 ]             b,
input   [ 2 : 0 ]                         alu_ctrl,
output  [ dataWidth - 1 : 0 ]             alu_out,
output                                    Z_flag_o, 
output                                    N_flag_o, 
output                                    V_flag_o, 
output                                    C_flag_o
);

wire [dataWidth - 1 : 0 ]           a_and_b, a_or_b,not_b, mux_21_o,mux_41_o, sum, slt,out;
wire                                xnor_v, xor_v, not_alu_ctrl_1;
wire                                v_res,z_res,n_res,c_res;
wire                                cout;

assign not_alu_ctrl_1   =      ~alu_ctrl[1];
assign xnor_v           =      ~ (a[dataWidth - 1] ^ b[dataWidth - 1] ^ alu_ctrl [ 0 ] );
assign xor_v            =      a[dataWidth - 1] ^ sum[dataWidth - 1];

assign c_res            =      cout & not_alu_ctrl_1;
assign v_res            =      not_alu_ctrl_1 & xnor_v & xor_v;
  
assign a_and_b      =   a&b;
assign a_or_b       =   a|b;
assign not_b        =   ~b;
assign mux_21_o     =   (alu_ctrl[0])? not_b : b;
assign {cout,sum}   =   a + mux_21_o + alu_ctrl[0];
assign mux_41_o     =   ((alu_ctrl[2:0]==3'b000)?sum: ((alu_ctrl[2:0]==3'b001)?sum: ((alu_ctrl[2:0]==3'b010)?a_and_b: ((alu_ctrl[2:0]==3'b011)? a_or_b: ((alu_ctrl[2:0]==3'b101)?slt:32'd0)))));
assign out          =   mux_41_o;
assign alu_out      =   out;

assign slt          =   { {(dataWidth - 1) {1'b0} } ,( sum[dataWidth - 1 ] ) } ;

assign n_res            =       ~out[dataWidth - 1];
assign z_res            =       &(~out);
assign V_flag_o         =       v_res;
assign Z_flag_o         =       z_res;
assign N_flag_o         =       n_res;
assign C_flag_o         =       c_res;

endmodule





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

assign ReadData_1   =   (!rstn || ReadAddr_1 == 0)                                 ? {dataWidth{1'b0}} :
                        (Write_En && (WriteAddr == ReadAddr_1))                     ? WriteData         :
                                                                                      RegFile_Mem[ReadAddr_1];
assign ReadData_2   =   (!rstn || ReadAddr_2 == 0)                                 ? {dataWidth{1'b0}} :
                        (Write_En && (WriteAddr == ReadAddr_2))                     ? WriteData         :
                                                                                      RegFile_Mem[ReadAddr_2];

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
        if (Write_En && (WriteAddr != 0)) 
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


module RISCV_Extender_Block #(parameter dataWidth = 32) (
    input   [dataWidth - 1 : 0]     instrction_i,
    input   [ 1 : 0 ]               immediate_source_i,
    output  [dataWidth - 1 : 0]     Immediate_o
);

assign Immediate_o = (immediate_source_i == 2'b00) ? { {20{instrction_i[31]}}, instrction_i[31:20] }                     :   // I-type
                     (immediate_source_i == 2'b01) ? { {20{instrction_i[31]}}, instrction_i[31:25], instrction_i[11:7] } :   // S-type
                                                     {dataWidth{1'b0}}                                                    ;

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



module RISCV_3_to_1_MUX #(parameter dataWidth = 32) (
    input   [dataWidth - 1 : 0]   In1,
    input   [dataWidth - 1 : 0]   In2,
    input   [dataWidth - 1 : 0]   In3,
    input   [ 1 : 0 ]             sel_line,
    output  [dataWidth - 1 : 0]   MuxOut_o

);



assign MuxOut_o = (sel_line == 2'b00) ? In1                 :
                  (sel_line == 2'b01) ? In2                 :
                  (sel_line == 2'b10) ? In3                 :
                                        {dataWidth{1'b0}}   ;

endmodule