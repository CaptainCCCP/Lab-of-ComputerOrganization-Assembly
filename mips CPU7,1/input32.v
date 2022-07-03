module input32(
input [31:0]din,
output [31:0]dout,
input [1:0]DEV_Addr,
input clk,
input rst
 ); 
 //
reg [31:0]OD;
//
assign dout=OD;
//
always@(*)
OD=din;
endmodule