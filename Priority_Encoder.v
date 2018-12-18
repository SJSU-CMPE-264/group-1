`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/16/2018 11:37:36 AM
// Design Name: 
// Module Name: Priority_Encoder
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


module Priority_Encoder(
    input syscall, overflow, invalid, ext_int,
    output reg [1:0]ID
    );
    // Don't need enable bit as it should always be
    // on as it is looking for interrupts
    always@(*)
    begin
        if(syscall)         ID <= 0;
        else if (invalid)   ID <= 1;
        else if (overflow)  ID <= 2;
        else if (ext_int)   ID <= 3;
        else                ID <= 3;
    end
endmodule
