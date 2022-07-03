module test;
  reg clk,rst;
  reg [31:0]in;
  system sys(.clk(clk),.rst(rst),.in(in));
  
  initial begin
    in=32'h7;
    clk=1;
    rst=0;
    #1 rst=1;
    #1 rst=0;
    #20000 in=32'h44;
  end
  
  always
  #30 clk=~clk;
endmodule
