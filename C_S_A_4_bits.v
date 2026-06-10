`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11.04.2026 13:43:22
// Design Name: 
// Module Name: C_S_A_4_bits
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


module C_S_A_4_bits(input [3:0]A,B,C, output  [4:0]Sc, output  Coutc

    );
    
    wire  [7:1]w;
    Full_Adder fa5(A[0], B[0], C[0], Sc[0],w[1]);
    Full_Adder fa6(A[1], B[1], C[1] ,w[2],w[3]);
    Full_Adder fa7(A[2], B[2], C[2], w[4],w[5]);
    Full_Adder fa8(A[3], B[3], C[3], w[6],w[7]);
    Ripple_carry_adder_4bit rca({w[1],w[2],w[3],w[4],w[5],w[6],w[7],1'b0},1'b0 , Sc[1],Sc[2],Sc[3], Sc[4]);
    assign Coutc = Sc[4];
    
endmodule
