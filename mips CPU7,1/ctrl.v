module ctrl(instruction,RegDst,RegWr,ExtOp,nPC_sel,ALUctr,MemtoReg,MemWr,ALUSrc,
j_sel,jal_sel,lb_sel,sb_sel,PCWr,IRWr,clk,rst,Din_sel,jalr_en,
cp0_we,EXLSet,EXLClr,IntReq,dev_wen,PrAddr,epc_wr);
//
  input [31:0]instruction;
  input [15:0]PrAddr;
  input clk,rst;
  output reg [1:0]ExtOp,Din_sel;
  output reg [2:0]nPC_sel;
  output reg[3:0]ALUctr;
  output reg RegDst,RegWr,MemtoReg,MemWr,ALUSrc,j_sel,jal_sel,lb_sel,sb_sel,PCWr,IRWr,jalr_en;
    output reg cp0_we;
		output reg EXLSet;
		output reg EXLClr;
		input IntReq;
		output reg dev_wen;
		output reg epc_wr;
	//
parameter ADD=4'b0000;
parameter SUB=4'b0001;
parameter OR= 4'b0010;
parameter AND=4'b0011;
parameter SLT=4'b0100;
  wire [5:0]opcode,funct;
  wire [4:0]rs;
  reg [2:0]state,next_state;//||if:000   ||dcd/rf:001   ||exe:010   ||mem:011   ||wb:100
  
	parameter [5:0] j_op = 6'b000010;
	parameter [5:0] jal_op = 6'b000011;
	parameter [5:0] jr_op = 6'b000000		,jr_func = 6'b001000;
	parameter [5:0] addu_op = 6'b000000		,addu_func = 6'b100001;
	parameter [5:0] subu_op = 6'b000000		,subu_func = 6'b100011;
	parameter [5:0] slt_op = 6'b000000		,slt_func = 6'b101010;
	parameter [5:0] ori_op = 6'b001101;
	parameter [5:0] lw_op = 6'b100011;
	parameter [5:0] sw_op = 6'b101011;
	parameter [5:0] beq_op = 6'b000100;
	parameter [5:0] lui_op = 6'b001111;
	parameter [5:0] addi_op = 6'b001000;
	parameter [5:0] addiu_op = 6'b001001;
	parameter [5:0] lb_op = 6'b100000;
	parameter [5:0] sb_op = 6'b101000;
	parameter [5:0] jalr_func = 6'b001001;
	//
	parameter [5:0] mfc0_op = 6'b010000,	mfc0_rs = 5'b00000;
	parameter [5:0] mtc0_op = 6'b010000,	mtc0_rs = 5'b00100;
	parameter [5:0] eret_op = 6'b010000,	eret_rs = 5'b10000;
	//
  initial begin
    RegDst=0;
    RegWr=0;
    ExtOp=0;
    nPC_sel=0;//000:+4,001:beq,010:j/jal,011:jr 100?int  101?eret
    ALUctr=0;
    MemtoReg=0;
    MemWr=0;
    ALUSrc=0;
    j_sel=0;
    jal_sel=0;
    lb_sel=0;
    sb_sel=0;
    jalr_en=0;
    PCWr=1;
    IRWr=1;
    state = 3'b000;
end

