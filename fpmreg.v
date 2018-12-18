`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2018 11:04:43 AM
// Design Name: 
// Module Name: fpmreg
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


module fpmreg(
input [31:0] in,
input reset, en, clk,
output reg [31:0] out
    );
    
always @ (posedge clk, posedge reset)
    begin
        if (reset)
            begin
                out = 32'b0;
            end
        else
            begin
                out = (en) ? in : out;
            end     
    end    
endmodule

module fpmreg1(
input in,
input reset, en, clk,
output reg out
    );
    
always @ (posedge clk, posedge reset)
    begin
        if (reset)
            begin
                out = 0;
            end
        else
            begin
                out = (en) ? in : out;
            end     
    end    
endmodule

module fpmregres(
input [37:0] in,
input reset, en, clk,
output reg [37:0] out
    );
    
always @ (posedge clk, posedge reset)
    begin
        if (reset)
            begin
                out = 38'b0;
            end
        else
            begin
                out = (en) ? in : out;
            end     
    end    
endmodule