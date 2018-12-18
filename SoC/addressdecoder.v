`timescale 1ns / 1ps

module addressdecoder(
input [31:0] a,
input we,
output reg wefa,
output reg wegpio,
output reg wem,
output reg wefpm,
output reg [1:0] rdsel
    ); 
always@(*)
begin
if(we)
    begin
    if(a < 32'h000000fc || a == 32'h000000fc)
        begin
        wem=1;
        wefa=0;
        wegpio=0;
        wefpm=0;
        rdsel=2'b00;
        end
    else if (a > 32'h000007ff && a < 32'h0000080d)
        begin
        wem=0;
        wefa=1;
        wegpio=0;
        wefpm=0;
        rdsel=2'b10;
        end
    else if (a > 32'h000008ff && a < 32'h0000090d)
        begin
        wem=0;
        wefa=0;
        wegpio=1;
        wefpm=0;
        rdsel=2'b11;
        end
    else if (a > 32'h000009ff && a < 32'h00000a0d)
        begin
        wem=0;
        wefa=0;
        wegpio=0;
        wefpm=1;
        rdsel=2'b01;
        end 
    end
else
    begin
    if(a < 32'h000000fc || a == 32'h000000fc)
        begin
        wem=0;
        wefa=0;
        wegpio=0;
        rdsel=2'b00;
        end
    else if (a > 32'h000007ff && a < 32'h0000080d)
        begin
        wem=0;
        wefa=0;
        wegpio=0;
        rdsel=2'b10;
        end
    else if (a > 32'h000008ff && a < 32'h0000090d)
        begin
        wem=0;
        wefa=0;
        wegpio=0;
        rdsel=2'b11;
        end
    else if (a > 32'h000009ff && a < 32'h00000a0d)
        begin
        wem=0;
        wefa=0;
        wegpio=0;
        wefpm=0;
        rdsel=2'b01;
        end 
    end
end
endmodule