assign opcode = instruction[31:26];
assign funct = instruction[5:0];
assign rs = instruction[25:21];
always @(posedge clk , posedge rst) 
		begin
		  if(rst==1)begin
		    state<=3'b000;
		    end
		   else begin
			   state <= next_state;
			   end
		end
		/////////////////////////////
		always@(*)begin
		
		  if((state == 3'b101)||(state == 3'b001 && opcode == mtc0_op && rs == mtc0_rs))
		    cp0_we =1;
		  else
		    cp0_we = 0;
		    
		  if(state == 3'b101)
		    EXLSet=1;
		  else
		    EXLSet=0;
		    
		  if(state==3'b001 && opcode == eret_op && rs == eret_rs && state == 3'b001)
        EXLClr=1;
      else
        EXLClr=0;   
        //
     if (state == 3'b011 && (opcode == sw_op || opcode == sb_op)&&(PrAddr>'h7eff)) dev_wen = 1;
      else dev_wen = 0;    
		//
		if(state == 3'b101)
		    epc_wr =1;
		  else
		    epc_wr = 0;
  end
///////////////////////////////////////
always @(state or opcode or funct) begin
		case(state)
			3'b000: //if
				begin
				 next_state = 3'b001;
				end
				
			3'b001: //rf
				begin
					case (opcode)
						jal_op:
							begin
								next_state = 3'b100;					// jal
							end
						default: 
							begin
									if(opcode == eret_op && rs == eret_rs)
									begin
										next_state = 3'b000;//eret
									end
									else
										next_state = 3'b010; //all other
							end
					endcase
				end
				
			3'b010: //exe
				begin
					case (opcode)
					  j_op:
					  begin
					    if(IntReq)begin
				          next_state = 3'b101;
				               end
					    else next_state = 3'b000;		
					    end
						beq_op: 
							begin
							  if(IntReq)begin
				          next_state = 3'b101;
				               end
								else next_state = 3'b000;				// beq
							end
						lw_op: 
							begin
								next_state = 3'b011;			 	// lw
							end
						sw_op: 
							begin
								next_state = 3'b011;				// sw
							end
						lb_op: 
							begin
								next_state = 3'b011;			 	// lb
							end
						sb_op: 
							begin
								next_state = 3'b011;				// sb
							end
						default:
							begin
							  if(funct==jr_func)begin
							    if(IntReq)begin
				          next_state = 3'b101;
				               end
							    else next_state = 3'b000;
							    end
							   else begin
								next_state = 3'b100;//wb 					//addi addiu subu addu ori slt lui
							end
							
end
					endcase
				end
			
			3'b011://mem
				begin
					if(opcode == lw_op || opcode == lb_op)
						begin
							next_state = 3'b100;						//lw lb
						end
					else 
						begin
						  if(IntReq)begin
				          next_state = 3'b101;
				               end
							else next_state = 3'b000;						//sw sb
						end			
				end
				
			3'b100: //wb
				begin
				   if(IntReq)begin
				    next_state = 3'b101;
				  end
					else	begin
					next_state = 3'b000;
					end
				end
			3'b101:
			begin
			   next_state = 3'b001;
			end
		endcase
	end	

//------------------------------------------------------------------------------------------------
 always @(state or opcode or funct or rs) begin  
   //
        case(opcode)
            6'b000000: 
            case(funct)
              addu_func:
                begin  // addu
					 if(IntReq && (state==3'b100||state==3'b011||state==3'b010||state==3'b101))begin
              {Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
                RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 19'b0000000001_00_100_0000;
						end
               else {Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
                RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 19'b0000000001_00_000_0000;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b100: {IRWr, MemWr, RegWr} = 3'b101;
                    3'b101: {IRWr, MemWr, RegWr} = 3'b000;
                endcase
                end
            subu_func:
                begin  // subu
					 if(IntReq && (state==3'b100||state==3'b011||state==3'b010||state==3'b101))begin
					 {Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
               RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0000000001_00_100_0001;
					 end
               else {Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
               RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0000000001_00_000_0001;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b100: {IRWr, MemWr, RegWr} = 3'b101;
                    3'b101: {IRWr, MemWr, RegWr} = 3'b000;
                endcase
                end
            slt_func: begin  // slt
				if(IntReq && (state==3'b100||state==3'b011||state==3'b010||state==3'b101))begin
				{Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
                RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0000000001_01_100_0100;
					 end
                else {Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
                RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0000000001_01_000_0100;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b100: {IRWr, MemWr, RegWr} = 3'b101;
                    3'b101: {IRWr, MemWr, RegWr} = 3'b000;
                endcase
                end
            jr_func: begin  // jr
				if(IntReq && (state==3'b100||state==3'b011||state==3'b010||state==3'b101))begin
				 {Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
              RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0000000000_00_100_0000;
					 end
              else{Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
              RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0000000000_00_011_0000;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b101: {IRWr, MemWr, RegWr} = 3'b000;
                endcase
                end
            jalr_func:
                begin  // jalr
					 if(IntReq && (state==3'b100||state==3'b011||state==3'b010||state==3'b101))begin
					 {Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
                RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0010001001_01_100_00010;
					 end
                else {Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
                RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0010001001_01_000_00010;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b100: {IRWr, MemWr, RegWr} = 3'b101;
                    3'b101: {IRWr, MemWr, RegWr} = 3'b000;
                endcase
                end
            endcase//R
            
            //I///////////////////////////////
            addi_op: begin  // addi
				if(IntReq && (state==3'b100||state==3'b011||state==3'b010||state==3'b101))begin
				{Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
              RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0001000000_01_100_0000;
					 end
              else {Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
              RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0001000000_01_000_0000;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b100: {IRWr, MemWr, RegWr} = 3'b101;
                    3'b101: {IRWr, MemWr, RegWr} = 3'b000;
                endcase
            end
            addiu_op: begin  // addiu
				if(IntReq && (state==3'b100||state==3'b011||state==3'b010||state==3'b101))begin
				{Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
              RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0001000000_01_100_0000;
					 end
             else {Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
              RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0001000000_01_000_0000;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b100: {IRWr, MemWr, RegWr} = 3'b101;
                    3'b101: {IRWr, MemWr, RegWr} = 3'b000;
                endcase
            end
            ori_op: begin  // ori
				if(IntReq && (state==3'b100||state==3'b011||state==3'b010||state==3'b101))begin
				{Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
              RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0001000000_00_100_0010;
					 end
             else {Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
              RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0001000000_00_000_0010;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b100: {IRWr, MemWr, RegWr} = 3'b101;
                    3'b101: {IRWr, MemWr, RegWr} = 3'b000;
                endcase
            end
            sw_op: begin  // sw
				if(IntReq && (state==3'b100||state==3'b011||state==3'b010||state==3'b101))begin
				{Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
             RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0001000000_01_100_0000;
					 end
             else {Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
             RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0001000000_01_000_0000;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b011: if(PrAddr<'h3000)begin
                                {IRWr, MemWr, RegWr} = 3'b110;
                            end
                    3'b101: {IRWr, MemWr, RegWr} = 3'b000;
                endcase
            end
            lw_op: begin  // lw
				if(IntReq && (state==3'b100||state==3'b011||state==3'b010||state==3'b101))begin
				{Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
              RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0001100000_01_100_0000;
					 end
              else {Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
              RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0001100000_01_000_0000;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b011: if(PrAddr<'h3000)begin
                              {IRWr, MemWr, RegWr} = 3'b100;
                            end
                    3'b100: if(PrAddr>'h7eff)begin
                            {IRWr, MemWr, RegWr} = 3'b101;
                            Din_sel<=2'b11;
                            end
                    3'b101: {IRWr, MemWr, RegWr} = 3'b000;
                endcase
            end
            sb_op: begin  // sb
				if(IntReq && (state==3'b100||state==3'b011||state==3'b010||state==3'b101))begin
				{Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
               RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0001000010_01_100_0000;
					 end
               else {Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
               RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0001000010_01_000_0000;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b011: if(PrAddr<'h3000)begin
                              {IRWr, MemWr, RegWr} = 3'b110;
                            end
                    3'b101: {IRWr, MemWr, RegWr} = 3'b000;
                endcase
            end
            lb_op: begin  // lb
				if(IntReq && (state==3'b100||state==3'b011||state==3'b010||state==3'b101))begin
				{Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
              RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0001100100_01_100_0000;
					 end
              else {Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
              RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0001100100_01_000_0000;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b011: if(PrAddr<'h3000)begin
                              {IRWr, MemWr, RegWr} = 3'b100;
                            end
                    3'b100: if(PrAddr>'h7eff)begin
                            {IRWr, MemWr, RegWr} = 3'b101;
                            Din_sel[1:0]<=2'b11;
                            end
                    3'b101: {IRWr, MemWr, RegWr} = 3'b000;
                endcase
            end
            beq_op: begin  // beq
				if(IntReq && (state==3'b100||state==3'b011||state==3'b010||state==3'b101))begin
				{Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
                RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0000000000_01_100_0001;
					 end
                else{Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
                RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0000000000_01_010_0001;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                endcase
            end
            lui_op: begin  // lui
				if(IntReq && (state==3'b100||state==3'b011||state==3'b010||state==3'b101))begin
				{Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
               RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0001000000_10_100_0010;
					 end
               else {Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
               RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0001000000_10_000_0010;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b100: {IRWr, MemWr, RegWr} = 3'b101;
                    3'b101: {IRWr, MemWr, RegWr} = 3'b000;
                endcase
            end
            ////////j////////////////////////////
            j_op: begin  // j
				
				
				if(IntReq && (state==3'b100||state==3'b011||state==3'b010||state==3'b101))begin
				{Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
                RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0000100000_01_100_0001;
					 end
					 
					 
                else {Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
                RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0000110000_01_001_0001;
					 
					 
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b101;
                    3'b101: {IRWr, MemWr, RegWr} = 3'b000;
                endcase
            end
            jal_op: begin  // jal
				if(IntReq && (state==3'b100||state==3'b011||state==3'b010||state==3'b101))begin
				{Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
                RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0000111000_01_100_0001;
					 end
                else {Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
                RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0000111000_01_001_0001;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b100: {IRWr, MemWr, RegWr} = 3'b101;
                    3'b101: {IRWr, MemWr, RegWr} = 3'b000;
                endcase
            end
            //////////////////////////////////////////////////
            eret_op:begin
              case(rs)
                eret_rs:begin
					 if(IntReq && (state==3'b100||state==3'b011||state==3'b010||state==3'b101))begin
					 {Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
                RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0000110000_01_100_0001;
					 end
                else {Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
                RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0000110000_01_101_0001;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b100: {IRWr, MemWr, RegWr} = 3'b101;
                    3'b101: {IRWr, MemWr, RegWr} = 3'b000;
                endcase
              end
                mtc0_rs:begin
					 if(IntReq && (state==3'b100||state==3'b011||state==3'b010||state==3'b101))begin
					 {Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
                RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0000100000_01_100_0001;
					 end
                else {Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
                RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b0000100000_01_000_0001;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b100: {IRWr, MemWr, RegWr} = 3'b101;
                    3'b101: {IRWr, MemWr, RegWr} = 3'b000;
                endcase
              end
                mfc0_rs:begin
					 if(IntReq && (state==3'b100||state==3'b011||state==3'b010||state==3'b101))begin
					 {Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
                RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b1000100000_01_100_0001;
					 end
                else {Din_sel[1:0],jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,
                RegDst,ExtOp[1:0], nPC_sel[2:0], ALUctr[3:0]} <= 18'b1000100000_01_000_0001;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b100: {IRWr, MemWr, RegWr} = 3'b101;
                    3'b101: {IRWr, MemWr, RegWr} = 3'b000;
                endcase
              end
              endcase
            end
        endcase
    end
    
    
    always @(negedge clk) begin
        case(state)
            3'b100: begin
            PCWr <= 1;
          end
            3'b011: begin
            PCWr <= (opcode==sb_op||opcode==sw_op ? 1 : 0);   // swsb
          end
            3'b010: begin
            PCWr <= (opcode==beq_op||opcode==j_op||((opcode==jr_op)&&funct==jr_func) ? 1 : 0);  
          end
            3'b101: begin
            PCWr <= 1; 
          end
            default: PCWr <= 0;
        endcase
    end
//|||||||-----------|||||||||||||||||----------||||||||||||||||||||||||||||----------||||||||||||||||||||
    endmodule