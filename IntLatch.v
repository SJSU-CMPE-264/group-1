`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/01/2018 03:12:01 PM
// Design Name: 
// Module Name: IntLatch
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


module IntLatch(
input d, clr, en, 
output reg q
    );
    reg signal;
always @ (*)
    begin
        if (clr)
            begin
                q <= 0;
            end
        else
            begin
                q <= (en) ? d : q;
            end
    end    
endmodule
