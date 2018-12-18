`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/17/2018 01:39:36 PM
// Design Name: 
// Module Name: VerificationTopLevel
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


module VerificationTopLevel(
input Clk, Rst,
input [3:0] ex_int,
input [31:0] instr,
input [31:0] rd_dm,
output we_dm,
output [31:0] addr_dm, wd_dm, pc_current, epc
    );
    
	// deleted wire "branch" - not used
    wire             memtoreg, pcsrc, zero, alusrc, regdst, regwrite, regdst2, signor4,
                    multien, twoonemux, epcread, epcwrite, exdone, orsignal, syscall_clear,
                    invalid_clear, overflow_clear, extint_clear;
    wire    [1:0]   jump, fouronemux, id;
    wire    [2:0]     alucontrol;

    wire syscall, invalid, overflow, ext_int;
    
    wire clk, reset, memwrite;
    wire [31:0] pc, EPC, aluout, writedata, readdata;
    
    //Inputs
    assign {syscall, invalid, overflow, ext_int} = ex_int;
    assign clk = Clk;
    assign reset = Rst;
    assign readdata = rd_dm;
    
    //Outputs
    assign we_dm = memwrite;
    assign addr_dm = aluout;
    assign wd_dm = writedata;
    assign pc_current = pc;
    assign epc = EPC;
    
    controller c(
    .op(instr[31:26]),
    .funct(instr[5:0]),
    .ID(id),
    .zero(zero),
    .orsignal(orsignal),   // added
    .memtoreg(memtoreg),
    .memwrite(memwrite),
    .pcsrc(pcsrc),
    .alusrc(alusrc),
    .regdst(regdst), 
    .regwrite(regwrite), 
    .regdst2(regdst2), 
    .signor4(signor4), 
    .multien(multien),
    .twoonemux(twoonemux), // added
    .epcwrite(epcwrite),   // added
    .epcread(epcread),     // added
    .exdone(exdone),       // added
    .jump(jump),
    .fouronemux(fouronemux),
    .alucontrol(alucontrol),
    .syscall_clear(syscall_clear), // added
    .invalid_clear(invalid_clear), // added
    .overflow_clear(overflow_clear), // added
    .extint_clear(extint_clear) // added

    );
 
        wire        latched_syscall, latched_invalid, latched_overflow, latched_ext_int, latched_exdone,
                    latched_syscall_clear, latched_invalid_clear, latched_overflow_clear, latched_extint_clear,
                    interrupt;
        wire [4:0]  writereg, writemux;
        wire [31:0] pcnext, pcnextbr, pcplus4, pcbranch, signimm, signimmsh, srca, srcb, result, signtomux, muxtobran, hi, lo;
        wire [31:0] resmuxtofour, firstpc;
    
        
    //new
        fouronemux #(32) fourmuxtopc(
        .d0(pcnextbr), 
        .d1(srca), 
        .d2({pcplus4[31:28], signtomux[27:0]}),
        .d3(pcplus4), 
        .s(jump), 
        .y(pcnext)
        );
        
        adder       pcadd2(
        .a(muxtobran),
        .b(pcplus4),
        .y(pcbranch)
        );
        
        sl2         immtomux(
        .a({6'b0, instr[25:0]}),
        .y(signtomux)
        );
        
        mux2 #(32)  signtobran(
        .d0(signimmsh),
        .d1(32'b0),
        .s(signor4),
        .y(muxtobran)
        );
    
        mux2 #(5)  muxreg(
        .d0(5'b11111),
        .d1(writemux),
        .s(regdst2),
        .y(writereg)
        );
        
        multiply    multi(
        .clk(clk),
        .enable(multien),
        .rs(srca),
        .rt(srcb),
        .hi(hi),
        .lo(lo)
        ); 
        
        fouronemux #(32) fourmuxtomux(
        .d0(pcbranch), 
        .d1(lo), 
        .d2(hi),
        .d3(resmuxtofour), 
        .s(fouronemux), 
        .y(result)
        );
    
    //given
        flopr #(32) pcreg(
        .clk(clk),
        .reset(reset),
        .d(pcnext),
        .q(firstpc)
        );
            
        adder       pcadd1(
        .a(pc),
        .b(32'b100),
        .y(pcplus4)
        );
    
        sl2         immsh(
        .a(signimm),
        .y(signimmsh)
        );
    
        mux2 #(32)  pcbrmux(
        .d0(pcplus4),
        .d1(pcbranch),
        .s(pcsrc),
        .y(pcnextbr)
        );
        
        regfile        rf(
        .clk(clk),
        .we3(regwrite),
        .ra1(instr[25:21]),
        .ra2(instr[20:16]),
        .wa3(writereg),
        .wd3(result),
        .rd1(srca),
        .rd2(writedata)
        );
        
        mux2 #(5)    wrmux(
        .d0(instr[20:16]),
        .d1(instr[15:11]),
        .s(regdst),
        .y(writemux)
        );
        
        mux2 #(32)    resmux(
        .d0(aluout),
        .d1(readdata),
        .s(memtoreg),
        .y(resmuxtofour)
        );
        
        signext        se(
        .a(instr[15:0]),
        .y(signimm)
        );
        
        
        mux2 #(32)    srcbmux(
        .d0(writedata),
        .d1(signimm),
        .s(alusrc),
        .y(srcb)
        );
        
        alu            alu(
        .a(srca),
        .b(srcb),
        .alucont(alucontrol),
        .result(aluout),
        .zero(zero)
        );
        
        // Added
        mux2 #(32)  pcmux(
        .d0(firstpc),
        .d1(EPC),
        .s(twoonemux),
        .y(pc)
        );
        
        EPC epcreg(
        .CLK(clk),
        .WE(epcwrite),
        .RE(epcread),
        .RST(reset),
        .ID(id),
        .PC(pcnext),
        .EPC(EPC)
        );
        
        Priority_Encoder priority_encoder(
        .syscall(latched_syscall),
        .overflow(latched_overflow),
        .invalid(latched_invalid),
        .ext_int(latched_ext_int),
        .ID(id)
        );
        
        OR_4_to_1 Int_Or(
        .a(latched_syscall),
        .b(latched_overflow),
        .c(latched_invalid),
        .d(latched_ext_int),
        .out(interrupt)
        );
        
        IntLatch syscall_latch(
        .d(syscall),
        .q(latched_syscall),
        .en(syscall),
        .clr(latched_exdone & latched_syscall_clear)
        );
        
        IntLatch invalid_latch(
        .d(invalid),
        .q(latched_invalid),
        .en(invalid),
        .clr(latched_exdone & latched_invalid_clear)
        );
        
        IntLatch overflow_latch(
        .d(overflow),
        .q(latched_overflow),
        .en(overflow),
        .clr(latched_exdone & latched_overflow_clear)
        );
        
        IntLatch ext_int_latch(
        .d(ext_int),
        .q(latched_ext_int),
        .en(ext_int),
        .clr(latched_exdone & latched_extint_clear)
        );
        
        Done_Reg DoneRegister(
        .clk(clk),
        .rst(reset),
        .we(exdone),
        .re(~twoonemux),
        .d(exdone),
        .q(latched_exdone), 
        .in1(syscall_clear),
        .in2(invalid_clear),
        .in3(overflow_clear),
        .in4(extint_clear),
        .interrupt(interrupt),
        .out1(latched_syscall_clear),
        .out2(latched_invalid_clear),
        .out3(latched_overflow_clear),
        .out4(latched_extint_clear),
        .int_signal(orsignal)
        );

endmodule
