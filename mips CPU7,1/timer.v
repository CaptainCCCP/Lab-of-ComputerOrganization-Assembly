module timer(
				input clk_i,
				input rst_i,
				input [1:0] add_i,	//addr
				input we_i,        //write en
				input [31:0] dat_i,//data in
				
				output [31:0] dat_o,//data out
				output reg IRQ
			);
			/////////////////////////////////////////////////////
	reg [31:0] CTRL;
	//[3]IM ping bi   [2:1]mode 00:mode0	01:mode1    [0]enable:count en
	reg [31:0] PRESET;//initial
	reg [31:0] COUNT;
	reg flag;
	//////////////////////////////////////////////////////
	assign dat_o=(add_i==2'b00)?CTRL:(add_i==2'b01)?PRESET:(add_i==2'b10)?COUNT:dat_o;
	
	initial
		begin
			CTRL = 32'b0;
			IRQ = 1'b0;
			flag =0;
		end
	
	
	always @(posedge clk_i or posedge rst_i)
		begin
		if(rst_i)
        begin
          CTRL=0;
          PRESET=0;
          COUNT=0;
        end
      else begin
		  if(we_i)begin
		    if (add_i==2'b00) begin
			 CTRL = dat_i;
			 end
		    else if (add_i==2'b01) begin
		            PRESET = dat_i; 
						flag = 1;
		                   end
		  end
		  case(CTRL[2:1])
            2'b00:begin
				if(!CTRL[0])  begin
					if(flag)COUNT<=PRESET;//pause
					else COUNT<=COUNT;
									end
				if(COUNT == 0)
						begin
							CTRL[0] <= 0;
							if(CTRL[3]==1) begin 
							   IRQ <= 1'b1; CTRL[3] <=0;
							end
						end
				else COUNT <= COUNT - 1;
				end
            2'b01:begin
					if(COUNT == 0)
						begin
							COUNT <= PRESET;
							if(CTRL[3]==1) begin
							IRQ <= 1'b1;
							CTRL[3] <=0;
							end
						end
					else if(CTRL[0]==1)begin
						COUNT <= COUNT - 1;
						end
			
                  end
          endcase
		  if(flag==1)flag<=0;
		  end
	end
endmodule