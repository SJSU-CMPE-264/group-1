`timescale 1ns / 1ps
module fpgatop(
input reset,
input sel,
input clk,
input [3:0] n,
input ext_int,
output [7:0] LEDSEL,
output [7:0] LEDOUT,
output dispsel,
output facterror
    );

wire clksec;
wire sysclk;
wire [31:0] gpo2;
wire [16:0] hex;

wire [7:0] digit0;
wire [7:0] digit1;
wire [7:0] digit2;
wire [7:0] digit3;
wire [7:0] digit4;
wire [7:0] digit5;
wire [7:0] digit6;
wire [7:0] digit7;

wire [31:0] gpo1l2;

assign dispsel=gpo1l2[1];
assign facterror=gpo1l2[0];

clk_gen CLK(
 .clk100MHz(clk),
 .rst(reset), 
 .clk_sec(clksec),
 .clk_5KHz(sysclk)
);

system system(
 .clk(sysclk),
 .reset(reset),
 .gpi1({27'b0,sel,n}),
 .gpi2(gpo1l2),
 .gpo1(gpo1l2),
 .gpo2(gpo2),
 .ext_int(ext_int)
);

mux2 #(16) fpgamux(
 .d0(gpo2[15:0]),
 .d1(gpo2[31:16]),
 .s(gpo1l2[1]),
 .y(hex)
);

    bcd_to_7seg bcd0 (hex[3:0], digit7);
    bcd_to_7seg bcd1 (hex[7:4], digit6);
    bcd_to_7seg bcd2 (hex[11:8], digit5);
    bcd_to_7seg bcd3 (hex[15:12], digit4);
    bcd_to_7seg bcd4 (4'b0000, digit3);
    bcd_to_7seg bcd5 (4'b0000, digit2);
    bcd_to_7seg bcd6 (4'b0000, digit1);
    bcd_to_7seg bcd7 (4'b0000, digit0);    

    LED_MUX disp_unit (
        sysclk,
        reset,
        digit0,
        digit1,
        digit2,
        digit3,
        digit4,
        digit5,
        digit6,
        digit7,
        LEDOUT,
        LEDSEL        
        );
endmodule
