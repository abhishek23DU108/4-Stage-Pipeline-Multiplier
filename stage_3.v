`timescale 1ns / 1ps
// ============================================================
//  PIPELINE STAGE 3 — Intermediate Temps with Full ET
//
//  What I added:
//  Use B zero flags to mask row sums before accumulation
//  If B_slice_j = 0 → entire row sum for that column = 0
//
//  Row sum zero conditions:
//  sum0 zero if B0_zero=1 (all of B[3:0] zero)
//  sum1 zero if B1_zero=1 (all of B[7:4] zero)
//  sum2 zero if B2_zero=1 (all of B[11:8] zero)
//  sum3 zero if B3_zero=1 (all of B[15:12] zero)
//
//  Previous temp formula is UNCHANGED
// ============================================================

module stage3_temp_ET_full(
    input  wire        clk,
    input  wire        reset,

    // ---- ORIGINAL inputs (unchanged) ----
    input  wire [19:0] sum0, sum1, sum2, sum3,

    // ---- NEW inputs — B zero flags from Stage 2 ----
    input  wire        B0_zero, B1_zero,
    input  wire        B2_zero, B3_zero,

    // ---- ORIGINAL outputs (unchanged) ----
    output reg  [27:0] temp0_r, temp1_r,

    // ---- NEW outputs — which sums were skipped ----
    output reg         sum0_skipped_r,
    output reg         sum1_skipped_r,
    output reg         sum2_skipped_r,
    output reg         sum3_skipped_r
);

    // ----------------------------------------------------------
    // Mask row sums based on B zero flags
    // If entire B slice is zero → entire row sum = 0
    // ----------------------------------------------------------
    wire [19:0] sum0_m = B0_zero ? 20'b0 : sum0;
    wire [19:0] sum1_m = B1_zero ? 20'b0 : sum1;
    wire [19:0] sum2_m = B2_zero ? 20'b0 : sum2;
    wire [19:0] sum3_m = B3_zero ? 20'b0 : sum3;

    // ----------------------------------------------------------
    // Temp computation (SAME formula as before)
    // using masked row sums
    // ----------------------------------------------------------
    wire [27:0] temp0, temp1;

    assign temp0 = {8'b0, sum0_m} + ({8'b0, sum1_m} << 4);
    assign temp1 = {8'b0, sum2_m} + ({8'b0, sum3_m} << 4);

    // ----------------------------------------------------------
    // Sequential : register on posedge clk
    // ----------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            temp0_r <= 0;
            temp1_r <= 0;
            sum0_skipped_r <= 0;
            sum1_skipped_r <= 0;
            sum2_skipped_r <= 0;
            sum3_skipped_r <= 0;
        end else begin
            temp0_r <= temp0;
            temp1_r <= temp1;
            // Record which sums were skipped
            sum0_skipped_r <= B0_zero;
            sum1_skipped_r <= B1_zero;
            sum2_skipped_r <= B2_zero;
            sum3_skipped_r <= B3_zero;
        end
    end

endmodule
