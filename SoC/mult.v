module mult(x,y,z);
input [3:0] x;
input [21:0] y;
output reg [21:0] z;

always@(*)
begin
z = x*y;
end
endmodule