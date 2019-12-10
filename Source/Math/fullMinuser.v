`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Mario-Hero
//
// Create Date: 12/02/2019 09:14:25 PM
// Module Name: fullMinuser
// Description: The child module of minus.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module fullMinuser (reqParent,req,fin,cin,x,y,s,cout);
input req,reqParent,cin,x,y;
output wire s,cout;
(* dont_touch="true" *) output wire fin;

assign s=(x&(cin==y))|((!x)&(cin!=y));
assign cout=(cin&y)|((!x)&(cin|y));
assign fin=reqParent&(req|(x&!y));  // To start next full minuser quickly

endmodule

