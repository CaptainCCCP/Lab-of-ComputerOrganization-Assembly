module ctrl(instruction,RegDst,RegWr,ExtOp,nPC_sel,ALUctr,MemtoReg,MemWr,ALUSrc,j_sel,jal_sel,lb_sel,sb_sel,PCWr,IRWr,clk,rst,Din_sel,jalr_en);
  input [31:0]instruction;
  input clk,rst;
  output reg [1:0]ExtOp,nPC_sel;
  output reg[3:0]ALUctr;
  output reg RegDst,RegWr,MemtoReg,MemWr,ALUSrc,j_sel,jal_sel,lb_sel,sb_sel,PCWr,IRWr,Din_sel,jalr_en;
  
parameter ADD=4'b0000;
parameter SUB=4'b0001;
parameter OR= 4'b0010;
parameter AND=4'b0011;
parameter SLT=4'b0100;
  wire [5:0]opcode,funct;
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
  initial begin
    nPC_sel=0;
    RegDst=0;
    RegWr=0;
    ExtOp=0;
    nPC_sel=0;//00:+4,01:beq,10:j/jal,11:jr
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

always @(posedge clk,posedge rst) 
		begin
		  if(rst==1)begin
		    state<=3'b000;
		    end
		   else begin
			   state <= next_state;
			   end
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
								next_state = 3'b010; //all other
							end
					endcase
				end
				
			3'b010: //exe
				begin
					case (opcode)
					  j_op:
					  begin
					    next_state = 3'b000;		
					    end
						beq_op: 
							begin
								next_state = 3'b000;				// beq
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
							    next_state = 3'b000;
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
							next_state = 3'b000;						//sw sb
						end			
				end
				
			3'b100: //wb
				begin
					next_state = 3'b000;
				end
				
		endcase
	end	

//------------------------------------------------------------------------------------------------
 always @(state or opcode or funct) begin  
        case(opcode)
            6'b000000: 
            case(funct)
              addu_func:
                begin  // addu
                {jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,RegDst,ExtOp[1:0], nPC_sel[1:0], ALUctr[3:0]} <= 16'b00000001_00_00_0000;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b100: {IRWr, MemWr, RegWr} = 3'b101;
                endcase
                end
            subu_func:
                begin  // subu
               {jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,RegDst,ExtOp[1:0], nPC_sel[1:0], ALUctr[3:0]} <= 16'b00000001_00_00_0001;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b100: {IRWr, MemWr, RegWr} = 3'b101;
                endcase
                end
            slt_func: begin  // slt
                {jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,RegDst,ExtOp[1:0], nPC_sel[1:0], ALUctr[3:0]} <= 16'b00000001_01_00_0100;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b100: {IRWr, MemWr, RegWr} = 3'b101;
                endcase
                end
            jr_func: begin  // jr
              {jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,RegDst,ExtOp[1:0], nPC_sel[1:0], ALUctr[3:0]} <= 16'b00000000_00_11_0000;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                endcase
                end
            jalr_func:
                begin  // jalr
                {jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,RegDst,ExtOp[1:0], nPC_sel[1:0], ALUctr[3:0]} <= 16'b10111001_01_00_00010;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b100: {IRWr, MemWr, RegWr} = 3'b101;
                endcase
                end
            endcase//R
            
            //I///////////////////////////////
            addi_op: begin  // addi
              {jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,RegDst,ExtOp[1:0], nPC_sel[1:0], ALUctr[3:0]} <= 16'b01000000_01_00_0000;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b100: {IRWr, MemWr, RegWr} = 3'b101;
                endcase
            end
            addiu_op: begin  // addiu
              {jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,RegDst,ExtOp[1:0], nPC_sel[1:0], ALUctr[3:0]} <= 16'b01000000_01_00_0000;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b100: {IRWr, MemWr, RegWr} = 3'b101;
                endcase
            end
            ori_op: begin  // ori
              {jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,RegDst,ExtOp[1:0], nPC_sel[1:0], ALUctr[3:0]} <= 16'b01000000_00_00_0010;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b100: {IRWr, MemWr, RegWr} = 3'b101;
                endcase
            end
            sw_op: begin  // sw
             {jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,RegDst,ExtOp[1:0], nPC_sel[1:0], ALUctr[3:0]} <= 16'b01000000_01_00_0000;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b011: {IRWr, MemWr, RegWr} = 3'b110;
                endcase
            end
            lw_op: begin  // lw
              {jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,RegDst,ExtOp[1:0], nPC_sel[1:0], ALUctr[3:0]} <= 16'b01100000_01_00_0000;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b011: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b100: {IRWr, MemWr, RegWr} = 3'b101;
                endcase
            end
            sb_op: begin  // sb
               {jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,RegDst,ExtOp[1:0], nPC_sel[1:0], ALUctr[3:0]} <= 16'b01000010_01_00_0000;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b011: {IRWr, MemWr, RegWr} = 3'b110;
                endcase
            end
            lb_op: begin  // lb
              {jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,RegDst,ExtOp[1:0], nPC_sel[1:0], ALUctr[3:0]} <= 16'b01100100_01_00_0000;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b011: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b100: {IRWr, MemWr, RegWr} = 3'b101;
                endcase
            end
            beq_op: begin  // beq
                {jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,RegDst,ExtOp[1:0], nPC_sel[1:0], ALUctr[3:0]} <= 16'b00000000_01_10_0001;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                endcase
            end
            lui_op: begin  // lui
               {jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,RegDst,ExtOp[1:0], nPC_sel[1:0], ALUctr[3:0]} <= 16'b01000000_10_00_0010;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b100: {IRWr, MemWr, RegWr} = 3'b101;
                endcase
            end
            ////////j////////////////////////////
            j_op: begin  // j
                {jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,RegDst,ExtOp[1:0], nPC_sel[1:0], ALUctr[3:0]} <= 16'b00110000_01_01_0001;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b010: {IRWr, MemWr, RegWr} = 3'b101;
                endcase
            end
            jal_op: begin  // jal
                {jalr_en,ALUSrc, MemtoReg,j_sel,jal_sel,lb_sel,sb_sel,RegDst,ExtOp[1:0], nPC_sel[1:0], ALUctr[3:0]} <= 16'b00111000_01_01_0001;
                case(state)
                    3'b000: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b001: {IRWr, MemWr, RegWr} = 3'b100;
                    3'b100: {IRWr, MemWr, RegWr} = 3'b101;
                endcase
            end
        endcase
    end
    
    always @(negedge clk) begin
        case(state)
            3'b100: PCWr <= 1;
            3'b011: PCWr <= (opcode==sb_op||opcode==sw_op ? 1 : 0);   // swsb
            3'b010: PCWr <= (opcode==beq_op||opcode==j_op||((opcode==jr_op)&&funct==jr_func) ? 1 : 0);  
            default: PCWr <= 0;
        endcase
    end
//|||||||-----------|||||||||||||||||----------||||||||||||||||||||||||||||----------||||||||||||||||||||
    endmodule