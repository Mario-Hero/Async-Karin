`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Mario-Hero 
//
// Create Date: 11/30/2019 04:51:46 PM
// Module Name: equalOrNot
// Description: When req rises, if x==y then equal rises 
//                              else notEqual rises
// 
// Dependencies: oneEqual
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module equalOrNot #(parameter Width=32) (req,equal,notEqual,x,y);
input req;
input [Width-1:0] x,y;
output reg equal=1'b0,notEqual=1'b0;

reg reqBuf=1'b0;
wire compareFin;
wire [Width:0] e,et;
wire [Width-1:0] ne;

always@(posedge req or posedge compareFin) begin
if(compareFin) begin
	reqBuf<=1'b0;
	equal<=e[Width];
	notEqual<=et[Width];
end
else begin
    reqBuf<=1'b1;
	equal<=1'b0;
	notEqual<=1'b0;
end
end

assign e[0]=reqBuf;
assign et[0]=ne[0];
assign compareFin=reqBuf&(e[Width]|et[Width]);

genvar i;
generate 
	for(i=0;i<Width;i=i+1)
	begin:oneEqual 
		oneEqual oneEqual (e[i],e[i+1],ne[i],x[i],y[i]);
		assign et[i+1]=et[i]|ne[i];
	end
endgenerate

endmodule





