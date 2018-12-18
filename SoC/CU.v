`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/04/2016 12:41:21 PM
// Design Name: 
// Module Name: CU
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


module CU(go, reset, gt, clk, load, loadcnt, en, sel, oe, done);

input go;
input reset;
input gt;
input clk;
output reg load;
output reg loadcnt;
output reg en;
output reg sel;
output reg oe;
output reg done;

reg [2:0] ns;
reg [2:0] cs;

parameter state0 = 3'b000;
parameter state1 = 3'b001;
parameter state2 = 3'b010;
parameter state3 = 3'b011;
parameter state4 = 3'b100;

always@(posedge clk, posedge reset)
begin
    if(reset)
        begin
        cs<=state0;
        end
    else
        begin
        cs<=ns;
        end
end

always@(cs, go)
begin
    case(cs)
        state0: begin
                if(go)
                    begin
                    ns=state1;
                    end
                else
                    begin
                    ns=state0;
                    end
                end
        
        state1: begin
                    ns=state2;
                end 
      
        state2:begin
               if(gt)
                    begin
                    ns=state3;
                    end
               else
                    begin
                    ns=state4;
                    end
               end
        
        state3:begin
               ns=state2;
               end
        
        state4:begin
               ns=state0;
               end
    
        default:begin
                ns=state0;
                end
    endcase
end

always@(*)
begin
    case(cs)
        state0: begin
                load=0;
                loadcnt=0;
                en=0;
                sel=0;
                oe=0;
                done=0;
                end
        
        state1: begin
                load=1;
                loadcnt=1;
                en=0;
                sel=0;
                oe=0;
                done=0;
                end
                
        state2: begin
                load=0;
                loadcnt=0;
                en=0;
                sel=1;
                oe=0;
                done=0;
                end
                
        state3: begin
                load=1;
                loadcnt=0;
                en=1;
                sel=1;
                oe=0;
                done=0;
                end
                
        state4: begin
                load=0;
                loadcnt=0;
                en=0;
                sel=0;
                oe=1;
                done=1;
                end
    endcase
end
endmodule
