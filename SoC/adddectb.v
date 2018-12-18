`timescale 10ns / 10ps

module adddectb;
reg [31:0] a_tb;
reg we_tb;
wire wefa_tb, wegpio_tb, wem_tb;
wire [1:0] rdsel_tb;

reg [4:0] test;

addressdecoder DUT(
 .a(a_tb),
 .we(we_tb),
 .wefa(wefa_tb),
 .wegpio(wegpio_tb),
 .wem(wem_tb),
 .rdsel(rdsel_tb)
 );
 
initial
begin
a_tb = 32'h000000ed;
we_tb=0;
#10;
we_tb=1;
#10;
if(wefa_tb != 0 && wegpio_tb !=0 && wem_tb != 1 && rdsel_tb != 2'b00)
    begin
    $monitor("Failed");
    $stop;
    end
we_tb=0;
#10;

a_tb = 32'h00000806;
#10;
we_tb=1;
#10;
if(wefa_tb != 1 && wegpio_tb !=0 && wem_tb != 0 && rdsel_tb != 2'b10)
    begin
    $monitor("Failed");
    $stop;
    end
we_tb=0;
#10;

a_tb = 32'h00000907;
#10;
we_tb=1;
#10;
if(wefa_tb != 0 && wegpio_tb != 1 && wem_tb != 0 && rdsel_tb != 2'b11)
    begin
    $monitor("Failed");
    $stop;
    end
we_tb=0;
#10;


$monitor("Test Success!!!!! :D");
end
endmodule
