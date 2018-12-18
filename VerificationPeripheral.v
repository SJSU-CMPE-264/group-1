`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/17/2018 01:38:30 PM
// Design Name: 
// Module Name: VerificationPeripheral
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


module VerificationPeripheral(
input Clk, Rst, we,
input [31:0] addr_dm, wd_dm,
output [31:0] rd_dm,
output [3:0] ex_int
);

wire wefa, wem, wefpm, clk;
wire [1:0] rdsel;
wire [31:0] fpmdata, factdata, dmemdata;

assign clk = Clk;
    
addressdecoder ad(
.a(addr_dm),
.we(we),
.wefa(wefa),
.wegpio(ex_int[0]),
.wem(wem),
.wefpm(wefpm),
.rdsel(rdsel)
);

factorialtop fa(
 .a(addr_dm[3:2]),
 .we(wefa),
 .wd(wd_dm[3:0]),
 .rst(Rst),
 .clk(clk),
 .rd(factdata)
);

fouronemux #(32) selector(
.d0(dmemdata),
.d1(fpmdata),
.d2(factdata),
.d3(32'b0),
.s(rdsel), 
.y(rd_dm)
);

fpmwrapper fpm(
.a(addr_dm[3:2]),
.wd(wd_dm),
.we(wefpm),
.rst(Rst),
.clk(clk),
.rd(fpmdata),
.syscall(ex_int[1]),
.invalid(ex_int[2]),
.overflow(ex_int[3])
);

dmem dm(
.clk(clk),
.we(wem),
.addr(addr_dm),
.dIn(wd_dm),
.dOut(dmemdata)
);	
endmodule
