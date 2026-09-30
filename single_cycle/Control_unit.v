module RISCV_Control_Unit 
(
    input                   Z_flag_i,
    input   [6 : 0]         opCode_i,
    input   [2 : 0]         func3_i,
    input                   func7_5b_i,
    output  [2 : 0]         ALU_Ctrl_o,
    output                  RegWrite_o,
    output                  MemWrite_o,
    output                  ResSource_o,
    output                  ALUSource_o,
    output                  PCSource_o,
    output  [1 : 0]         ImmeSource_o

);

wire    [1 : 0]         ALU_Operation_int;

RISCV_CU_Main_Deocder   main_decoder_inst   (
    .Z_flag(Z_flag_i),
    .opCode(opCode_i),
    .RegWrite(RegWrite_o),
    .MemWrite(MemWrite_o),
    .ResSource(ResSource_o),
    .ALUSource(ALUSource_o),
    .PCSource(PCSource_o),
    .ImmeSource(ImmeSource_o),
    .ALUOperation(ALU_Operation_int)
);


RISCV_CU_ALU_Decoder    alu_decoder_inst    (
    .func3(func3_i),
    .func7_5b(func7_5b_i),
    .opCode_5b(opCode_i[5]),
    .ALUOperation_i(ALU_Operation_int),
    .ALU_Ctrl(ALU_Ctrl_o)
);

endmodule


module RISCV_CU_Main_Deocder (
    input                   Z_flag,
    input   [6:0]           opCode,
    output                  RegWrite,
    output                  MemWrite,
    output                  ResSource,
    output                  ALUSource,
    output                  PCSource,
    output  [1:0]           ImmeSource,
    output  [1:0]           ALUOperation
);
    wire                        Branch_w;
    
    assign  RegWrite        =  ((opCode == 7'h3) | (opCode ==  7'h33))?    1'b1    :   1'b0;

    assign  MemWrite        =  (opCode ==  7'h23)?     1'b1    :   1'b0;
    assign  ResSource       =  (opCode  ==  7'h3)?      1'b1     :    ( (opCode   ==  7'h23)?     1'bX    :   1'b0  );
    assign  ALUSource       =  ((opCode == 7'h3) | (opCode ==  7'h23))?    1'b1    :   1'b0;
    assign  Branch_w        =  (opCode ==  7'h63)?     1'b1    :   1'b0;
    assign  ALUOperation    =  (opCode == 7'h33)?   2'b10   :   (   (opCode == 7'h63)?  2'b01   :   2'b00   );
    assign  ImmeSource      =  (opCode == 7'h33)?   2'bXX   :   (   (opCode == 7'h63)?  2'b10   :   (   (opCode == 7'h23)?  2'b01   :   2'b00  )   );
    assign  PCSource        =  Branch_w    &   Z_flag;

endmodule


module RISCV_CU_ALU_Decoder (
    input   [2 : 0]             func3,
    input                       func7_5b,
    input                       opCode_5b,
    input   [1 : 0]             ALUOperation_i,
    output  [2 : 0]             ALU_Ctrl
);

reg [2 : 0]         ALU_Ctrl_reg=0;

always @(*) 
begin
    
    case (ALUOperation_i)
        2'b00: 
        begin
            ALU_Ctrl_reg    =   3'd0;
        end

        2'b01:
        begin
            ALU_Ctrl_reg    =   3'b001;
        end

        2'b10:
        begin
            if (func3   ==  3'b000) 
            begin
                if ({opCode_5b,func7_5b}    ==  2'b11) 
                begin
                    ALU_Ctrl_reg    =   3'b001;
                end
                else
                begin
                    ALU_Ctrl_reg    =   3'b000;
                end
            end
            else if (func3  ==  3'b010) 
            begin
                ALU_Ctrl_reg    =   3'b101;
            end
            else if (func3  ==  3'b110) 
            begin
                ALU_Ctrl_reg    =   3'b011;
            end
            else if (func3  ==  3'b111) 
            begin
                ALU_Ctrl_reg    =   3'b010;
            end
            else
            begin
                ALU_Ctrl_reg    =   3'bXXX;
            end
        end

        default: 
        begin
            ALU_Ctrl_reg    =   3'bXXX;
        end 
    endcase
    
end

assign  ALU_Ctrl    =   ALU_Ctrl_reg;

endmodule
