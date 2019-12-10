`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Mario-Hero
// 
// Create Date: 12/03/2019 04:22:12 PM
// Module Name: sqrt
// Description: When req rises. (square root of x) -> y. Then fin rises.
//
//              Width is the bit width of x and y.
//              This module uses Newton's iterative method to calculate the square root of x.
//              The sqrtInitialValue module give the initial value of iteration, 
//              which makes it take less cycles to give out the result.
//
//              The result y is a integer.  y^2 <= x < (y+1)^2
// 
// Dependencies: sqrtInitialValue, var2, divide, add, comparator, branch
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module sqrt #(parameter Width=32)(req,fin,x,y);
input req;
output wire fin;
input [Width-1:0] x;
output wire [Width-1:0] y;

wire [Width:0] x1In;
wire [Width-1:0] xInitial;
wire [Width-1:0] xIn,xOut,xDxOut; 
wire smaller,finish,continues;
wire xFin,xFin1,xFin2,xReq,addFin,compareFin,divideFin,req2;

assign y=xOut;

reqOr #(2) reqOrFin ({xFin1,xFin2},xFin);
sqrtInitialValue #(Width) sqrtInitialValue (req,req2,x,xInitial);
var2 #(Width,0) xVar (req2,continues,xFin1,xFin2,xInitial,x1In[Width:1],xOut);
divide #(Width,Width) divide (xFin,divideFin,x,xOut,xDxOut,);
add #(Width+1) add (divideFin,addFin,1'b0,{1'b0,xOut},{1'b0,xDxOut},x1In,);
comparator #(Width) comparator (addFin,compareFin,x1In[Width:1],xOut,,,smaller);
branch branch (compareFin,continues,fin,smaller);

endmodule
