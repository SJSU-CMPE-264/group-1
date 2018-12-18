module cnt(cntin, cntload, cnten, clk, cntq);

input [3:0] cntin;
input cntload;
input cnten;
input clk;
output reg [3:0] cntq;

always@(posedge clk)
begin

if(cntload)
    begin
    cntq=cntin;
    end
else
    begin
    cntq=cntq;
    end
    
if(cnten)
    begin
    cntq=cntq-1;
    end
else
    begin
    cntq=cntq;
    end

end
endmodule