`timescale 1ns / 1ps

module mips_top(
	input	clk, reset, 
	output	memwrite,
	output	[ 7:0] 	LEDSEL, 
	output 	[ 7:0]	LEDOUT,
	input	[ 7:0]	switches,
	output	sinkBit 
	
	);

	wire	[31:0] 	pc, instr, dataadr, writedata, readdata, dispDat;
	wire 	clksec;
	reg		[ 15:0] 	reg_hex;
	
	wire clk_5KHz;

	// Clock (1 second) to slow down the running of the instructions
	//clk_gen top_clk(.clk50MHz(clk), .reset(reset), .clksec(clksec));

	// Instantiate processor and memories	
	mips mips(
	.clk(clksec), 
	.reset(reset), 
	.pc(pc),
	.instr(instr), 
	.memwrite(memwrite),
	.aluout(dataadr),
	.writedata(writedata), 
	.readdata(readdata),
	.dispSel(switches[4:0]),
	.dispDat(dispDat)
	
	);
 
	imem imem(
	.a(pc[7:2]),
	.dOut(instr)
	
	);
	
	dmem dmem(
	.clk(clk), 
	.we(memwrite), 
	.addr(dataadr),
	.dIn(writedata),
	.dOut(readdata)
	
	);
endmodule