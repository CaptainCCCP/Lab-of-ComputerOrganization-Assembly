module cp0(
  input [31:0]pc,
  input [31:0]Din,
  input [5:0]HWint,
  input [4:0]Sel,//regsel
  input Wen,EXLSet,EXLClr,clk,rst,EpcWr,
  
  output IntReq,
  output reg [31:0]epc,
  output [31:0]Dout);
  
  reg [5:0]im;//sr
  reg [5:0] ip ;//cause
  reg [31:0]PrID;//PrID
  reg exl,ie;
  //4regs
  wire [31:0]SR,Cause;
  
  
  initial begin
    exl=0;ie=0;im=0;ip=0;
	 PrID = 32'h2007_4411;
  end
  
  assign IntReq=(|(HWint & im) & ie & !exl);

  //12:SR 13:CAUSE 14:EPC 15:PrID
  assign SR ={16'b0,im,8'b0,exl,ie};
  assign Cause ={16'b0, ip, 10'b0};
  
  assign DOut=(Sel==12)?SR:(Sel==13)?Cause:(Sel==14)?{epc[31:2],2'b00}:(Sel==15)?PrID:32'b0;

  always @(posedge clk or posedge rst)
    begin
	 if(rst)begin
      exl=0;ie=0;im=0;ip=0;
      end
	 else begin
        if(!Wen)
          begin
            if(EXLSet)        exl<=1'b1;
            else if(EXLClr)   exl<=1'b0;//out
                              ip=HWint;
            if(EpcWr)         epc<=pc;
          end
        if(Wen)
				if(IntReq)begin
				epc<=pc[31:2];
				end
          case(Sel)
            5'b01100:{im,exl,ie}<={Din[15:10],Din[1],Din[0]};//12  SR
            5'b01101:ip=Din[15:10];////////////////////////////13  CAUSE
            5'b01110:epc<=Din[31:2];///////////////////////////14  EPC
				5'b01111:PrID<=Din[31:0];//////////////////////////15  PrID
          endcase
			 end
    end   
  
endmodule