`timescale 1ns / 1ps

module faregn #(parameter WIDTH = 32)(
input [WIDTH-1:0] in,
input enable,
input clk,
output reg [WIDTH-1:0] out
    );
always@(posedge clk)
begin
if(enable)
    begin
    out=in;
    end
else
    begin
    out=out;
    end
end
endmodule
