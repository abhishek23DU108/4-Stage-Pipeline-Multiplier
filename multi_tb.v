`timescale 1ns / 1ps
// ============================================================
//  TESTBENCH — Full Slice Zero Detection Pipeline
//
//  Shows EXACTLY what is happening at every stage:
//  1. Which slices of A and B are zero
//  2. Which partial products are skipped
//  3. Which row sums are skipped
//  4. Final product verification
// ============================================================

module Pipeline_ET_full_tb;

    reg         clk, reset;
    reg  [15:0] A, B;
    wire [31:0] product;

    // Zero detection signals
    wire        A0_zero_r, A1_zero_r, A2_zero_r, A3_zero_r;
    wire        B0_zero_r, B1_zero_r, B2_zero_r, B3_zero_r;
    wire [15:0] pp_zero_flags_r;
    wire        sum0_skipped_r, sum1_skipped_r;
    wire        sum2_skipped_r, sum3_skipped_r;

    // DUT
    Pipeline_Multiplier_ET_full dut(
        .clk(clk), .reset(reset), .A(A), .B(B),
        .product(product),
        .A0_zero_r(A0_zero_r), .A1_zero_r(A1_zero_r),
        .A2_zero_r(A2_zero_r), .A3_zero_r(A3_zero_r),
        .B0_zero_r(B0_zero_r), .B1_zero_r(B1_zero_r),
        .B2_zero_r(B2_zero_r), .B3_zero_r(B3_zero_r),
        .pp_zero_flags_r(pp_zero_flags_r),
        .sum0_skipped_r(sum0_skipped_r),
        .sum1_skipped_r(sum1_skipped_r),
        .sum2_skipped_r(sum2_skipped_r),
        .sum3_skipped_r(sum3_skipped_r)
    );

    // Clock
    initial clk = 0;
    always #5 clk = ~clk;

    integer pass_count = 0;
    integer fail_count = 0;
    integer pp_skipped_count;

    task apply_and_check;
        input [15:0] a_in, b_in;
        reg   [31:0] expected;
        integer j;
        begin
            @(negedge clk);
            A = a_in; B = b_in;

            // Wait 4 pipeline cycles
            @(posedge clk); #1;
            @(posedge clk); #1;
            @(posedge clk); #1;
            @(posedge clk); #1;

            expected = a_in * b_in;

            // Count skipped PPs
            pp_skipped_count = 0;
            for(j = 0; j < 16; j = j + 1)
                if(pp_zero_flags_r[j]) pp_skipped_count = pp_skipped_count + 1;

            $display("==========================================");
            $display("A = %5d (0x%04h) | B = %5d (0x%04h)",
                      a_in, a_in, b_in, b_in);

            // Show A slice analysis
            $display("  -- A Slice Analysis --");
            $display("  A[3:0]  =%4d  zero=%0b  %s",
                      a_in[3:0],   A0_zero_r,
                      A0_zero_r ? "SKIP pp0,pp4,pp8,pp12"  : "compute");
            $display("  A[7:4]  =%4d  zero=%0b  %s",
                      a_in[7:4],   A1_zero_r,
                      A1_zero_r ? "SKIP pp1,pp5,pp9,pp13"  : "compute");
            $display("  A[11:8] =%4d  zero=%0b  %s",
                      a_in[11:8],  A2_zero_r,
                      A2_zero_r ? "SKIP pp2,pp6,pp10,pp14" : "compute");
            $display("  A[15:12]=%4d  zero=%0b  %s",
                      a_in[15:12], A3_zero_r,
                      A3_zero_r ? "SKIP pp3,pp7,pp11,pp15" : "compute");

            // Show B slice analysis
            $display("  -- B Slice Analysis --");
            $display("  B[3:0]  =%4d  zero=%0b  %s",
                      b_in[3:0],   B0_zero_r,
                      B0_zero_r ? "SKIP pp0,pp1,pp2,pp3  + sum0" : "compute");
            $display("  B[7:4]  =%4d  zero=%0b  %s",
                      b_in[7:4],   B1_zero_r,
                      B1_zero_r ? "SKIP pp4,pp5,pp6,pp7  + sum1" : "compute");
            $display("  B[11:8] =%4d  zero=%0b  %s",
                      b_in[11:8],  B2_zero_r,
                      B2_zero_r ? "SKIP pp8,pp9,pp10,pp11 + sum2" : "compute");
            $display("  B[15:12]=%4d  zero=%0b  %s",
                      b_in[15:12], B3_zero_r,
                      B3_zero_r ? "SKIP pp12,pp13,pp14,pp15+sum3" : "compute");

            // Show PP zero flags
            $display("  -- Partial Product Status --");
            $display("  pp_zero_flags = %016b", pp_zero_flags_r);
            $display("  PPs skipped   = %0d out of 16", pp_skipped_count);
            $display("  PPs computed  = %0d out of 16", 16 - pp_skipped_count);

            // Show row sum status
            $display("  -- Row Sum Status (Stage 3) --");
            $display("  sum0 skipped = %0b  (B[3:0]  zero)",  sum0_skipped_r);
            $display("  sum1 skipped = %0b  (B[7:4]  zero)",  sum1_skipped_r);
            $display("  sum2 skipped = %0b  (B[11:8] zero)",  sum2_skipped_r);
            $display("  sum3 skipped = %0b  (B[15:12] zero)", sum3_skipped_r);

            // Show final result
            $display("  -- Final Result --");
            $display("  Product  = %0d", product);
            $display("  Expected = %0d", expected);

            if(product === expected) begin
                pass_count = pass_count + 1;
                $display("  RESULT   : PASS" );
            end else begin
                fail_count = fail_count + 1;
                $display("  RESULT   : FAIL ");
            end
        end
    endtask

    integer k;
    reg [15:0] ra, rb;

    initial begin
        $dumpfile("pipeline_ET_full.vcd");
        $dumpvars(0, Pipeline_ET_full_tb);
        $dumpvars(0, Pipeline_ET_full_tb.dut);

        reset = 1; A = 0; B = 0;
        repeat(4) @(posedge clk);
        reset = 0;
        @(posedge clk);

        $display("==========================================");
        $display("  FULL ZERO DETECTION PIPELINE TESTBENCH");
        $display("==========================================");

        // Case 1: No zeros at all
        $display("\n--- Case 1: No zeros (all 16 PPs computed) ---");
        apply_and_check(16'hFFFF, 16'hFFFF);

        // Case 2: Both upper halves zero
        $display("\n--- Case 2: Both upper halves zero ---");
        apply_and_check(16'h00FF, 16'h00FF);

        // Case 3: Alternating slices zero
        $display("\n--- Case 3: Alternating zero slices ---");
        apply_and_check(16'h0F0F, 16'hF0F0);

        // Case 4: A completely zero
        $display("\n--- Case 4: A = 0 (all PPs zero) ---");
        apply_and_check(16'h0000, 16'hFFFF);

        // Case 5: Only one slice of A zero
        $display("\n--- Case 5: Only A[15:12] zero ---");
        apply_and_check(16'h0FFF, 16'hFFFF);

        // Case 6: Only one slice of B zero
        $display("\n--- Case 6: Only B[3:0] zero ---");
        apply_and_check(16'hFFFF, 16'hFFF0);

        // Case 7: Manual verification
        $display("\n--- Case 7: Manual verification A=27122 B=38606 ---");
        apply_and_check(16'd27122, 16'd38606);

        // Case 8: Random vectors
        $display("\n--- Case 8: Random Tests (50) ---");
        for(k = 0; k < 50; k = k + 1) begin
            ra = $random;
            rb = $random;
            apply_and_check(ra, rb);
        end

        repeat(5) @(posedge clk);
        $display("\n==========================================");
        $display("            RESULTS SUMMARY");
        $display("==========================================");
        $display("PASS : %0d", pass_count);
        $display("FAIL : %0d", fail_count);
        if(fail_count == 0)
            $display("ALL TESTS PASSED!");
        else
            $display("%0d FAILURES DETECTED!", fail_count);
        $display("==========================================");
        $finish;
    end

endmodule
