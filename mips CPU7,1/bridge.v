module bridge(
    input [31:0] PrAddr,
    output [31:0] PrDin,//RD
    input [31:0] PrDout,//WD
    input Wen,
    input IRQ,
    output [5:0]HWInt,
    //
    input [31:0] DEVT_RD,
    input [31:0] DEVI_RD,
    input [31:0] DEVO_RD,
    //
	  output [31:0] DEV_Addr,
	  //
    output [31:0] DEV_WD,
    output WeDEVT,
    output WeDEVO
    );
	wire Hitdev0,Hitdev1,Hitdev2;//timer output input
	//////////////////////////////////////
	assign HWInt={5'b0,IRQ};
	//
	assign Hitdev0=(PrAddr[31:4] == 'h00007F0);//timerRD
	assign Hitdev1=(PrAddr[31:4] == 'h00007F1);//outputRD
	assign Hitdev2=(PrAddr[31:4] == 'h00007F2);//inputRD
	//
	assign PrDin=(Hitdev0)?DEVT_RD:
	             (Hitdev1)?DEVO_RD:
	             (Hitdev2)?DEVI_RD:32'b0;
	//
	assign WeDEVT=Wen&&Hitdev0;
	assign WeDEVO=Wen&&Hitdev1;
	//
	assign DEV_Addr=PrAddr;
	//
	assign DEV_WD=PrDout;

endmodule