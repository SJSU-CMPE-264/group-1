`timescale 1ns / 1ps
module rslatch(
input s,
input r,
input clk,
input reset,
output reg q
    );

always@(posedge clk)
begin
if(reset==1)
    q=0;
else
begin    
if(s==1 && r==0)
    q=1;
else if(r==1 && s==0)
    q=0;    
else
    q=q;
end
end
endmodule
