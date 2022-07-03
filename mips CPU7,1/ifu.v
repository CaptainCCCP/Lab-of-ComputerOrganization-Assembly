module ifu(nPC_sel,zero,clk,rst,instruction,j_sel,jValue,jrValue,jalsw,PCWr,jalr_en,epc);
  input clk,rst;
  input [2:0]nPC_sel;
  input [31:0]zero;
  input [31:0]epc;
  input j_sel,jalr_en;
  input PCWr;
  input [25:0]jValue;
  input [31:0]jrValue;
  output [31:0]instruction,jalsw;
  
  
  
  reg [31:0]pc;
  reg [7:0]im[8191:0];
  reg [31:0]pcnew;
  wire [31:0]temp,t0,t1,t2,t3,t4;
  wire [15:0]imm16;
  reg [31:0]extout;
  
  
  initial
  begin
     // $readmemh("try.txt",im,'h0000);
    $readmemh("p3t1.txt",im,'h0000);
    $readmemh("p3t2.txt",im,'h0034);
  end
  
  assign instruction={im[(pc[14:0])-15'h3000],im[(pc[14:0]+1)-15'h3000],im[(pc[14:0]+2)-15'h3000],im[(pc[14:0]+3)-15'h3000]};
  assign imm16=instruction[15:0];
  
  assign temp={{16{imm16[15]}},imm16};//branch
  //j
  always@(*)begin
    if(j_sel==1)begin
      extout={pc[31:28],jValue[25:0],2'b0};
    end
      if(j_sel==0)begin
      extout={temp[31:0]<<2};//{14{imm[15]},imm16}//beq
    end
  end
    //beq ext18(16<<2)    j ext28(address<<2)+[3:0]pc+4
    
    
    
  assign t0=pc+4;
  assign t1=t0+extout;//mux
  assign t2=jrValue;
  assign t3=epc;
  assign jalsw=t0;
  assign t4=epc;
  //npc
  always@(*)
  begin
    if(PCWr==1)begin
      if(nPC_sel==3'b000)begin
        if(jalr_en==1)begin
          pcnew=t2;
        end
      else if(jalr_en==0)begin
      pcnew=t0;//+4
    end
     end
     else if(nPC_sel==3'b001)begin
      pcnew=t1;//branch beq
     end
     else if(nPC_sel==3'b011)begin
      pcnew=t2;//jrValue
      end
     else if(nPC_sel==3'b010)begin//j/jal
       if(zero==0)begin
        pcnew=t1;
       end
    else if(nPC_sel==3'b101)begin
      pcnew=t4;//eret
      end
    else if(nPC_sel==3'b100)begin
      pcnew=32'h0000_4180;//int
      end
     else begin
      pcnew=t0;
      end
    end
    end
  end
  
  //pc
  //reset
  always@(posedge clk or posedge rst)
	begin
	if(rst)begin
	pc=32'h0000_3000;
	end
   else begin
	if(PCWr)begin
    if(j_sel==0)pc=pcnew;
    if(j_sel==1)pc=extout;
            end
		end
	end
endmodule
    