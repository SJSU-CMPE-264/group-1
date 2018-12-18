`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/07/2018 06:09:38 PM
// Design Name: 
// Module Name: EPC
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


module EPC(
    input CLK, WE, RE, RST,
    input [1:0] ID,
    input [31:0] PC,
    output reg [31:0] EPC
    );
    
    reg [31:0]latched_PC;
    
    always@(posedge CLK, posedge RST)
    begin
        if(RST)       latched_PC <= 0;
        else if(WE)
        begin
            latched_PC <= PC;
            case(ID)
                2'b00: EPC <= 108;
                2'b01: EPC <= 120;
                2'b10: EPC <= 132;
                2'b11: EPC <= 144; // This still points to a dummy procedure
                default: EPC <= 0;
            endcase
        end
        else if(RE)     EPC <= latched_PC;
        else            EPC <= PC;
    end
endmodule
