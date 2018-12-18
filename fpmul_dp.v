`timescale 1ns / 1ps

//Parameterized 2-input adder
module fp_adder #(parameter WIDTH = 8)(
	input	[WIDTH-1:0]	a, b,
	output	[WIDTH-1:0]	y );

	assign y = a + b;
endmodule

//Parameterized 2-input subtractor
module subtractor #(parameter WIDTH = 8)(
    input  [WIDTH-1:0] a, b,
    output [WIDTH-1:0] y );
    
    assign y = a - b;
endmodule

//25-bit multiplier to follow reference code
module multiplier(
    input [24:0] a, b,
    output [47:0] p);// ds change
    
    assign p = a * b;
    
endmodule

//// Parameterized 2-to-1 MUX
//module mux2 #(parameter WIDTH = 8) (
//	input	[WIDTH-1:0]	d0, d1, 
//	input				s, 
//	output	[WIDTH-1:0]	y );

//	assign y = s ? d1 : d0; 
//endmodule

// Simple Parameterized Register for use with flags
module dreg #(parameter WIDTH = 1) (
    input       clk,
    input      [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q);

    always @(posedge clk)
        q <= d;
endmodule

//Special Register to just quickly set UF/OF to 0 or 1 depending on two flags
module dreg_of_uf #(parameter WIDTH = 1) (
    input clk,
    input en,
    input rst,
    input [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q);

    always @(posedge clk, posedge rst)
    begin
        if(rst) q <= 0;
        else if(en) q <= 1;
    end
endmodule

// Parameterized Register with enable
module dreg_en #(parameter WIDTH = 8) (
	input					clk,
	input					en,
	input                   reset, //added a reset to the module and all instantiations JCAJ
	input		[WIDTH-1:0]	d, 
	output reg	[WIDTH-1:0]	q);

	always @(posedge reset, posedge clk)
	    begin
		  if (reset)      q <= 0;
		  else if (en)    q <= d;
		end
endmodule

// Register with rst //ds change
module Dreg_rst #(parameter WIDTH = 1) (clk,rst,d,q);
	input wire clk;
	input wire rst;
	input wire [WIDTH-1:0] d;
	output reg [WIDTH-1:0] q;

	always @(posedge clk or posedge rst)
	begin
		if(rst) begin
		   q <= 0;
		end else begin
		   q <= d;
		end
	end
endmodule

//Parameterized Register with enable, reset, and set functions
module dreg_full #(parameter WIDTH = 8) (
    input clk,
    input en,
    input rst,
    input set,
    input [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q);
    
    always @(posedge clk, posedge rst)
        begin
            if(rst)       q <= 0;
            else if(set)  q <= {WIDTH{1'b1}}; //set all 1's at variable width with replication operator
            else if (en)  q <= d;
        end

endmodule

//one-bit left shifter used for state 5
module sl_one #(parameter WIDTH=32) (
    input [WIDTH-1:0] a, 
    input             b,
    output [WIDTH-1:0] y);
    
    assign y = {a[WIDTH-2:0], b}; //for 32-bit number, would make y = {a[30:0], b}

endmodule


module fpmul_dp(
    input wire Done, // ds change
    input wire clk,
    input wire rst,
    input wire [31:0] A,
    input wire [31:0] B,
    
    //control signals
    input wire SA_LD,
    input wire EA_LD,
    input wire MA_LD,
    input wire SB_LD,
    input wire EB_LD,
    input wire MB_LD,
    input wire SP_LD,
    input wire EP_RST,
    input wire EP_SET,
    input wire [1:0] EP_SEL,
    input wire EP_LD,
    input wire MPH_RST,
    input wire MPH_SET,
    input wire [2:0] MPH_SEL, // ds change
    input wire MPH_LD,
    input wire MPL_SEL,
    input wire MPL_LD,
    input wire UF_RST,
    input wire UF_LD,
    input wire OF_RST,
    input wire OF_LD,
    input wire P_RST,
    input wire P_LD,
    
    //status signals to CU
    output wire Op_NaN,
    output wire Op_Inf,
    output wire Op_Zero, //map top three signals to Nan, Inf, and Zero of ctrl unit
    output wire MPH23,
    output wire Round,
    output wire Carry,
    output wire UFlow,
    output wire OFlow,
    output wire Dnf,
    
    //data outputs
    output wire [31:0] P,
    output wire P_UF,
    output wire P_OF,
    output wire P_NANF,
    output wire P_INFF,
    output wire P_DNF,
    output wire P_ZF
    );
    
    //bit width of sign component
    localparam sign_width = 1;
    
    //bit width of exponent component
    localparam exponent_width = 8;
    localparam exponent_width2 = exponent_width + 2; //10
    
    //bit width of mantissa component
    localparam mantissa_width = 23;
    localparam mantissa_width2 = mantissa_width + 1; //24
    
    //constant signals used for calc
    wire [exponent_width2-1:0] exp_bias; //used for ep = ep -127
    
    //internal signals
    wire sa;
    wire [9:0] ea;
    wire [23:0] ma;
    
    wire sb;
    wire [9:0] eb;
    wire [23:0] mb;
    
    wire sp;
    wire [7:0] ep;
    wire [23:0] mp;
    
    assign exp_bias = 127;
    
    //unpack the input signals 
    assign sa = A[31];
    assign ea = {2'b00, A[30:23]};
    assign ma = {1'b1, A[22:0]};
    
    assign sb = B[31];
    assign eb = {2'b00, B[30:23]};
    assign mb = {1'b1, B[22:0]};
    
    //constants
    wire [exponent_width2-1:0] EP_ONE_CONSTANT; 
    assign EP_ONE_CONSTANT = 1'b1;
	
    wire [mantissa_width2-1:0] MPH_ONE_CONSTANT; 
    assign MPH_ONE_CONSTANT = 1'b1;
    wire [mantissa_width2-1:0] MPH_CONSTANT = 24'h800000; //TODO: see if this is right 
    
    //internal signals
    wire SA, SB, SP_D, SP; 
    wire [9:0] EA, EB, EP, 
               EP_D1, EP_D2, EP_D3, //store all intermediates after arithmetic units
               EP_Y1, EP_Y2; //store all intermediates after multiplexers
    wire [23:0] MA, MB, 
                MPH_D1, MPH_D2, MPH_D3, //store all intermediates after arithmetic units
                MPH_Y1, MPH_Y2, MPH_Y3, //store all intermediates after multiplexers
                MPL_D1, MPL_D2, // after arithmetic units
                MPL_Y1,
                MPH, MPL;
    wire P_SIGN;
    wire [7:0] P_EXP;
    wire [22:0] P_MANT;
    
    // ds change
    wire INT_UF;
    wire INT_OF;
    wire INT_NANF;
    wire INT_INFF;
    wire INT_DNF;
    wire INT_ZF;
    
    // ds change
    wire [47:0] MP;
    //internal/intermediate signals for flag generation
    wire EA_ZF_C, EA_ZF, EA_HF_C, EA_HF, 
         MA_ZF_C, MA_ZF, MA_HF_C, MA_HF,
         EB_ZF_C, EB_ZF, EB_HF_C, EB_HF,
         MB_ZF_C, MB_ZF, MB_HF_C, MB_HF,
         EP_ZF, EP_HF, MPH_ZF, MPH_HF; //used for product overflow calculation
         
    wire A_NANF, A_INFF, A_NF, A_DNF, A_ZF,
         B_NANF, B_INFF, B_NF, B_DNF, B_ZF;
         
     wire Op_NaN_C, Op_Inf_C, Op_Zero_C,
          NaN_C, Inf_C, Zero_C, Dnf_C;
     
     wire R, S;
    
    //A signed bit register
    dreg_en #(sign_width) sa_reg (
    .clk(clk),
    .en(SA_LD),
    .reset(rst),
    .d(sa),
    .q(SA));
    
    //B signed bit register
    dreg_en #(sign_width) sb_reg (
    .clk(clk),
    .en(SB_LD),
    .reset(rst),
    .d(sb),
    .q(SB));
    
    //A exponent register
    dreg_en #(exponent_width2) ea_reg (
    .clk(clk),
    .en(EA_LD),
    .reset(rst),
    .d(ea),
    .q(EA));
    
    //B exponent register
    dreg_en #(exponent_width2) eb_reg (
    .clk(clk),
    .en(EB_LD),
    .reset(rst),
    .d(eb),
    .q(EB));
    
    //A mantissa register
    dreg_en #(mantissa_width2) ma_reg (
    .clk(clk),
    .en(MA_LD),
    .reset(rst),
    .d(ma),
    .q(MA));
    
    //B mantissa register
    dreg_en #(mantissa_width2) mb_reg (
    .clk(clk),
    .en(MB_LD),
    .reset(rst),
    .d(mb),
    .q(MB));
  
    
    /* RTL logic fo exponent calculation */
    //adder for ea + eb op
    fp_adder #(exponent_width2) ep_add1(
    .a(EA),
    .b(EB),
    .y(EP_D1));
    
    //subtractor for ep - 127
    subtractor #(exponent_width2) ep_sub1(
    .a(EP),
    .b(exp_bias),
    .y(EP_D2));
    
    //adder for ep + 1 
    fp_adder #(exponent_width2) ep_add2 (
    .a(EP),
    .b(EP_ONE_CONSTANT),
    .y(EP_D3));
    
   //this mux looks at EP_SEL[1] 
    mux2 #(exponent_width2) ep_mux1 (
    .d0(EP_D1), // EA + EB
    .d1(EP_D2), // EP - 127
    .s(EP_SEL[1]),
    .y(EP_Y1));
    
    //this mux looks at EP_SEL[0]
    mux2 #(exponent_width2) ep_mux2 (
    .d0(EP_Y1), //EA + EB
    .d1(EP_D3), // EP + 1
    .s(EP_SEL[0]),
    .y(EP_Y2));
    
    dreg_full #(exponent_width2) ep_reg (
    .clk(clk),
    .en(EP_LD),
    .rst(EP_RST),
    .set(EP_SET),
    .d(EP_Y2), //output of EP_SEL[0] mux
    .q(EP));
    
    /*  mantissa combinational units go here */
    //reference code uses library mux that takes in a clock, have to see if this works
    multiplier mult (
    .a({1'b0, MA}),
    .b({1'b0, MB}),
    .p(MP));
    
    assign MPL_D1 = MP[23:0];
    
    //shifter for mpl = {mpl[22:0], 0}
    sl_one #(mantissa_width2) mpl_shift (
    .a(MPL),
    .b(1'b0),
    .y(MPL_D2));
    
    //multiplexer that looks at MPL_SEL into MPL register
    mux2 #(mantissa_width2) mpl_mux (
    .d0(MPL_D1),
    .d1(MPL_D2),
    .s(MPL_SEL),
    .y(MPL_Y1));
    
    //MPL register
    dreg_en #(mantissa_width2) mpl_reg (
    .clk(clk),
    .en(MPL_LD),
    .reset(rst),
    .d(MPL_Y1),
    .q(MPL));
    
    //mph stuff below
    assign MPH_D1 = MP[47:24];
    
    //adder for MPH + 1
    fp_adder #(mantissa_width2) mph_add (
    .a(MPH),
    .b(MPH_ONE_CONSTANT),
    .y(MPH_D2));
    
    //shifter for MPH = {MPH[22:0], MPL[23]}
    sl_one #(mantissa_width2) mph_shift (
    .a(MPH),
    .b(MPL[23]),
    .y(MPH_D3));    
    
    //mph mux that looks at mph_sel[2]; chooses between MP[47:24] and 0x800000
    mux2 #(mantissa_width2) mph_mux1 (
    .d0(MPH_D1),
    .d1(MPH_CONSTANT),
    .s(MPH_SEL[2]),
    .y(MPH_Y1));
    
    //mph mux that looks at mph_sel[1]; chooses between mph_mux1 output and mph + 1
    mux2 #(mantissa_width2) mph_mux2 (
    .d0(MPH_Y1),
    .d1(MPH_D2),
    .s(MPH_SEL[1]),
    .y(MPH_Y2));
    
    //mph mux that looks at mph_sel[0]; chooses between mph_mux2 output and {mph[22:0], mpl[23]}
    mux2 #(mantissa_width2) mph_mux3 (
    .d0(MPH_Y2),
    .d1(MPH_D3),
    .s(MPH_SEL[0]),
    .y(MPH_Y3));   
    
    //mph register stores the output of mph_mux3
    dreg_full #(mantissa_width2) mph_reg (
    .clk(clk),
    .en(MPH_LD),
    .rst(MPH_RST),
    .set(MPH_SET),
    .d(MPH_Y3),
    .q(MPH));
    
    assign MPH23 = MPH[23];
    
    /* flag logic goes here */
    
    //EA Zero Flag
    assign EA_ZF_C = ~|EA[7:0];
    
    dreg #(1) ea_zf_reg (
    .clk(clk),
    .d(EA_ZF_C),
    .q(EA_ZF));
    
    //EA High Flag
    assign EA_HF_C = &EA[7:0];
    
    dreg #(1) ea_hf_reg (
    .clk(clk),
    .d(EA_HF_C),
    .q(EA_HF));
    
    //MA Zero Flag
    assign MA_ZF_C = ~|MA[22:0];
    
    dreg #(1) ma_zf_reg (
    .clk(clk),
    .d(MA_ZF_C),
    .q(MA_ZF));
    
    //MA High Flag
    assign MA_HF_C = &MA[22:0];
    
    dreg #(1) ma_hf_reg (
    .clk(clk),
    .d(MA_HF_C),
    .q(MA_HF));
    
    //EB Zero Flag
    assign EB_ZF_C = ~|EB[7:0];
    
    dreg #(1) eb_zf_reg (
    .clk(clk),
    .d(EB_ZF_C),
    .q(EB_ZF));
    
    //EB High Flag
    assign EB_HF_C = &EB[7:0];
    
    dreg #(1) eb_hf_reg (
    .clk(clk),
    .d(EB_HF_C),
    .q(EB_HF));
    
    //MB Zero Flag
    assign MB_ZF_C = ~|MB[22:0];
    
    dreg #(1) mb_zf_reg (
    .clk(clk),
    .d(MB_ZF_C),
    .q(MB_ZF));
    
    //MB High Flag
    assign MB_HF_C = &MB[22:0];
    
    dreg #(1) mb_hf_reg (
    .clk(clk),
    .d(MB_HF_C),
    .q(MB_HF));
    
    //Product High and Zero Flags
    assign EP_HF = &EP[7:0];
    assign EP_ZF = ~|EP[7:0];
    assign MPH_HF = &MPH[22:0];
    assign MPH_ZF = ~|MPH[22:0];
    
    assign Carry = MPH_HF;
     
    //now that operand high and zero flags set, start setting flags and save in regs
    //Not a Number Flags
    assign A_NANF = EA_HF & ~MA_ZF;
    assign B_NANF = EB_HF & ~MB_ZF;
    
    //Infinity Flags
    assign A_INFF = EA_HF & MA_ZF;
    assign B_INFF = EB_HF & MB_ZF;
    
    //Normal Flags
    assign A_NF = ~EA_HF & EA_ZF;
    assign B_NF = ~EB_HF & EB_ZF;
    
    //Denormal Flags
    assign A_DNF = EA_ZF & ~MA_ZF;
    assign B_DNF = EB_ZF & ~MB_ZF;
    assign Dnf = A_DNF | B_DNF;
    
    //Zero Flags
    assign A_ZF = EA_ZF & MA_ZF;
    assign B_ZF = EB_ZF & MB_ZF; //changed MA_ZF to MB_ZF JCAJ
    
    //set intermediate value before saving in register
    //Store Nan Flag
    assign Op_NaN_C = A_NANF | B_NANF | (A_INFF & B_ZF) | (A_ZF & B_INFF);
    
    dreg #(1) op_nan_reg (
    .clk(clk),
    .d(Op_NaN_C),
    .q(Op_NaN)); //output signal from dp into cu
    
    //Store Inf FLag
    assign Op_Inf_C = (A_INFF & ~(B_NANF | B_ZF)) |
                   (B_INFF & ~(A_NANF | A_ZF));
   
   dreg #(1) op_inf_reg (
   .clk(clk),
   .d(Op_Inf_C),
   .q(Op_Inf));
   
assign Op_Zero_C = (A_ZF & (~B_NANF | B_INFF)) |
                   (B_ZF & (~A_NANF | A_INFF)); //moved tildas to inside JCAJ
                   
   dreg #(1) op_zero_reg (
   .clk(clk),
   .d(Op_Zero_C),
   .q(Op_Zero));
   
   //Round Bit
   assign R = MPL[23];
   
   //Sticky Bit (Notice: Not storing Sticky bit in a register as in reference code
   //all calculations done in single state, not gated
   assign S = |MPL[22:0];
   
   //Round Flag
   assign Round = R & (MPH[0] | S);
   
   //Underflow Flag
   assign UFlow = EP[9];
   
   //Overflow Flag
   assign OFlow = (~EP[9] & EP[8]) | EP_HF; //changed where parentheses are JCAJ
   
   // ds change
   assign P_UF = INT_UF & Done;
   assign P_OF = INT_OF & Done;

   dreg_of_uf #(1) uf_reg (
   .clk(clk),
   .en(UF_LD),
   .rst(UF_RST),
   .d(UFlow),
   .q(INT_UF)); // ds change
   
   dreg_of_uf #(1) of_reg (
   .clk(clk),
   .en(OF_LD),
   .rst(OF_RST),
   .d(OFlow),
   .q(INT_OF));// ds change
  
  //Product business below
   assign SP_D = SA ^ SB;
  //Product signed bit register
  dreg_en #(sign_width) sp_reg (
  .clk(clk),
  .en(SP_LD),
  .reset(rst),
  .d(SP_D),
  .q(SP));
  
  assign P = {P_SIGN, P_EXP, P_MANT};
  //gate all the product fields behind registers tied to P_LD and P_RST
  dreg_full #(sign_width) p_sign_reg (
  .clk(clk),
  .en(P_LD),
  .rst(P_RST),
  .set(),
  .d(SP),
  .q(P_SIGN));
  
  dreg_full #(exponent_width) p_exp_reg (
  .clk(clk),
  .en(P_LD),
  .rst(P_RST),
  .set(),
  .d(EP[7:0]),
  .q(P_EXP));
  
  dreg_full #(mantissa_width) p_mant_reg (
  .clk(clk),
  .en(P_LD),
  .rst(P_RST),
  .set(),
  .d(MPH[22:0]),// ds change
  .q(P_MANT));
  
  //capture all the system level abnormal flags and output them through P_UF, P_OF etc
  assign NaN_C = EP_HF & ~MPH_ZF;
  assign Inf_C = EP_HF & MPH_ZF;
  assign Dnf_C = EP_ZF & ~MPH_ZF;
  assign Zero_C = EP_ZF & MPH_ZF;
  
  assign P_NANF = INT_NANF & Done; // ds change
  dreg #(1) nan_reg (
  .clk(clk),
  .d(NaN_C),
  .q(INT_NANF)); // ds change
  
  assign P_INFF = INT_INFF & Done; // ds change
  dreg #(1)  inf_reg (
  .clk(clk),
  .d(Inf_C),
  .q(INT_INFF));// ds change
  
  assign P_DNF = (INT_DNF | Dnf) & Done ; // ds change
  dreg #(1) dnf_reg (
  .clk(clk),
  .d(Dnf_C),
  .q(INT_DNF));// ds change
  
  assign P_ZF = INT_ZF & Done; // ds change
  dreg #(1) zero_reg (
  .clk(clk),
  .d(Zero_C),
  .q(INT_ZF));// ds change
  
endmodule