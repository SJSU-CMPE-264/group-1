`timescale 1ns / 1ps

module factorial(go, reset, in, clk, done, out,error);

input go;
input [3:0] in;
input reset;
input clk;
output done;
output [21:0] out;
output error;
wire gt;
wire load;
wire loadcnt;
wire en;
wire sel;
wire oe;


CU CONTROL(
    .go(go),
    .reset(reset),
    .gt(gt),
    .clk(clk),
    .load(load),
    .loadcnt(loadcnt),
    .en(en),
    .sel(sel),
    .oe(oe),
    .done(done)

);

DP DATAPATH(
    .reset(reset),
    .d(in),
    .loadcnt(loadcnt),
    .cnten(en),
    .clk(clk),
    .muxsel(sel),
    .regload(load),
    .oe(oe),
    .gt(gt),
    .out(out),
    .error(error)

);
endmodule
