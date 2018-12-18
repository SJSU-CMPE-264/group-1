`timescale 1ns / 1ps

module gpioaddressdecoder(
input [1:0] a,
input we,
output reg we1,
output reg we2,
output reg [1:0] rdsel
    );

always@(*)
begin
    case(a)
        2'b00:
            begin
            we1=0;
            we2=0;
            rdsel=a;
            end
        2'b01:
            begin
            we1=0;
            we2=0;
            rdsel=a;
            end
        2'b10:
            begin
            if(we)
                begin
                we1=we;
                we2=0;
                rdsel=a;
                end
            else
                begin
                we1=0;
                we2=0;
                rdsel=a;            
                end
            end
        2'b11:
            begin
            if(we)
                begin
                we1=0;
                we2=we;
                rdsel=a;
                end
            else
                begin
                we1=0;
                we2=0;
                rdsel=a;            
                end
            end
    endcase
end
endmodule