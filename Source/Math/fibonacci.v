`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Mario-Hero
// 
// Create Date: 12/02/2019 10:06:19 PM 
// Module Name: fibonacci
// Description: When req rises, fibonacci(N) -> result. Then fin rises.
//              Width is the bit width of N and result.
//              N must >= 3. fibonacci sequence starts numbering from 0.
//
// Dependencies: var, reqAndSimple, once, add, equalOrNot
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module fibonacci #(parameter Width=32) (req,fin,N,result);
input req;
input [Width-1:0] N;
output wire fin;
output wire [Width-1:0] result;

wire [Width-1:0] i,a,b,cCal,iCal,c;
reg [Width-1:0] none=0;
wire onceFin,ABCFin,iFin,equalFin;
wire saveFin,saveRst;
wire cout1,cout2;
wire branchFalse,branchTrue;
wire saveFinA,saveFinB,saveFinC,saveFinI;
wire rstFinA,rstFinB,rstFinC,rstFinI;
wire onceRstReq,onceRstFin;
wire resultRstFin,addFin;
assign onceRstReq=fin;

var #(Width,1) resultSaver (branchTrue,fin,1'b0,resultRstFin,c,result);
var #(Width,1) A (addFin,saveFinA,fin,rstFinA,b,a);
var #(Width,1) B (addFin,saveFinB,fin,rstFinB,cCal,b);
var #(Width,0) C (addFin,saveFinC,fin,rstFinC,cCal,c);
var #(Width,2) I (addFin,saveFinI,fin,rstFinI,iCal,i);

reqAnd #(4) IABCFin ({saveFinA,saveFinB,saveFinC,saveFinI},saveFin);
reqAnd #(2) ABCI ({ABCFin,iFin},addFin);

once                 oncef   (req,branchFalse,onceFin,onceRstReq,onceRstFin);
add        #(Width)  addABC  (onceFin,ABCFin,1'b0,a,b,cCal,cout1);
add        #(Width)  addi    (onceFin,iFin,1'b1,i,none,iCal,cout2);
equalOrNot #(Width)  equalOr (addFin,branchTrue,branchFalse,i,N);

endmodule