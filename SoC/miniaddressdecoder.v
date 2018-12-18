`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2016 08:40:06 PM
// Design Name: 
// Module Name: miniaddressdecoder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module miniaddressdecoder(
input [1:0] a,
input we,
output reg we1,
output reg we2,
output reg [1:0]rdsel
    );

always@(*)
begin
if(we==0)
    begin
        case(a)
        2'b00:
            begin
            we1=0;
            we2=0;
            rdsel=2'b00;
            end
        2'b01:
            begin
            we1=0;
            we2=0;
            rdsel=2'b01;
            end
        2'b10:
            begin
            we1=0;
            we2=0;
            rdsel=2'b10;
            end
        2'b11:
            begin
            we1=0;
            we2=0;
            rdsel=2'b11;      
            end
       endcase
    end    
if(we==1)
    begin
        case(a)
        2'b10:
            begin
            we1=1;
            we2=0;
            rdsel=2'b10;
            end
        2'b11:
            begin
            we1=0;
            we2=1;
            rdsel=2'b11;
            end
       endcase
    end
end
endmodule
