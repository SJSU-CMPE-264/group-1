
//------------------------------------------------
// Source Code for a Single-cycle MIPS Processor (supports partial instruction)
// Developed by D. Hung, D. Herda and G. Gerken,
// based on the following source code provided by
// David_Harris@hmc.edu (9 November 2005):
//    mipstop.v
//    mipsmem.v
//    mips.v
//    mipsparts.v
//------------------------------------------------

// Main Decoder
module maindec(
	input	[ 5:0]	op, funct,
	input   [ 1:0]  ID, // added
	input           orsignal, clk,// added
	output			memtoreg, memwrite, branch, alusrc, regdst,
	                regwrite, regdst2, signor4, multien, exdone,
	output          twoonemux, epcwrite, epcread, // added
	output	[ 1:0]	aluop, jump, fouronemux,
	output          syscall_clear, invalid_clear, overflow_clear, extint_clear); // added

    reg     [  1:0] start = 0;
    reg     [  6:0] exception_controls;
	reg 	[ 15:0]	controls;
	reg     [  1:0] NS, CS;

    assign {twoonemux, epcwrite, epcread, syscall_clear, invalid_clear, overflow_clear, extint_clear} =  exception_controls;
	assign {regwrite, regdst, alusrc, branch, memwrite, memtoreg, 
	       jump, aluop, regdst2, signor4, multien, fouronemux, exdone} = controls;
	       
	always @(*)
	begin
		case(op)
			6'b000000: //R-Type
			     begin
			         if (funct == 6'b011001) //multu
			             begin
			             controls <= 16'b1100001110101000; 
			             end
			         else if (funct == 6'b010000)//mfhi
			             begin
            			 controls <= 16'b1100001110100100;
			              end
        			else if (funct == 6'b010010)//mflo
            			 begin
            			 controls <= 16'b1100001110100010;
            			 end
            		else if (funct == 6'b001000)//jreg
            		     begin
            		     controls <= 16'b1100000110100110;
            		     end	 
        			else
            			 begin
            			 controls <= 16'b1100001110100110;  
            			 end
                 end
            6'b100011: controls <= 16'b1010011100100110; //LW
            6'b101011: controls <= 16'b0010101100100110; //SW
            6'b000100: controls <= 16'b0001000001100000; //BEQ
            6'b001000: controls <= 16'b1010001100100110; //ADDI
            6'b000010: controls <= 16'b0000001010000000; //J 
            6'b000011: controls <= 16'b1000001010010000; //JAL
            6'b100000: controls <= 16'b0000000011000001; //RFE
			default:   controls <= 16'bxxxxxxxxxxxxxxxx; //???
		endcase
		
        if(orsignal)
            begin
                if(start && ~exdone)
                begin
                    exception_controls <= 7'b1000000;
                end
                else if (exdone)
                begin
                    case(ID)
                        2'b00: exception_controls <= 7'b1011000;
                        2'b01: exception_controls <= 7'b1010100;
                        2'b10: exception_controls <= 7'b1010010;
                        2'b11: exception_controls <= 7'b1010001;
                    endcase
                end
                else
                begin
                    exception_controls = 7'b1100000;
                    #10
                    start = 1;
                end
            end
        else
            begin
                exception_controls <= 7'b0000000;
                start <= 0;
            end
    end
endmodule

// ALU Decoder
module aludec(
	input		[5:0]	funct,
	input		[1:0]	aluop,
	output reg	[2:0]	alucontrol );

	always @(*)
		case(aluop)
			2'b00: alucontrol <= 3'b010;  // add
			2'b01: alucontrol <= 3'b110;  // sub
			default: case(funct)          // RTYPE
				6'b100000: alucontrol <= 3'b010; // ADD
				6'b100010: alucontrol <= 3'b110; // SUB
				6'b100100: alucontrol <= 3'b000; // AND
				6'b100101: alucontrol <= 3'b001; // OR
				6'b101010: alucontrol <= 3'b111; // SLT	
				6'b010000: alucontrol <= 3'b000; // RFE		
				default:   alucontrol <= 3'bxxx; // ???
			endcase
		endcase
endmodule
// ALU
module alu(
	input		[31:0]	a, b, 
	input		[ 2:0]	alucont, 
	output reg	[31:0]	result,
	output			zero );

	wire	[31:0]	b2, sum, slt;

	assign b2 = alucont[2] ? ~b:b; 
	assign sum = a + b2 + alucont[2];
	assign slt = sum[31];

	always@(*)
		case(alucont[1:0]) // Change to use all three bits now since we adding rfenot sure what tho
			2'b00:result <= a & b;
			2'b01:result <= a | b;
			2'b10:result <= sum;
			2'b11:result <= slt;
		endcase

	assign zero = (result == 32'b0);
endmodule

// Adder
module adder(
	input	[31:0]	a, b,
	output	[31:0]	y );

	assign y = a + b;
endmodule

// Two-bit left shifter
module sl2(
	input	[31:0]	a,
	output	[31:0]	y );

	// shift left by 2
	assign y = {a[29:0], 2'b00};
endmodule

// Sign Extension Unit
module signext(
	input	[15:0]	a,
	output	[31:0]	y );

	assign y = {{16{a[15]}}, a};
endmodule

// Parameterized Register
module flopr #(parameter WIDTH = 8) (
	input					clk, reset,
	input		[WIDTH-1:0]	d, 
	output reg	[WIDTH-1:0]	q);

	always @(posedge clk, posedge reset)
		if (reset) q <= 0;
		else       q <= d;
endmodule

// Parameterized 2-to-1 MUX
module mux2 #(parameter WIDTH = 8) (
	input	[WIDTH-1:0]	d0, d1, 
	input				s, 
	output	[WIDTH-1:0]	y );

	assign y = s ? d1 : d0; 
endmodule

//Regular 2to1 mux
/*module singlemux (
	input	d0, d1, 
	input	s, 
	output	y );

	assign y = s ? d1 : d0; 
endmodule
*/
//4to1 Mux
module fouronemux #(parameter WIDTH = 32)(
	input	[WIDTH-1:0] d0, d1, d2, d3,
	input	[1:0] s, 
	output	reg [WIDTH-1:0] y );
always@(*)
begin
    case(s)
 	      2'b00: y<=d0;
          2'b01: y<=d1;
          2'b10: y<=d2;
          2'b11: y<=d3;
    endcase
end
endmodule

//Multiplication
module multiply (
input clk,
input enable,
input [31:0] rs, rt,
output reg [31:0] hi, lo

);
reg [63:0] result;

always@(posedge clk)
begin
    if(enable)
        begin
            result = rs*rt; 
            hi=result[63:32];
            lo=result[31:0];
        end
    else
        begin
            hi=hi;
            lo=lo;
        end
end
endmodule

// register file with one write port and three read ports
// the 3rd read port is for prototyping dianosis
module regfile(	
	input			clk, 
	input			we3, 
	input 	[ 4:0]	ra1, ra2, wa3, 
	input	[31:0] 	wd3, 
	output 	[31:0] 	rd1, rd2
	);

	reg		[31:0]	rf[31:0];
	integer			n;
	
	//initialize registers to all 0s
	initial 
		for (n=0; n<32; n=n+1) 
			rf[n] = 32'h00;
			
	//write first order, include logic to handle special case of $0
    always @(posedge clk)
        if (we3)
			if (~ wa3[4])
				rf[{0,wa3[3:0]}] <= wd3;
			else
				rf[{1,wa3[3:0]}] <= wd3;
		
	assign rd1 = (ra1 != 0) ? rf[ra1[4:0]] : 0;
	assign rd2 = (ra2 != 0) ? rf[ra2[4:0]] : 0;
endmodule

// Control Unit
module controller(
	input	[5:0]	op, funct,
	input   [1:0]   ID,            // added
	input			zero, orsignal, // added
	output			memtoreg, memwrite, pcsrc, alusrc, regdst,
	                regwrite, regdst2, signor4, multien,
	                twoonemux, epcwrite, epcread, exdone, // added
	output  [1:0]   jump, fouronemux,
	output	[2:0]	alucontrol,
	output          syscall_clear, invalid_clear, overflow_clear, extint_clear ); // added

	wire	[1:0]	aluop;
	wire			branch;

	
	maindec	md(
	.op(op),
	.funct(funct),
	.ID(ID),               // added
	.orsignal(orsignal),   // added
	.memtoreg(memtoreg),
	.memwrite(memwrite),
	.branch(branch),
	.alusrc(alusrc),
	.regdst(regdst),
	.regwrite(regwrite),
	.regdst2(regdst2),
	.signor4(signor4),
	.multien(multien),
	.twoonemux(twoonemux), // added
	.epcwrite(epcwrite),   // added
	.epcread(epcread),     // added
	.exdone(exdone),   // added
	.aluop(aluop),
	.jump(jump),
	.fouronemux(fouronemux),
	.syscall_clear(syscall_clear), // added
	.invalid_clear(invalid_clear), // added
	.overflow_clear(overflow_clear), // added
	.extint_clear(extint_clear) // added
	
	);

	aludec	ad(
	.funct(funct),
	.aluop(aluop),
	.alucontrol(alucontrol)
	
	);

	assign pcsrc = branch & zero;
endmodule

// Data Path (excluding the instruction and data memories)
module datapath(
	input			clk, reset, memtoreg, pcsrc, alusrc, regdst, regwrite, regdst2,
	                signor4, multien, twoonemux, syscall, invalid, overflow, ext_int,
	                epcwrite, epcread, exdone, // Added interrupt signals, epc signals, and or signal
	input   [1:0]   jump, fouronemux,
	input	[2:0]	alucontrol,
	input           syscall_clear, invalid_clear, overflow_clear, extint_clear, //added
	output			zero, orsignal,
	output  [1:0]   id,
	output	[31:0]	pc,
	input	[31:0]	instr,
	output	[31:0]	aluout, writedata,
	input	[31:0]	readdata);

    wire        latched_syscall, latched_invalid, latched_overflow, latched_ext_int, latched_exdone,
                latched_syscall_clear, latched_invalid_clear, latched_overflow_clear, latched_extint_clear,
                interrupt;
	wire [4:0]  writereg, writemux;
	wire [31:0] pcnext, pcnextbr, pcplus4, pcbranch, signimm, signimmsh, srca, srcb, result, signtomux, muxtobran, hi, lo;
	wire [31:0] resmuxtofour, epc, firstpc;

	
//new
	fouronemux #(32) fourmuxtopc(
	.d0(pcnextbr), 
	.d1(srca), 
	.d2({pcplus4[31:28], signtomux[27:0]}),
	.d3(pcplus4), 
	.s(jump), 
	.y(pcnext)
	);
	
	adder       pcadd2(
	.a(muxtobran),
	.b(pcplus4),
	.y(pcbranch)
	);
	
	sl2         immtomux(
	.a({6'b0, instr[25:0]}),
	.y(signtomux)
	);
    
    mux2 #(32)  signtobran(
    .d0(signimmsh),
    .d1(32'b0),
    .s(signor4),
    .y(muxtobran)
    );

    mux2 #(5)  muxreg(
    .d0(5'b11111),
    .d1(writemux),
    .s(regdst2),
    .y(writereg)
    );
    
    multiply    multi(
    .clk(clk),
    .enable(multien),
    .rs(srca),
    .rt(srcb),
    .hi(hi),
    .lo(lo)
    ); 
	
    fouronemux #(32) fourmuxtomux(
    .d0(pcbranch), 
    .d1(lo), 
    .d2(hi),
    .d3(resmuxtofour), 
    .s(fouronemux), 
    .y(result)
    );

//given
	flopr #(32) pcreg(
	.clk(clk),
	.reset(reset),
	.d(pcnext),
	.q(firstpc)
	);
		
	adder       pcadd1(
	.a(pc),
	.b(32'b100),
	.y(pcplus4)
	);

	sl2         immsh(
	.a(signimm),
	.y(signimmsh)
	);

	mux2 #(32)  pcbrmux(
	.d0(pcplus4),
	.d1(pcbranch),
	.s(pcsrc),
	.y(pcnextbr)
	);
	
	regfile		rf(
	.clk(clk),
	.we3(regwrite),
	.ra1(instr[25:21]),
	.ra2(instr[20:16]),
	.wa3(writereg),
	.wd3(result),
	.rd1(srca),
	.rd2(writedata)
	);
	
	mux2 #(5)	wrmux(
	.d0(instr[20:16]),
	.d1(instr[15:11]),
	.s(regdst),
	.y(writemux)
	);
	
	mux2 #(32)	resmux(
	.d0(aluout),
	.d1(readdata),
	.s(memtoreg),
	.y(resmuxtofour)
	);
	
	signext		se(
	.a(instr[15:0]),
	.y(signimm)
	);
	
	
	mux2 #(32)	srcbmux(
	.d0(writedata),
	.d1(signimm),
	.s(alusrc),
	.y(srcb)
	);
	
	alu			alu(
	.a(srca),
	.b(srcb),
	.alucont(alucontrol),
	.result(aluout),
	.zero(zero)
	);
	
	// Added
	mux2 #(32)  pcmux(
	.d0(firstpc),
	.d1(epc),
	.s(twoonemux),
	.y(pc)
	);
	
	EPC epcreg(
	.CLK(clk),
	.WE(epcwrite),
	.RE(epcread),
	.RST(reset),
    .ID(id),
	.PC(pcnext),
	.EPC(epc)
	);
	
	Priority_Encoder priority_encoder(
	.syscall(latched_syscall),
	.overflow(latched_overflow),
	.invalid(latched_invalid),
	.ext_int(latched_ext_int),
	.ID(id)
	);
	
	OR_4_to_1 Int_Or(
	.a(latched_syscall),
	.b(latched_overflow),
	.c(latched_invalid),
	.d(latched_ext_int),
	.out(interrupt)
	);
	
	IntLatch syscall_latch(
	.d(syscall),
	.q(latched_syscall),
	.en(syscall),
	.clr(latched_exdone & latched_syscall_clear)
	);
	
    IntLatch invalid_latch(
    .d(invalid),
    .q(latched_invalid),
    .en(invalid),
    .clr(latched_exdone & latched_invalid_clear)
    );
	
	IntLatch overflow_latch(
	.d(overflow),
	.q(latched_overflow),
	.en(overflow),
	.clr(latched_exdone & latched_overflow_clear)
	);
    
	IntLatch ext_int_latch(
    .d(ext_int),
    .q(latched_ext_int),
    .en(ext_int),
    .clr(latched_exdone & latched_extint_clear)
    );
    
    Done_Reg DoneRegister(
    .clk(clk),
    .rst(reset),
    .we(exdone),
    .re(~twoonemux),
    .d(exdone),
    .q(latched_exdone), 
    .in1(syscall_clear),
    .in2(invalid_clear),
    .in3(overflow_clear),
    .in4(extint_clear),
    .interrupt(interrupt),
    .out1(latched_syscall_clear),
    .out2(latched_invalid_clear),
    .out3(latched_overflow_clear),
    .out4(latched_extint_clear),
    .int_signal(orsignal)
    );
	
