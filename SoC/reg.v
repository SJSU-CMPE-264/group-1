module regi(regd, regload, regout, clk);
input [21:0] regd;
input regload;
output reg [21:0] regout;
input clk;

always@(posedge clk)
begin
if(regload)
    begin
    regout=regd;
    end
else
    begin
    regout=regout;
    end
end
endmodule