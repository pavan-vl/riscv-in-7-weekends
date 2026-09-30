module RISCV_Hazard_Unit #(
    parameter   dataWidth   =   32
) (

    input                                               rstn,

    input                                               RegWrite_M,
    input                                               RegWrite_W,
    input   [ 4 : 0 ]                                   RD_M,
    input   [ 4 : 0 ]                                   RD_W,
    input   [ 4 : 0 ]                                   RSrc1_E,
    input   [ 4 : 0 ]                                   RSrc2_E,

    output  [ 1 : 0 ]                                   ForwardA_E,
    output  [ 1 : 0 ]                                   ForwardB_E
);


assign ForwardA_E = (!rstn)                                                    ? 2'b00 :
                    (RegWrite_M && (RD_M != 5'h00) && (RD_M == RSrc1_E))       ? 2'b10 :
                    (RegWrite_W && (RD_W != 5'h00) && (RD_W == RSrc1_E))       ? 2'b01 :
                                                                                 2'b00 ;

assign ForwardB_E = (!rstn)                                                    ? 2'b00 :
                    (RegWrite_M && (RD_M != 5'h00) && (RD_M == RSrc2_E))       ? 2'b10 :
                    (RegWrite_W && (RD_W != 5'h00) && (RD_W == RSrc2_E))       ? 2'b01 :
                                                                                 2'b00 ;

endmodule