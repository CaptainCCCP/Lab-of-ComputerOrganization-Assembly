module dm(Data_in,MemWr,Addr,clk,rst,Data_out,lb_sel,sb_sel);
  input [31:0]Data_in,Addr;
  input clk,rst,MemWr,lb_sel,sb_sel;
  output reg[31:0]Data_out;
  
  reg [7:0]DataMem[12287:0];
  wire [9:0]pointer;
  assign pointer=Addr[13:0];
  //reset
  integer i;
  
  always@(posedge clk or negedge rst)begin
  if(!rst)begin
	 if(MemWr==1)begin
      if(sb_sel==1)begin
              DataMem[pointer+0]<=Data_in[7:0];
             end
    else if(sb_sel==0)begin
      DataMem[pointer+3]<=Data_in[31:24];
      DataMem[pointer+2]<=Data_in[23:16];
      DataMem[pointer+1]<=Data_in[15:8];
      DataMem[pointer+0]<=Data_in[7:0];
    end
  end
  end
    //store word
  else if(rst) begin
  for(i=0;i<4999;i=i+1)
    DataMem[i]=0;
	 for(i=4999;i<9990;i=i+1)
    DataMem[i]=0;
	 for(i=9990;i<12288;i=i+1)
    DataMem[i]=0;
	 end
  
  end
  
  always@(negedge clk)begin
    //load word
  if(MemWr==0)begin
    if(lb_sel==1) begin
        if(DataMem[pointer][7]==0)begin
            Data_out<={24'b0,DataMem[pointer]};
          end
        else if(DataMem[pointer][7]==1)begin
           Data_out<={24'b111111111111111111111111,DataMem[pointer]};
        end
      end
    else if(lb_sel==0)begin
    Data_out<={DataMem[pointer+3],DataMem[pointer+2],DataMem[pointer+1],DataMem[pointer]};
    end
  end
end
endmodule
    
    
  
