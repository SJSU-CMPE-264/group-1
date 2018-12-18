`timescale 1ns / 1ps

module mipstb;

reg reset_tb;
reg clk_tb;
reg wem_tb;
wire [31:0] pc_tb, instr_tb;
reg [31:0] readdata_tb;
wire memwrite_tb;
wire [31:0] dataaddr_tb, writedata_tb;
wire [31:0] dmemdata_tb;


mips mipstb(
 .clk(clk_tb),
 .reset(reset_tb),
 .pc(pc_tb),
 .instr(instr_tb),
 .memwrite(memwrite_tb),
 .aluout(dataaddr_tb),
 .writedata(writedata_tb),
 .readdata(readdata_tb)
 );
 
imem imemtb(
 .a(pc_tb[7:2]),
 .dOut(instr_tb)
);

dmem dmemtb(
 .clk(clk_tb),
 .we(wem_tb),
 .addr({26'b0,dataaddr_tb[7:2]}),
 .dIn(writedata_tb),
 .dOut(dmemdata_tb)
);

initial
begin
reset_tb=1;
clk_tb=0;
wem_tb=1;
readdata_tb=0;
#10;

reset_tb=0;
#10;

clk_tb=~clk_tb;
#10;
clk_tb=~clk_tb;
#10;

clk_tb=~clk_tb;
#10;
clk_tb=~clk_tb;
#10;

clk_tb=~clk_tb;
#10;
clk_tb=~clk_tb;
#10;

clk_tb=~clk_tb;
#10;
clk_tb=~clk_tb;
#10;

clk_tb=~clk_tb;
#10;
clk_tb=~clk_tb;
#10;


end
endmodule
