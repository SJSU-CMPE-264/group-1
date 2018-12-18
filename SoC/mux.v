module mux #(parameter width=22) (a,b,c,sel);
input [width-1:0] a;
input [width-1:0] b;
output reg [width-1:0] c;
input sel;

always@(*)
begin
if(sel)
    begin
    c=b;
    end
else
    begin
    c=a;
    end
end
endmodule