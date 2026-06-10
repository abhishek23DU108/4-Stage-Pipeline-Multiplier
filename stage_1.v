`timescale 1ns / 1ps
// ============================================================
//  PIPELINE STAGE 1 — Partial Product Generation
//  + FULL SLICE ZERO DETECTION (all 8 slices)
//
//  What I added:
//  Detect zero for ALL 4 slices of A and ALL 4 slices of B
//  using reduction NOR operator (~|)
//  ~|A[3:0] = 1 means A[3:0] is completely zero
//
//  Previous design is UNCHANGED — only new outputs added
// ============================================================

module stage1_pp_ET_full(
    input  wire        clk,
    input  wire        reset,
    input  wire [15:0] A,
    input  wire [15:0] B,

    // ---- ORIGINAL outputs (completely unchanged) ----
    output reg  [7:0]  p0_r,  p1_r,  p2_r,  p3_r,
    output reg  [7:0]  p4_r,  p5_r,  p6_r,  p7_r,
    output reg  [7:0]  p8_r,  p9_r,  p10_r, p11_r,
    output reg  [7:0]  p12_r, p13_r, p14_r, p15_r,

    // ---- NEW outputs — zero flags for all 8 slices ----
    // A slice zero flags
    output reg         A0_zero_r,   // A[3:0]   all zero?
    output reg         A1_zero_r,   // A[7:4]   all zero?
    output reg         A2_zero_r,   // A[11:8]  all zero?
    output reg         A3_zero_r,   // A[15:12] all zero?
    // B slice zero flags
    output reg         B0_zero_r,   // B[3:0]   all zero?
    output reg         B1_zero_r,   // B[7:4]   all zero?
    output reg         B2_zero_r,   // B[11:8]  all zero?
    output reg         B3_zero_r    // B[15:12] all zero?
);

    // ----------------------------------------------------------
    // Combinational : partial products (UNCHANGED from before)
    // ----------------------------------------------------------
    wire [7:0] p0,p1,p2,p3,p4,p5,p6,p7;
    wire [7:0] p8,p9,p10,p11,p12,p13,p14,p15;

    // Row 0 : B[3:0]
    assign p0  = A[3:0]   * B[3:0];
    assign p1  = A[7:4]   * B[3:0];
    assign p2  = A[11:8]  * B[3:0];
    assign p3  = A[15:12] * B[3:0];
    // Row 1 : B[7:4]
    assign p4  = A[3:0]   * B[7:4];
    assign p5  = A[7:4]   * B[7:4];
    assign p6  = A[11:8]  * B[7:4];
    assign p7  = A[15:12] * B[7:4];
    // Row 2 : B[11:8]
    assign p8  = A[3:0]   * B[11:8];
    assign p9  = A[7:4]   * B[11:8];
    assign p10 = A[11:8]  * B[11:8];
    assign p11 = A[15:12] * B[11:8];
    // Row 3 : B[15:12]
    assign p12 = A[3:0]   * B[15:12];
    assign p13 = A[7:4]   * B[15:12];
    assign p14 = A[11:8]  * B[15:12];
    assign p15 = A[15:12] * B[15:12];

    // ----------------------------------------------------------
    // NEW : Zero detection for all 8 slices
    // Using reduction NOR — gives 1 if ALL bits in slice = 0
    // ----------------------------------------------------------
    wire A0_zero = ~|A[3:0];
    wire A1_zero = ~|A[7:4];
    wire A2_zero = ~|A[11:8];
    wire A3_zero = ~|A[15:12];

    wire B0_zero = ~|B[3:0];
    wire B1_zero = ~|B[7:4];
    wire B2_zero = ~|B[11:8];
    wire B3_zero = ~|B[15:12];

    // ----------------------------------------------------------
    // Sequential : register everything on posedge clk
    // ----------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            // Reset partial products
            p0_r<=0;  p1_r<=0;  p2_r<=0;  p3_r<=0;
            p4_r<=0;  p5_r<=0;  p6_r<=0;  p7_r<=0;
            p8_r<=0;  p9_r<=0;  p10_r<=0; p11_r<=0;
            p12_r<=0; p13_r<=0; p14_r<=0; p15_r<=0;
            // Reset zero flags
            A0_zero_r<=0; A1_zero_r<=0;
            A2_zero_r<=0; A3_zero_r<=0;
            B0_zero_r<=0; B1_zero_r<=0;
            B2_zero_r<=0; B3_zero_r<=0;
        end else begin
            // Register partial products (unchanged)
            p0_r<=p0;   p1_r<=p1;   p2_r<=p2;   p3_r<=p3;
            p4_r<=p4;   p5_r<=p5;   p6_r<=p6;   p7_r<=p7;
            p8_r<=p8;   p9_r<=p9;   p10_r<=p10; p11_r<=p11;
            p12_r<=p12; p13_r<=p13; p14_r<=p14; p15_r<=p15;
            // Register zero flags
            A0_zero_r <= A0_zero;
            A1_zero_r <= A1_zero;
            A2_zero_r <= A2_zero;
            A3_zero_r <= A3_zero;
            B0_zero_r <= B0_zero;
            B1_zero_r <= B1_zero;
            B2_zero_r <= B2_zero;
            B3_zero_r <= B3_zero;
        end
    end

endmodule
