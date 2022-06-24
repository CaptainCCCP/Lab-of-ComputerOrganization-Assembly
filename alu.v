module alu(busA,busB,ALUctr,zero,Alu_out,Addr,over);
  input [31:0]busA,busB;
  input [3:0]ALUctr;
  
  output [31:0]zero,Addr;
  output reg over;
  output reg[31:0]Alu_out;
  
  //set ADD,SUB,OR
parameter ADD=4'b0000;
parameter SUB=4'b0001;
parameter OR= 4'b0010;
parameter AND=4'b0011;
parameter SLT=4'b0100;

  //three conditions
  always@(*)begin
    case(ALUctr)
      ADD:begin
        Alu_out=busA+busB;
        if((busA[31]==1'h0&&busB[31]==1'h0&&Alu_out[31]==1'h1) || (busA[31]==1'h1&&busB[31]==1'h1&&Alu_out[31]==1'h0))assign over=1'h1;
				else assign over=1'h0;
      end
      SUB:begin
        Alu_out=busA-busB;
      end
      OR:begin
        Alu_out=busA|busB;
      end
      SLT: begin
        Alu_out=($signed(busA)<$signed(busB))?32'h0000_0001:32'h0000_0000;
      end
        
    endcase
  end
  assign zero=Alu_out;
  assign Addr=Alu_out;
endmodule