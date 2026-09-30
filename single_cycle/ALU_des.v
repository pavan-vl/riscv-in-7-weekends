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
