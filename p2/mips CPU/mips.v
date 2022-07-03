module mips(clk,rst,PrAddr,PrDIn,PrDOut,Wen,HWInt);
  input clk,rst;
  
  input [31:0]PrDIn;
  input [5:0] HWInt;
  output [31:0] PrAddr,PrDOut;
  output Wen;
  
  wire [1:0]ExtOp,nPC_sel;
  wire [3:0]ALUctr;
  wire ALUSrc,MemWr,MemtoReg,RegDst,RegWr,j_sel,jal_sel,jr_sel,lb_sel,IRWr,PCWr;
  wire [31:0]instruction;
  wire jalr_en;
  wire [31:0]epc,cp0_out;
  
  
  ctrl CU(.instruction(instruction),.RegDst(RegDst),.RegWr(RegWr),.ExtOp(ExtOp),.nPC_sel(nPC_sel),.ALUctr(ALUctr),.MemtoReg(MemtoReg),.MemWr(MemWr),.ALUSrc(ALUSrc),.j_sel(j_sel),.jal_sel(jal_sel),.lb_sel(lb_sel),.sb_sel(sb_sel),.PCWr(PCWr),.IRWr(IRWr),.clk(clk),.rst(rst),.jalr_en(jalr_en));
  mips_dp MAIN(.clk(clk),.rst(rst),.RegDst(RegDst),.RegWr(RegWr),.ExtOp(ExtOp),.nPC_sel(nPC_sel),.ALUctr(ALUctr),.MemtoReg(MemtoReg),.MemWr(MemWr),.ALUSrc(ALUSrc),.j_sel(j_sel),.Instruction(instruction),
  .jal_sel(jal_sel),.lb_sel(lb_sel),.sb_sel(sb_sel),.PCWr(PCWr),.IRWr(IRWr),.PrRD(PrDIn),.PrWD(PrDOut),.PrAddr(PrAddr),.jalr_en(jalr_en));
endmodule
  
