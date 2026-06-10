`timescale 1ns / 1ps
// ============================================================
//  TOP MODULE — 4-Stage Pipeline Multiplier
//  with FULL Slice-Level Zero Detection
//
//  Stage 4 is completely unchanged
//  All new signals are internal wires only
//  External interface is identical to original design
// ============================================================

module Pipeline_Multiplier_ET_full(
    input  wire        clk,
    input  wire        reset,
    input  wire [15:0] A,
    input  wire [15:0] B,
    output wire [31:0] product,

    // NEW — expose internal signals for testbench display
    output wire        A0_zero_r, A1_zero_r,
    output wire        A2_zero_r, A3_zero_r,
    output wire        B0_zero_r, B1_zero_r,
    output wire        B2_zero_r, B3_zero_r,
    output wire [15:0] pp_zero_flags_r,
    output wire        sum0_skipped_r, sum1_skipped_r,
    output wire        sum2_skipped_r, sum3_skipped_r
);

    // ----------------------------------------------------------
    // Stage 1 → Stage 2 wires (partial products — unchanged)
    // ----------------------------------------------------------
    wire [7:0]  p0_r,  p1_r,  p2_r,  p3_r;
    wire [7:0]  p4_r,  p5_r,  p6_r,  p7_r;
    wire [7:0]  p8_r,  p9_r,  p10_r, p11_r;
    wire [7:0]  p12_r, p13_r, p14_r, p15_r;

    // NEW — A zero flags Stage 1 → Stage 2
    wire        A0_zr, A1_zr, A2_zr, A3_zr;
    // NEW — B zero flags Stage 1 → Stage 2
    wire        B0_zr, B1_zr, B2_zr, B3_zr;

    // Expose to testbench
    assign A0_zero_r = A0_zr; assign A1_zero_r = A1_zr;
    assign A2_zero_r = A2_zr; assign A3_zero_r = A3_zr;
    assign B0_zero_r = B0_zr; assign B1_zero_r = B1_zr;
    assign B2_zero_r = B2_zr; assign B3_zero_r = B3_zr;

    // ----------------------------------------------------------
    // Stage 2 → Stage 3 wires
    // ----------------------------------------------------------
    wire [19:0] sum0_r, sum1_r, sum2_r, sum3_r;
    wire        B0_z_s2, B1_z_s2, B2_z_s2, B3_z_s2;

    // ----------------------------------------------------------
    // Stage 3 → Stage 4 wires
    // ----------------------------------------------------------
    wire [27:0] temp0_r, temp1_r;

    // ----------------------------------------------------------
    // STAGE 1
    // ----------------------------------------------------------
    stage1_pp_ET_full s1(
        .clk(clk), .reset(reset), .A(A), .B(B),
        .p0_r(p0_r),   .p1_r(p1_r),   .p2_r(p2_r),   .p3_r(p3_r),
        .p4_r(p4_r),   .p5_r(p5_r),   .p6_r(p6_r),   .p7_r(p7_r),
        .p8_r(p8_r),   .p9_r(p9_r),   .p10_r(p10_r), .p11_r(p11_r),
        .p12_r(p12_r), .p13_r(p13_r), .p14_r(p14_r), .p15_r(p15_r),
        .A0_zero_r(A0_zr), .A1_zero_r(A1_zr),
        .A2_zero_r(A2_zr), .A3_zero_r(A3_zr),
        .B0_zero_r(B0_zr), .B1_zero_r(B1_zr),
        .B2_zero_r(B2_zr), .B3_zero_r(B3_zr)
    );

    // ----------------------------------------------------------
    // STAGE 2
    // ----------------------------------------------------------
    stage2_rowsum_ET_full s2(
        .clk(clk), .reset(reset),
        .p0(p0_r),   .p1(p1_r),   .p2(p2_r),   .p3(p3_r),
        .p4(p4_r),   .p5(p5_r),   .p6(p6_r),   .p7(p7_r),
        .p8(p8_r),   .p9(p9_r),   .p10(p10_r), .p11(p11_r),
        .p12(p12_r), .p13(p13_r), .p14(p14_r), .p15(p15_r),
        .A0_zero(A0_zr), .A1_zero(A1_zr),
        .A2_zero(A2_zr), .A3_zero(A3_zr),
        .B0_zero(B0_zr), .B1_zero(B1_zr),
        .B2_zero(B2_zr), .B3_zero(B3_zr),
        .sum0_r(sum0_r), .sum1_r(sum1_r),
        .sum2_r(sum2_r), .sum3_r(sum3_r),
        .B0_zero_r(B0_z_s2), .B1_zero_r(B1_z_s2),
        .B2_zero_r(B2_z_s2), .B3_zero_r(B3_z_s2),
        .pp_zero_flags_r(pp_zero_flags_r)
    );

    // ----------------------------------------------------------
    // STAGE 3
    // ----------------------------------------------------------
    stage3_temp_ET_full s3(
        .clk(clk), .reset(reset),
        .sum0(sum0_r), .sum1(sum1_r),
        .sum2(sum2_r), .sum3(sum3_r),
        .B0_zero(B0_z_s2), .B1_zero(B1_z_s2),
        .B2_zero(B2_z_s2), .B3_zero(B3_z_s2),
        .temp0_r(temp0_r), .temp1_r(temp1_r),
        .sum0_skipped_r(sum0_skipped_r),
        .sum1_skipped_r(sum1_skipped_r),
        .sum2_skipped_r(sum2_skipped_r),
        .sum3_skipped_r(sum3_skipped_r)
    );

    // ----------------------------------------------------------
    // STAGE 4 — completely unchanged
    // ----------------------------------------------------------
    stage4_product s4(
        .clk(clk), .reset(reset),
        .temp0(temp0_r), .temp1(temp1_r),
        .product(product)
    );

endmodule
