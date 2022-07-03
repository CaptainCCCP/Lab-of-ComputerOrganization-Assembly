module output32(
input clk,
input rst,
input WeDEVO,
input [1:0]DEV_Addr,
input [31:0]Din,
output reg[31:0]Dout
 ); 

reg [31:0] r1,r2;

always@(posedge clk or negedge rst)begin
if(!rst)begin
	if(WeDEVO)
	begin
    if(DEV_Addr==2'b00) r1=Din;//preset
    if(DEV_Addr==2'b01) r2=Din;
	end
 Dout<=(DEV_Addr==2'b00)?r1:(DEV_Addr==2'b01)?r2:Dout;//addr0 r1,addr1 r2
  end
else if(rst)begin
  Dout<=Din;
  end
end
endmodule