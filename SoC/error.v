`timescale 1ns / 1ps

module error(
input load,
input clk,
input [3:0] n,
output reg error
    );
always@(posedge clk)
begin
if(load)
    begin
    if(n>12)
        begin
        error=1;
        end
    else
        begin
        error=0;
        end
    end
end     
endmodule
