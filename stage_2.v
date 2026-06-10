`timescale 1ns / 1ps
// ============================================================
//  PIPELINE STAGE 2 — Row Sum with FULL Zero Detection
//
//  What I added:
//  Each partial product is individually checked:
//  pp(i,j) = 0 if A_slice_i = 0 OR B_slice_j = 0
//
//  16 individual PP zero flags computed
//  Each PP masked before adding to row sum
//
//  Previous row sum formula is UNCHANGED
//  Only masked PPs are used instead of raw PPs
// ============================================================

module stage2_rowsum_ET_full(
    input  wire        clk,
    input  wire        reset,

    // ---- ORIGINAL inputs (unchanged) ----
    input  wire [7:0]  p0,  p1,  p2,  p3,
    input  wire [7:0]  p4,  p5,  p6,  p7,
    input  wire [7:0]  p8,  p9,  p10, p11,
    input  wire [7:0]  p12, p13, p14, p15,

    // ---- NEW inputs — all 8 zero flags from Stage 1 ----
    input  wire        A0_zero, A1_zero, A2_zero, A3_zero,
    input  wire        B0_zero, B1_zero, B2_zero, B3_zero,

    // ---- ORIGINAL outputs (unchanged) ----
    output reg  [19:0] sum0_r, sum1_r, sum2_r, sum3_r,

    // ---- NEW outputs — pass B flags to Stage 3 ----
    output reg         B0_zero_r, B1_zero_r,
    output reg         B2_zero_r, B3_zero_r,

    // ---- NEW outputs — PP zero flags (for display) ----
    output reg  [15:0] pp_zero_flags_r  // bit i = pp[i] was zero
);

    // ----------------------------------------------------------
    // Compute individual PP zero flags
    // pp(i,j) = 0 if A_slice_i=0 OR B_slice_j=0
    // ----------------------------------------------------------
    wire pp0_zero  = A0_zero | B0_zero;
    wire pp1_zero  = A1_zero | B0_zero;
    wire pp2_zero  = A2_zero | B0_zero;
    wire pp3_zero  = A3_zero | B0_zero;
    wire pp4_zero  = A0_zero | B1_zero;
    wire pp5_zero  = A1_zero | B1_zero;
    wire pp6_zero  = A2_zero | B1_zero;
    wire pp7_zero  = A3_zero | B1_zero;
    wire pp8_zero  = A0_zero | B2_zero;
    wire pp9_zero  = A1_zero | B2_zero;
    wire pp10_zero = A2_zero | B2_zero;
    wire pp11_zero = A3_zero | B2_zero;
    wire pp12_zero = A0_zero | B3_zero;
    wire pp13_zero = A1_zero | B3_zero;
    wire pp14_zero = A2_zero | B3_zero;
    wire pp15_zero = A3_zero | B3_zero;

    // ----------------------------------------------------------
    // Mask each PP individually
    // If zero flag = 1 → replace with 0
    // If zero flag = 0 → use actual PP value
    // ----------------------------------------------------------
    wire [7:0] p0_m  = pp0_zero  ? 8'b0 : p0;
    wire [7:0] p1_m  = pp1_zero  ? 8'b0 : p1;
    wire [7:0] p2_m  = pp2_zero  ? 8'b0 : p2;
    wire [7:0] p3_m  = pp3_zero  ? 8'b0 : p3;
    wire [7:0] p4_m  = pp4_zero  ? 8'b0 : p4;
    wire [7:0] p5_m  = pp5_zero  ? 8'b0 : p5;
    wire [7:0] p6_m  = pp6_zero  ? 8'b0 : p6;
    wire [7:0] p7_m  = pp7_zero  ? 8'b0 : p7;
    wire [7:0] p8_m  = pp8_zero  ? 8'b0 : p8;
    wire [7:0] p9_m  = pp9_zero  ? 8'b0 : p9;
    wire [7:0] p10_m = pp10_zero ? 8'b0 : p10;
    wire [7:0] p11_m = pp11_zero ? 8'b0 : p11;
    wire [7:0] p12_m = pp12_zero ? 8'b0 : p12;
    wire [7:0] p13_m = pp13_zero ? 8'b0 : p13;
    wire [7:0] p14_m = pp14_zero ? 8'b0 : p14;
    wire [7:0] p15_m = pp15_zero ? 8'b0 : p15;

    // ----------------------------------------------------------
    // Row sum computation (SAME formula as before)
    // using masked partial products
    // ----------------------------------------------------------
    wire [19:0] sum0, sum1, sum2, sum3;

    assign sum0 = {12'b0,p0_m}  + ({12'b0,p1_m}  << 4)
                                + ({12'b0,p2_m}  << 8)
                                + ({12'b0,p3_m}  << 12);

    assign sum1 = {12'b0,p4_m}  + ({12'b0,p5_m}  << 4)
                                + ({12'b0,p6_m}  << 8)
                                + ({12'b0,p7_m}  << 12);

    assign sum2 = {12'b0,p8_m}  + ({12'b0,p9_m}  << 4)
                                + ({12'b0,p10_m} << 8)
                                + ({12'b0,p11_m} << 12);

    assign sum3 = {12'b0,p12_m} + ({12'b0,p13_m} << 4)
                                + ({12'b0,p14_m} << 8)
                                + ({12'b0,p15_m} << 12);

    // ----------------------------------------------------------
    // PP zero flags bundle for display in testbench
    // ----------------------------------------------------------
    wire [15:0] pp_zero_flags = {
        pp15_zero, pp14_zero, pp13_zero, pp12_zero,
        pp11_zero, pp10_zero, pp9_zero,  pp8_zero,
        pp7_zero,  pp6_zero,  pp5_zero,  pp4_zero,
        pp3_zero,  pp2_zero,  pp1_zero,  pp0_zero
    };

    // ----------------------------------------------------------
    // Sequential : register on posedge clk
    // ----------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            sum0_r <= 0; sum1_r <= 0;
            sum2_r <= 0; sum3_r <= 0;
            B0_zero_r <= 0; B1_zero_r <= 0;
            B2_zero_r <= 0; B3_zero_r <= 0;
            pp_zero_flags_r <= 0;
        end else begin
            sum0_r <= sum0;
            sum1_r <= sum1;
            sum2_r <= sum2;
            sum3_r <= sum3;
            // Pass B flags to Stage 3
            B0_zero_r <= B0_zero;
            B1_zero_r <= B1_zero;
            B2_zero_r <= B2_zero;
            B3_zero_r <= B3_zero;
            // Register PP zero flags for display
            pp_zero_flags_r <= pp_zero_flags;
        end
    end

endmodule
