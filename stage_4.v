`timescale 1ns / 1ps
// ============================================================
//  PIPELINE STAGE 4 - Final Product
//  Inputs  : temp0_r, temp1_r from Stage 3
//  Compute : product = temp0 + (temp1 << 8) using RCA_32bit
//  Register: product on posedge clk
// ============================================================

module stage4_product(
    input  wire        clk,
    input  wire        reset,

    // Inputs from Stage 3
    input  wire [27:0] temp0, temp1,

    // Final output
    output reg  [31:0] product
);

    // ----------------------------------------------------------
    // Combinational : prepare inputs for RCA_32bit
    // ----------------------------------------------------------
    wire [31:0] a_rca, b_rca;
    wire [31:0] final_sum;
    wire        final_cout;

    assign a_rca = {4'b0,  temp0};           // zero extend to 32-bit
    assign b_rca = {temp1[23:0], 8'b0};      // shift left 8, take lower 32

    // Final addition using your verified RCA_32bit
    RCA_32bit rca_final (
        .a    (a_rca),
        .b    (b_rca),
        .cin  (1'b0),
        .sum  (final_sum),
        .cout (final_cout)
    );

    // ----------------------------------------------------------
    // Sequential : register product on posedge clk
    // ----------------------------------------------------------
    always @(posedge clk) begin
        if (reset)
            product <= 32'b0;
        else
            product <= final_sum;
    end

endmodule