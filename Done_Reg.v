`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/15/2018 03:16:09 PM
// Design Name: 
// Module Name: Done_Reg
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


module Done_Reg(
    input clk, rst, we, re, d, in1, in2, in3, in4, interrupt,
    output reg q, out1, out2, out3, out4, int_signal
    );
    
    reg done, int1, int2, int3, int4;
    reg [1:0] counter = 0;
    
    always@(posedge clk)
    begin
        if(rst)
        begin
            done <= 0;
            int1 <= 0;
            int2 <= 0;
            int3 <= 0;
            int4 <= 0;
        end
        else if(we)
        begin
            done <= d;
            int1 <= in1;
            int2 <= in2;
            int3 <= in3;
            int4 <= in4;
        end
        else if(re)
        begin
            q <= done;
            out1 <= int1;
            out2 <= int2;
            out3 <= int3;
            out4 <= int4;
        end
    end
    always@(posedge clk)
    begin
        if(done && !counter) counter <= 1;
        else if(counter == 2)
        begin
            counter <= 0;
            int_signal <= interrupt;
        end
        else if(counter)
        begin
            int_signal <= 0;
            counter <= counter + 1;
        end
        else int_signal <= interrupt; 
    end
endmodule
