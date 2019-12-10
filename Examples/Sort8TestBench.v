`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Author: Mario-Hero
// 
// Create Date: 11/30/2019 03:57:11 PM
// Module Name: Sort8TestBench
// Top Level: sort8
// Description: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Sort8TestBench();
reg req=1'b0;
wire fin;
reg [31:0] inputNumber[0:7];
wire [255:0] inputNumberLine;
wire [255:0] outputNumberLine;
wire [31:0] outputNumber[0:7];

initial begin
#10;
inputNumber[0] = $random;
inputNumber[1] = $random;
inputNumber[2] = $random;
inputNumber[3] = $random;
inputNumber[4] = $random;
inputNumber[5] = $random;
inputNumber[6] = $random;
inputNumber[7] = $random;
end

genvar i;
generate 
for(i=0;i<8;i=i+1)
begin
   assign inputNumberLine[32*i+31:i*32]=inputNumber[7-i];
   assign outputNumber[7-i]=outputNumberLine[32*i+31:i*32];
end
endgenerate 

initial begin
#400 req=1'b1;
end

sort8 #(32) sort8 (req,fin,inputNumberLine,outputNumberLine);

endmodule
