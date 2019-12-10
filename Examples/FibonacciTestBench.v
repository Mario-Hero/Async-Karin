`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Mario-Hero
// 
// Create Date: 11/27/2019 08:34:09 PM
// Module Name: FibonacciTestBench
// Top Level: fibonacci
// Description: 
// 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module FibonacciTestBench();
reg req=1'b0;
wire fin;
wire [15:0] result;
reg [15:0] N=16'd10;  // fibonacci[]={1,1,2,3,5,8...}, starts numbering from 0

initial begin
#400 req=1'b1;
end

fibonacci #(16) fibonacci (req,fin,N,result);

endmodule
