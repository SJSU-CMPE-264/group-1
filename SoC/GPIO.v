`timescale 1ns / 1ps

module GPIO(
input [1:0] a,
input we,
input [31:0] gpioinputone,
input [31:0] gpioinputtwo,
input [31:0] wd,
input clk,
output [31:0] rd,
output [31:0] gpiooutputone,
output [31:0] gpiooutputtwo
    );

wire we1;
wire we2;
wire [1:0] rdsel;
wire [31:0] gpioout1;
wire [31:0] gpioout2;    
    
gpioaddressdecoder GPIOAD(
 .a(a),
 .we(we),
 .we1(we1),
 .we2(we2),
 .rdsel(rdsel)
);

gpioreg GPIOREG1(
 .in(wd),
 .clk(clk),
 .enable(we1),
 .out(gpiooutputone)
);

gpioreg GPIOREG2(
 .in(wd),
 .clk(clk),
 .enable(we2),
 .out(gpiooutputtwo)
);

fouronemux #(32) GPIOFOURONEMUX(
 .d0(gpioinputone),
 .d1(gpioinputtwo), 
 .d2(gpiooutputone), 
 .d3(gpiooutputtwo),
 .s(rdsel),
 .y(rd)
);
    
endmodule
