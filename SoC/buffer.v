`timescale 1ns / 1ps

module buffer(regin, oe, out);
input [21:0] regin;
input oe;
output reg [21:0] out;

always@(*)
if(oe)
    begin
    out=regin;
    end
else
    begin
    out=22'bZ;
    end    
endmodule
