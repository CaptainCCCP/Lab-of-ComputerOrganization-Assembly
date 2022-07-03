module muxm(a0,a1,a2,a3,op,out);
  input [1:0]op;
  input [31:0]a0,a1,a2,a3;
  output reg[31:0]out;
  
  always@(*)begin
    case(op)
    2'b00:begin
    out=a0;
    end
    2'b01:begin
    out=a1;
    end
    2'b10:begin
    out=a2;
    end
    2'b11:begin
    out=a3;
    end
  endcase
end
  endmodule
