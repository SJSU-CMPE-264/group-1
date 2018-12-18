`timescale 1ns / 1ps

module gpioreg(
input [31:0] in,
input clk,
input enable,
output reg [31:0] out
    );

always@(posedge clk)
begin
if (enable)
    begin
    out=in;
    end
else
    begin
    out=out;
    end
end
endmodule
