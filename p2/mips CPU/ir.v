module ir(input [31:0] imin,  
         input IRWr,  
         input clk, 
         output reg [31:0] imout);
always @(negedge clk) begin
        if(IRWr) imout <= imin;  
end
endmodule
