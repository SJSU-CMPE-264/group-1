`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/27/2018 04:46:07 PM
// Design Name: 
// Module Name: fpmwrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fpmwrapper(
input [1:0] a,
input [31:0] wd,
input we, rst, clk,
output [31:0] rd,
output syscall, invalid, overflow
    );
    
wire we0, we1, we3;
wire [1:0] rdsel;
wire [31:0] opa, opb, p;
wire start;
wire of, uf, nanf, inff, dnf, zf, done;
wire resp, resof, resuf, resnanf, resinff, resdnf, reszf;
wire startreqcmb, startreq, donedly, startpulsecmb;
wire resdone;

assign startreqcmb = wd[0] & we3;
assign startpulsecmb = startreq & ~donedly;
assign syscall = done;
assign invalid = done & (resdnf | reszf | resuf);
assign overflow = done & (resof | resinff);
    
fpmadec AddDec(
.a(a),
.we(we),
.we0(we0),
.we1(we1),
.we3(we3),
.rdsel(rdsel)
);    

fouronemux FPMWrapperOutput(
.d0(opa),
.d1(opb),
.d2(resp),
.d3({15'b0, start, 2'b0,resof, resuf, resnanf, resinff, resdnf, reszf,7'b0,resdone}),
.s(rdsel),
.y(rd)
);

fpmreg OperandA(
.in(wd),
.reset(rst),
.en(we0),
.clk(clk),
.out(opa)
);

fpmreg OperandB(
.in(wd),
.reset(rst),
.en(we1),
.clk(clk),
.out(opb)
);

fpmreg1 StartBit(
.in(wd[0]),
.reset(rst),
.en(we3),
.clk(clk),
.out(start)
);

fpmreg1 StartReqBit(
.in(startreqcmb),
.reset(rst),
.en(1'b1),
.clk(clk),
.out(startreq)
);

fpmreg1 DoneBit(
.in(done),
.reset(rst),
.en(1'b1),
.clk(clk),
.out(donedly)
);

fpmul MultiplyFP(
.Clk(clk),
.Rst(rst),
.Start(startpulsecmb),
.Done(done),
.P(p),
.UF(uf),
.OF(of),
.NaNF(nanf),
.InfF(inff),
.DNF(dnf),
.ZF(zf),
.A(opa),
.B(opb)
);

fpmregres ResultRegister(
.in({p, of, uf, nanf, inff, dnf, zf}),
.reset(rst),
.en(done),
.clk(clk),
.out({resp, resof, resuf, resnanf, resinff, resdnf, reszf})
);

rslatch FPMLatch(
.s(done),
.r(startreqcmb),
.clk(clk),
.reset(rst),
.q(resdone)
);

 
endmodule
