`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/03/2016 09:04:49 PM
// Design Name: 
// Module Name: DP
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


module DP(reset, d, loadcnt, cnten, clk, muxsel, regload, oe, gt, out, error);

input reset;
input [3:0] d;
input loadcnt;
input cnten;
input clk;
input muxsel;
input regload;
input oe;
output gt;
output [21:0] out;
output error;
wire [21:0] muxtoreg;
wire [21:0] multtomux;
wire [3:0] cntout;
wire [21:0] regout;

mux #(22) M1(
    .a(22'b000000000000000000001),
    .b(multtomux),
    .c(muxtoreg),
    .sel(muxsel)
);

cnt C1(
    .cntin(d),
    .cntload(loadcnt),
    .cnten(cnten),
    .clk(clk),
    .cntq(cntout)
);

regi REGFILE(
    .regd(muxtoreg),
    .regload(regload),
    .regout(regout),
    .clk(clk)
);

compare CMP(
    .compin1(cntout),
    .compin2(4'b0001),
    .compout(gt)
    
);

mult MULT1(
    .x(cntout),
    .y(regout),
    .z(multtomux)

);

buffer BUFF(
    .regin(regout),
    .oe(oe),
    .out(out)
);

error ERROR(
 .load(loadcnt),
 .clk(clk),
 .n(d),
 .error(error)
    );

endmodule
