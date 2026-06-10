`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.04.2026 01:58:39
// Design Name: 
// Module Name: Full_Adder
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


module Full_Adder(input a_fa, b_fa,cin_fa, output reg sum_fa, carry_fa);
always@(*)
begin
sum_fa = a_fa ^ b_fa ^ cin_fa;
carry_fa = (a_fa & b_fa) | (b_fa & cin_fa) | (cin_fa & a_fa);
end
endmodule
