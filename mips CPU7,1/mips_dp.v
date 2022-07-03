module mips_dp(clk,rst,RegDst,RegWr,ExtOp,nPC_sel,ALUctr,MemtoReg,MemWr,ALUSrc,j_sel,
Instruction,jal_sel,lb_sel,IRWr,sb_sel,PCWr,PrRD,PrWD,PrAddr,Din_sel,jalr_en,cp0_wr,IntReq,epc);
input clk,rst;
input [1:0]ExtOp;
input [2:0]nPC_sel;
input [3:0]ALUctr;
input [31:0]PrRD,cp0_wr,epc;//Din,cp0dout epc
input [1:0]Din_sel;
input ALUSrc,MemWr,MemtoReg,RegDst,RegWr,j_sel,jal_sel,lb_sel,sb_sel,IRWr,PCWr,jalr_en,IntReq;
wire [31:0]instruction,IRinstruction;
wire [31:0]busB,busA,busW,Mux_ALUSrc_out,imm32,Alu_out,ALUoutD,Data_out,jValue,jrValue,jalsw,AbusA,BbusB,DMbusW;
wire [31:0]zero;
wire [4:0]rw;
wire over;
wire [31:0]RFWrD;
output [31:0]Instruction,PrWD,PrAddr;
assign Instruction[31:0]=IRinstruction[31:0];
assign PrWD = BbusB;
assign PrAddr = ALUoutD;
//connect all compoenet
ifu IFU(.nPC_sel(nPC_sel),.zero(zero),.clk(clk),.rst(rst),.instruction(instruction),.j_sel(j_sel),.jValue(instruction[25:0]),.jrValue(AbusA),.jalsw(jalsw),.PCWr(PCWr),.jalr_en(jalr_en),.epc(epc));
ext EXT(.imm16(IRinstruction[15:0]),.imm32(imm32),.ExtOp(ExtOp));
alu ALU(.busA(AbusA),.busB(Mux_ALUSrc_out),.ALUctr(ALUctr),.zero(zero),.Alu_out(Alu_out),.over(over));
mux_RegDst MUX_RegDst(.a0(IRinstruction[20:16]),.a1(IRinstruction[15:11]),.rw(rw),.RegDst(RegDst));//0 a0 rt   1 a1 rd
mux MUX_ALUSrc(.a0(BbusB),.a1(imm32),.op(ALUSrc),.out(Mux_ALUSrc_out));
mux MUX_MemtoReg(.a0(Alu_out),.a1(Data_out),.op(MemtoReg),.out(busW));//
muxm MUX_RegWr(.a0(DMbusW),.a1(ALUoutD),.a2(cp0_wr),.a3(PrRD),.op(Din_sel),.out(RFWrD));
gpr GPR(.RegWr(RegWr),.ra(IRinstruction[25:21]),.rb(IRinstruction[20:16]),.rw(rw),.busW(RFWrD),.clk(clk),.rst(rst),.busA(busA),.busB(busB),.jalsw(jalsw),.jal_sel(jal_sel),.over(over));
dm DM(.Data_in(BbusB),.MemWr(MemWr),.Addr(ALUoutD),.clk(clk),.rst(rst),.Data_out(Data_out),.lb_sel(lb_sel),.sb_sel(sb_sel));
ir IR(.clk(clk),.IRWr(IRWr),.imin(instruction),.imout(IRinstruction));
delay ADR(.clk(clk),.in(busA),.out(AbusA));
delay BDR(.clk(clk),.in(busB),.out(BbusB));
delay ALUoutDR(.clk(clk),.in(Alu_out),.out(ALUoutD));
delay DDR(.clk(clk),.in(busW),.out(DMbusW));


endmodule