`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2016 07:10:51 PM
// Design Name: 
// Module Name: topsoctb
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


module topsoctb();
reg clk_tb, reset_tb;
wire [31:0] gpo1_tb, gpo2_tb;

system TEST(
 .clk(clk_tb),
 .reset(reset_tb),
 .gpi1(8'h00000005),
 .gpi2(32'b1),
 .gpo1(gpo1_tb),
 .gpo2(gpo2_tb)
);
initial
begin
   reset_tb <= 1; # 22; reset_tb <= 0;
end

// generate clock to sequence tests
always
 begin
   clk_tb <= 1; # 5; clk_tb <= 0; # 5;
 end

always@(negedge clk_tb)
begin
if(gpo2_tb===120)
    begin
    $monitor("Success");
    #5;
    $stop;
    end    
end
endmodule