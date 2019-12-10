`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Mario-Hero 
//
// Create Date: 11/30/2019 04:51:46 PM
// Module Name: oneEqual
// Description: The child module of equalOrNot.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module oneEqual (req,equal,notEqual,x,y);
input req,x,y;
output wire equal,notEqual;

assign equal=req&(x==y);
assign notEqual=req&(x!=y);

endmodule

