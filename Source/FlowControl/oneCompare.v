`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Mario-Hero 
//
// Create Date: 11/30/2019 04:51:46 PM
// Module Name: oneCompare
// Description: The child module of comparator.
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module oneCompare (reqParent,req,finEqual,finSmaller,finBigger,x,y);
input req,x,y,reqParent;
(* dont_touch="true" *)  output wire finEqual,finSmaller,finBigger /* synthesis keep */;

assign finBigger=reqParent&(req&x&!y);
assign finEqual=reqParent&(req&(x==y));
assign finSmaller=reqParent&(req&!x&y);

endmodule

