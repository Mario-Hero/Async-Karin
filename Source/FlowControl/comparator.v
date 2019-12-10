`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Mario-Hero 
//
// Create Date: 11/30/2019 04:51:46 PM
// Module Name: comparator
// Description: When the req rises, this module compares x and y, 
//				output the result to bigger, equal and smaller. Then it raises fin.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module comparator #(parameter Width=32) (req,fin,x,y,bigger,equal,smaller);
input req;
input [Width-1:0] x,y;
(* dont_touch="true" *) output reg fin=1'b1,bigger=1'b0,equal=1'b0,smaller=1'b0 /* synthesis keep */;
reg reqBuf=1'b0 /* synthesis keep */ ;
wire compareFin /* synthesis keep */ ;
wire [Width:0] e,st,bt;
wire [Width-1:0] s,b;
wire rst;

//reqRst reqRst (req,rst,req2);
//assign rst=!(e[Width]|bt[Width]|st[Width]);

always@(posedge req or posedge compareFin) begin
if(compareFin) begin
	fin<=1'b1;
	reqBuf<=1'b0;
	bigger<=bt[Width];
	smaller<=st[Width];
	equal<=e[Width];
end
else begin
	fin<=1'b0;
	reqBuf<=1'b1;
	bigger<=1'b0;
	smaller<=1'b0;
	equal<=1'b0;
end
end

assign e[0]=reqBuf;
assign st[0]=s[0];
assign bt[0]=b[0]; 
assign compareFin=reqBuf&(e[Width]|bt[Width]|st[Width]);

genvar i;
generate 
	for(i=0;i<Width;i=i+1)
	begin:oneCompare
		oneCompare oneCompare (reqBuf,e[i],e[i+1],s[i],b[i],x[Width-i-1],y[Width-i-1]);
		assign st[i+1]=s[i]|st[i];
		assign bt[i+1]=b[i]|bt[i];
	end
endgenerate

endmodule





