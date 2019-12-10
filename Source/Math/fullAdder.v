`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Mario-Hero
// 
// Create Date: 12/02/2019 09:13:54 PM
// Module Name: fullAdder
// Description: The child module of add.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module fullAdder (reqParent,req,fin,cin,x,y,s,cout);
input req,reqParent,cin,x,y;
output wire s,cout;
(* dont_touch="true" *) output wire fin;

assign s=(x^y^cin);
assign cout=((x&y)|(x&cin)|(y&cin));
assign fin=reqParent&(req|(!x&!y));  // To start next full adder quickly

endmodule

