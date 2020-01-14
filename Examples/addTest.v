`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/10/2019 01:52:30 PM
// Design Name: 
// Module Name: addTest
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


module addTest(
    input clk,
    input req_in,
    output fin,
    input [31:0] a_in,
    input [31:0] b_in,
    output wire [31:0] s1,
    output wire cout1,
    output wire [31:0] s2,
    output wire cout2
    );
    reg req=1'b0;
    reg [31:0] a=0,b=0;
    always@(posedge clk) begin
        if(req_in) begin
            req<=1'b1;
            a<=a_in;
            b<=b_in;
        end
    end
    
    assign {cout1,s1}=a+b;
    add #(32) add (req,fin,a,b,s2,cout2);
       
endmodule
