`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2016 12:34:58 PM
// Design Name: 
// Module Name: gpiotb
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


module gpiotb;
reg [1:0] a;
reg we;
reg [31:0] gpioinputone;
reg [31:0] gpioinputtwo;
reg [31:0] wd;
reg clk;
wire [31:0] rd;
wire [31:0] gpiooutputone;
wire [31:0] gpiooutputtwo;
GPIO DUT(a, we, gpioinputone, gpioinputtwo, wd, clk, rd, gpiooutputone, gpiooutputtwo);
initial
begin
gpioinputone = 8'h00000045;
gpioinputtwo = 8'h0000002a;
clk = 1;
a = 2'b00;
we = 0;
#5;
clk = 0;
if (rd != 69)
begin
$monitor("Test Failed :(");
$stop;
end
#5;
clk = 1;
a = 2'b01;
#5;
clk = 0;
if (rd != 42)
begin
$monitor("Test Failed :(");
$stop;
end
wd = 8'h00000045;
#5;
clk = 1;
we = 1;
a = 2'b10;
#5;
clk = 0;
if (rd != 69)
begin
$monitor("Test Failed :(");
$stop;
end
wd = 8'h0000002a;
#5;
clk = 1;
a = 2'b11;
#5;
clk = 0;
if (rd != 42)
begin
$monitor("Test Failed :(");
$stop;
end
$monitor("Test Successful!!!!! :D");
end
endmodule
