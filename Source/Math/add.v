`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Mario-Hero
// 
// Create Date: 12/02/2019 09:13:54 PM
// Module Name: add
// Description: When req rises, x+y+cin -> so, 
//							  Carry Out -> couto. Then fin rises.
// 
// Dependencies: fullAdder
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module add #(parameter N=32) (req,fin,cin,x,y,so,couto);
input req,cin;
input [N-1:0] x,y;
output reg fin=1'b1;
output reg [N-1:0] so=0;
output reg couto=1'b0;

wire [N-1:0] s;
wire cout;
reg rec=1'b0;
wire fin_add;
wire [N:0] c,f,ft;

assign c[0]=cin;
assign cout=c[N];
assign f[0]=rec;
assign ft[0]=f[0];
assign fin_add=ft[N];

always@(posedge req or posedge fin_add) begin
if(fin_add) begin
	fin<=1'b1;
	rec<=1'b0;
	so<=s;
	couto<=cout;
end
else begin
	fin<=1'b0;
	rec<=1'b1;
	so<=0;
	couto<=1'b0;
end
end

genvar i;
generate 
	for(i=0;i<N;i=i+1)
	begin:fullAdder
		fullAdder fullAdder (rec,f[i],f[i+1],c[i],x[i],y[i],s[i],c[i+1]);
		assign ft[i+1]=f[i]&ft[i];
	end
endgenerate

endmodule

