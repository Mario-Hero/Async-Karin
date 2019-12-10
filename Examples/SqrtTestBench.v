`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Mario-Hero
// 
// Create Date: 12/07/2019 08:34:09 PM
// Module Name: SqrtTestBench
// Top Level: sqrt
// Description: 
// 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module SqrtTestBench();
reg req=1'b0;
wire fin;
reg [31:0] in=32'd10454520;  // change the input number as you like
wire [31:0] out;   

initial begin
#200 req=1'b1;
end

sqrt #(32) sqrt (req,fin,in,out);

endmodule
