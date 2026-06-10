`timescale 1ns / 1ps
// ============================================================
//  RCA 8-bit : chains two Ripple_carry_adder_4bit
// ============================================================
module RCA_8bit(
    input  [7:0] a,
    input  [7:0] b,
    input        cin,
    output [7:0] sum,
    output       cout
);
    wire carry_mid;

    Ripple_carry_adder_4bit rca_lo (
        .a_rca   (a[3:0]),
        .b_rca   (b[3:0]),
        .cin     (cin),
        .sum_rca (sum[3:0]),
        .cout    (carry_mid)
    );

    Ripple_carry_adder_4bit rca_hi (
        .a_rca   (a[7:4]),
        .b_rca   (b[7:4]),
        .cin     (carry_mid),
        .sum_rca (sum[7:4]),
        .cout    (cout)
    );
endmodule


// ============================================================
//  RCA 16-bit : chains two RCA_8bit
// ============================================================
module RCA_16bit(
    input  [15:0] a,
    input  [15:0] b,
    input         cin,
    output [15:0] sum,
    output        cout
);
    wire carry_mid;

    RCA_8bit rca_lo (
        .a    (a[7:0]),
        .b    (b[7:0]),
        .cin  (cin),
        .sum  (sum[7:0]),
        .cout (carry_mid)
    );

    RCA_8bit rca_hi (
        .a    (a[15:8]),
        .b    (b[15:8]),
        .cin  (carry_mid),
        .sum  (sum[15:8]),
        .cout (cout)
    );
endmodule


// ============================================================
//  RCA 32-bit : chains two RCA_16bit
//  Used for final addition in the multiplier
// ============================================================
module RCA_32bit(
    input  [31:0] a,
    input  [31:0] b,
    input         cin,
    output [31:0] sum,
    output        cout
);
    wire carry_mid;

    RCA_16bit rca_lo (
        .a    (a[15:0]),
        .b    (b[15:0]),
        .cin  (cin),
        .sum  (sum[15:0]),
        .cout (carry_mid)
    );

    RCA_16bit rca_hi (
        .a    (a[31:16]),
        .b    (b[31:16]),
        .cin  (carry_mid),
        .sum  (sum[31:16]),
        .cout (cout)
    );
endmodule