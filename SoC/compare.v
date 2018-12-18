`timescale 1ns / 1ps

module compare(compin1, compin2, compout);
input [3:0] compin1;
input [3:0] compin2;
output reg compout;

always@(*)
begin

if(compin1 > compin2)
    begin
    compout=1;
    end
else
    begin
    compout=0;
    end
end
endmodule
