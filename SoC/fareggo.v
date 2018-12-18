`timescale 1ns / 1ps

module fareggo(
input in,
input enable,
input clk,
output reg out
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
