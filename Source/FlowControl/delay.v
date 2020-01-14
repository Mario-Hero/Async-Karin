`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/13/2020 01:32:24 PM
// Design Name: 
// Module Name: delay
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


module delay #(parameter N=10) (req,fin);
input req;
output wire fin;

(* dont_touch="true" *) wire [N-1:0] c /*synthesis noprune*/;
reg rec=1'b0;

always@(posedge req or posedge fin) begin
	if(fin) rec<=1'b0;
	else rec<=1'b1;
end


assign c[0]=rec;
assign fin = c[N-1];
genvar i;
generate 
	for(i=1;i<N;i=i+1)
	begin:delays
		assign c[i]=rec&(c[i-1]);
	end
endgenerate

endmodule