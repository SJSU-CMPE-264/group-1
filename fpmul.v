module fpmul(
		input Clk,
		input Rst,
		input Start,
		input [31:0] A,
		input [31:0] B,
		output Done,
		output [31:0] P,
		output UF,
		output OF,
		output NaNF,
		output InfF,
		output DNF,
		output ZF );
    
	//Control signals
	wire SA_LD;
	wire EA_LD;
	wire MA_LD;
	wire SB_LD;
	wire EB_LD;
	wire MB_LD;
	wire SP_LD;
	wire EP_SET;
	wire EP_RST;
	wire [1:0] EP_SEL;
	wire EP_LD;
	wire MPH_SET;
	wire MPH_RST;
	wire [2:0] MPH_SEL;
	wire MPH_LD;
	wire MPL_SEL;
	wire MPL_LD;
	wire UF_RST;
	wire UF_LD;
	wire OF_RST;
	wire OF_LD;
	wire P_LD;
	wire P_RST;
    
	//Status Signals
	wire NaN;
	wire Inf;
	wire Zero;
	wire MPH23;
	wire Round;
	wire Carry;
	wire UFlow;
	wire OFlow;
 
	//fpmul_cu cu
	fpmul_cu cu (
			.clk(Clk),
			.rst(Rst),
			.Start(Start),
			.SA_LD(SA_LD),
			.EA_LD(EA_LD),
			.MA_LD(MA_LD),
			.SB_LD(SB_LD),
			.EB_LD(EB_LD),
			.MB_LD(MB_LD),
			.SP_LD(SP_LD),
			.EP_SET(EP_SET),
			.EP_RST(EP_RST),
			.EP_SEL(EP_SEL),
			.EP_LD(EP_LD),
			.MPH_SET(MPH_SET),
			.MPH_RST(MPH_RST),
			.MPH_SEL(MPH_SEL),
			.MPH_LD(MPH_LD),
			.MPL_SEL(MPL_SEL),
			.MPL_LD(MPL_LD),
			.UF_RST(UF_RST),
			.UF_LD(UF_LD),
			.OF_RST(OF_RST),
			.OF_LD(OF_LD),
			.P_RST(P_RST),
			.P_LD(P_LD),
			.NaN(NaN),
			.Inf(Inf),
			.Zero(Zero),
			.MPH23(MPH23),
			.Round(Round),
			.Carry(Carry),
			.UFlow(UFlow),
			.OFlow(OFlow),
			.Dnf(Dnf),
			.Done(Done)
		);
    

	fpmul_dp dp (
			.clk(Clk),
			.rst(Rst),
			.A(A),
			.B(B),
			.SA_LD(SA_LD),
			.EA_LD(EA_LD),
			.MA_LD(MA_LD),
			.SB_LD(SB_LD),
			.EB_LD(EB_LD),
			.MB_LD(MB_LD),
			.SP_LD(SP_LD),
			.EP_SET(EP_SET),
			.EP_RST(EP_RST),
			.EP_SEL(EP_SEL),
			.EP_LD(EP_LD),
			.MPH_SET(MPH_SET),
			.MPH_RST(MPH_RST),
			.MPH_SEL(MPH_SEL),
			.MPH_LD(MPH_LD),
			.MPL_SEL(MPL_SEL),
			.MPL_LD(MPL_LD),
			.UF_RST(UF_RST),
			.UF_LD(UF_LD),
			.OF_RST(OF_RST),
			.OF_LD(OF_LD),  
			.P_RST(P_RST),
			.P_LD(P_LD),
			.Op_NaN(NaN),
			.Op_Inf(Inf),
			.Op_Zero(Zero),
			.MPH23(MPH23),
			.Round(Round),
			.Carry(Carry),
			.UFlow(UFlow),
			.OFlow(OFlow),
			.P(P),
			.P_UF(UF),
			.P_OF(OF),
			.P_NANF(NaNF),
			.P_INFF(InfF),
			.P_DNF(DNF),
			.Dnf(Dnf),
			.Done(Done),//ds change
			.P_ZF(ZF));
    
endmodule