`timescale 1ns / 1ps

module andmodule(
input a,
input b,
output reg c
    );
always@(*)
begin
c = a && b;
end
endmodule
