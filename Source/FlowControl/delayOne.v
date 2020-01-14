`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/13/2020 03:53:47 PM
// Design Name: 
// Module Name: delayOne
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


module delayOne(req,fin);
input req;
(* dont_touch="true" *) output reg fin=1'b0 /*synthesis noprune*/;

always@(posedge req or posedge fin) begin
    if(fin) fin<=1'b0;
    else fin<=1'b1;
end

endmodule
