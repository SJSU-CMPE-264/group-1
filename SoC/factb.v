`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2016 05:20:53 PM
// Design Name: 
// Module Name: factb
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


module factb;
reg [1:0] a;
reg we;
reg [3:0] wd;
reg rst;
reg clk;
wire [31:0] rd;
factorialtop DUT(a, we, wd, rst, clk, rd);
initial
begin
clk = 0;
#5;
rst = 1;
clk = 1;
#5;
clk = 0;
rst = 0;
a = 2'b00;
wd = 4'b0100;
we = 1;
#5;
clk = 1;
#5;
clk = 0;
we = 0;
#5;
clk = 1;
#5;
clk = 0;
we = 1;
a = 2'b01;
wd = 4'b0001;
#5;
clk = 1;
#5
clk = 0;
we = 0;
a = 2'b10;
clk = 1;
#5;
clk = 0;
#5;
clk = 1;
#5;
clk = 0;
while (rd[0] != 1)
begin
#5;
clk = 1;
#5;
clk = 0;
end
a = 2'b11;
#5;
clk = 1;
#5;
clk = 0;
#5;
clk = 1;
if (rd != 8'h00000018)
begin
$monitor("Test Failed D:");
$stop;
end
$monitor("Test Successful :D");
end
endmodule