endmodule

// The MIPS (excluding the instruction and data memories)
module mips(
	input        	clk, reset, syscall, invalid, overflow, ext_int,
	output	[31:0]	pc,
	input 	[31:0]	instr,
	output			memwrite,
	output	[31:0]	aluout, writedata,
	input 	[31:0]	readdata
 );

	// deleted wire "branch" - not used
	wire 			memtoreg, pcsrc, zero, alusrc, regdst, regwrite, regdst2, signor4,
	                multien, twoonemux, epcread, epcwrite, exdone, orsignal, syscall_clear,
	                invalid_clear, overflow_clear, extint_clear;
	wire    [1:0]   jump, fouronemux, ID;
	wire	[2:0] 	alucontrol;

	controller c(
	.op(instr[31:26]),
	.funct(instr[5:0]),
	.ID(ID),
	.zero(zero),
	.orsignal(orsignal),   // added
	.memtoreg(memtoreg),
	.memwrite(memwrite),
	.pcsrc(pcsrc),
	.alusrc(alusrc),
	.regdst(regdst), 
	.regwrite(regwrite), 
	.regdst2(regdst2), 
	.signor4(signor4), 
	.multien(multien),
	.twoonemux(twoonemux), // added
    .epcwrite(epcwrite),   // added
    .epcread(epcread),     // added
    .exdone(exdone),       // added
	.jump(jump),
	.fouronemux(fouronemux),
	.alucontrol(alucontrol),
    .syscall_clear(syscall_clear), // added
    .invalid_clear(invalid_clear), // added
    .overflow_clear(overflow_clear), // added
    .extint_clear(extint_clear) // added

    );
	datapath dp(
	.clk(clk), 
	.reset(reset), 
	.memtoreg(memtoreg),
	.pcsrc(pcsrc),
	.alusrc(alusrc), 
	.regdst(regdst), 
	.regwrite(regwrite), 
	.regdst2(regdst2), 
	.signor4(signor4),
	.multien(multien),
	.twoonemux(twoonemux),     // added
	.syscall(syscall),         // added
	.invalid(invalid),         // added
	.overflow(overflow),       // added
	.ext_int(ext_int),         // added
	.epcwrite(epcwrite),       // added
	.epcread(epcread),         // added
	.exdone(exdone),           // added
	.jump(jump), 
	.fouronemux(fouronemux),
    .alucontrol(alucontrol),
    .zero(zero), 
    .orsignal(orsignal),        // added
    .id(ID),
    .pc(pc), 
    .instr(instr),
    .aluout(aluout), 
    .writedata(writedata), 
	.readdata(readdata),
    .syscall_clear(syscall_clear), // added
    .invalid_clear(invalid_clear), // added
    .overflow_clear(overflow_clear), // added
    .extint_clear(extint_clear) // added
	);
endmodule

// Instruction Memory
module imem (
	input	[ 5:0]	a,
	output 	[31:0]	dOut );
	
	reg		[31:0]	rom[0:63];
	
	//initialize rom from memfile_s.dat
	initial 
		$readmemh("memfile_s.dat", rom);
	
	//simple rom
    assign dOut = rom[a];
endmodule

// Data Memory
module dmem (
	input			clk,
	input			we,
	input	[31:0]	addr,
	input	[31:0]	dIn,
	output 	[31:0]	dOut );
	
	reg		[31:0]	ram[63:0];
	integer			n;
	
	//initialize ram to all FFs
	initial 
		for (n=0; n<64; n=n+1)
			ram[n] = 8'hFF;
		
	assign dOut = ram[addr[31:2]];
				
	always @(posedge clk)
		if (we) 
			ram[addr[31:2]] = dIn; 
endmodule