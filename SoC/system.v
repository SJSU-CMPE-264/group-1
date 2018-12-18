`timescale 1ns / 1ps
module system(
input clk,
input reset,
input ext_int,
input [31:0] gpi1,
input [31:0] gpi2,
output [31:0] gpo1,
output [31:0] gpo2
);

  wire [31:0] pc, instr, readdata, dmemdata, factdata, gpiodata, dataaddr, writedata, fpmdata;
  wire we2, we1, wem, memwrite, wefpm, syscall, invalid, overflow;
  wire [1:0] rdsel;
  
  // instantiate processor and memories
mips mips(
 .clk(clk),
 .reset(reset),
 .pc(pc),
 .instr(instr),
 .memwrite(memwrite),
 .aluout(dataaddr),
 .writedata(writedata),
 .readdata(readdata),
 .ext_int(ext_int)
 );
 
imem imem(
 .a(pc[7:2]),
 .dOut(instr)
);

dmem dmem(
 .clk(clk),
 .we(wem),
 .addr({26'b0,dataaddr[7:2]}),
 .dIn(writedata),
 .dOut(dmemdata)
);

addressdecoder ad(
 .a(dataaddr),
 .we(memwrite),
 .wefa(we1),
 .wegpio(we2),
 .wem(wem),
 .wefpm(wefpm),
 .rdsel(rdsel)
 );
 
factorialtop fa(
 .a(dataaddr[3:2]),
 .we(we1),
 .wd(writedata[3:0]),
 .rst(reset),
 .clk(clk),
 .rd(factdata)
);

GPIO gp (
 .a(dataaddr[3:2]),
 .we(we2),
 .gpioinputone(gpi1),
 .gpioinputtwo(gpi2),
 .wd(writedata),
 .clk(clk),
 .rd(gpiodata),
 .gpiooutputone(gpo1),
 .gpiooutputtwo(gpo2)
);

fouronemux #(32) selector(
.d0(fpmdata),
.d1(dmemdata),
.d2(factdata),
.d3(gpiodata),
.s(rdsel), 
.y(readdata)
);

fpmwrapper fpm(
.a(dataaddr[3:2]),
.wd(dmemdata),
.we(wefpm),
.rst(reset),
.clk(clk),
.rd(fpmdata),
.syscall(syscall),
.invalid(invalid),
.overflow(overflow)
);

endmodule
