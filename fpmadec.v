`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2018 01:16:59 PM
// Design Name: 
// Module Name: fpmadec
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


module fpmadec(
input [1:0] a,
input we,
output reg we0, we1, we3,
output reg [1:0] rdsel
    );
    
always @ (*)
    begin
        case (a)
            2'b00:
                begin
                    we0 = we;
                    we1 = 0;
                    we3 = 0;
                    rdsel = 2'b00;
                end
            2'b01:
                begin
                    we0 = 0;
                    we1 = we;
                    we3 = 0;
                    rdsel = 2'b01;
                end    
            2'b10:
                begin
                    we0 = 0;
                    we1 = 0;
                    we3 = we;
                    rdsel = 2'b10;
                end    
            2'b11:
                begin
                    we0 = 0;
                    we1 = 0;
                    we3 = 0;
                    rdsel = 2'b11;
                end    
        endcase
    end    
endmodule
