`timescale 1ns / 1ps

module factorialtop(
input [1:0] a,
input we,
input [3:0] wd,
input rst,
input clk,
output [31:0] rd
);

wire we1;
wire we2;
wire [1:0] rdsel;
wire [3:0] n;
wire go;
wire gopulsecmb;
wire gopulse;
wire done;
wire [21:0] nf;
wire resdone;
wire reserror;
wire [31:0] result;
wire error;


faaddressdecoder FAAD(
 .a(a),
 .we(we),
 .we1(we1),
 .we2(we2),
 .rdsel(rdsel)
);

faregn #(4) FAN(
 .in(wd),
 .enable(we1),
 .clk(clk),
 .out(n)
);

fareggo FAGO(
 .in(wd[0]),
 .enable(we2),
 .clk(clk),
 .out(go)
);

fareggopulse FAGOPULSE(
 .in(gopulsecmb),
 .clk(clk),
 .out(gopulse)
);

andmodule AND(
 .a(we2),
 .b(wd[0]),
 .c(gopulsecmb)
);

factorial FA(
 .go(gopulse),
 .in(n),
 .reset(rst),
 .clk(clk),
 .done(done),
 .out(nf),
 .error(error)
);

rslatch RESDONE(
 .s(done),
 .r(gopulsecmb),
 .clk(clk),
 .reset(rst),
 .q(resdone)
);

rslatch RESERROR(
 .s(error),
 .r(gopulsecmb),
 .clk(clk),
 .reset(rst),
 .q(reserror)
);

faregn #(32) RESULT(
 .in({10'b0,nf}),
 .enable(done),
 .clk(clk),
 .out(result)
);

fouronemux #(32) FAFOURONEMUX(
 .d0({28'b0,n}),
 .d1({31'b0,go}),
 .d2({30'b0,reserror,resdone}),
 .d3(result),
 .s(rdsel),
 .y(rd)
);


endmodule
