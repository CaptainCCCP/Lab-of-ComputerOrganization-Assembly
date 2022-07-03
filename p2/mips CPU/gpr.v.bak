module gpr(RegWr,ra,rb,rw,busW,clk,rst,busA,busB,jalsw,jal_sel,over);
  input clk,rst,RegWr,jal_sel,over;
  input [31:0]busW,jalsw;
  input [4:0]ra,rb,rw;//ra=rs;rb=rt
  output [31:0]busA,busB;
  
  reg [31:0]regi[31:0];
  
  //reset
  integer i;
  always@(posedge rst)
  begin
    if(rst)
      for(i=0;i<32;i=i+1)
      regi[i]=0;
    end
    
  //set busA & busB
  assign busA=regi[ra];//$rs
  assign busB=regi[rb];//$rt
  
  //Register write in
  always@(posedge clk)begin
    if(RegWr)begin
      if(jal_sel)begin
        regi[31]<=jalsw;
        regi[0]<=0;
      end
      if(over)begin
        regi[30]<=1;
        regi[0]<=0;
      end
      regi[rw]<=busW;
      regi[0]<=0;
    end
  end
endmodule