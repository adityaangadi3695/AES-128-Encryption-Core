//------------------------------------------------------------
// Module      : mix_columns
// Function    : AES MixColumns Transformation
// Description : Matrix multiplication in GF(2^8) for all 4 columns.
// Inputs      : 128-bit AES State
// Outputs     : 128-bit Mixed State
// Latency     : 0 cycles (Combinational)
// Throughput  : 1 block/cycle
// Standard    : FIPS-197
// FPGA Target : Spartan-6 XC6SLX4
// Toolchain   : Xilinx ISE 14.7
// ------------------------------------------------------------

module mix_columns (
    input  wire [127:0] data_in,
    output wire [127:0] data_out
);

    // ---------------------------------------------------------
    // Column 0
    // ---------------------------------------------------------
    wire [7:0] c0_s0; assign c0_s0 = data_in[127:120];
    wire [7:0] c0_s1; assign c0_s1 = data_in[119:112];
    wire [7:0] c0_s2; assign c0_s2 = data_in[111:104];
    wire [7:0] c0_s3; assign c0_s3 = data_in[103:96];

    wire [7:0] c0_m2_s0, c0_m3_s0, c0_m2_s1, c0_m3_s1, c0_m2_s2, c0_m3_s2, c0_m2_s3, c0_m3_s3;

    gf_arith u_c0_m2_s0 (.data_in(c0_s0), .factor(2'b10), .data_out(c0_m2_s0));
    gf_arith u_c0_m3_s0 (.data_in(c0_s0), .factor(2'b11), .data_out(c0_m3_s0));
    gf_arith u_c0_m2_s1 (.data_in(c0_s1), .factor(2'b10), .data_out(c0_m2_s1));
    gf_arith u_c0_m3_s1 (.data_in(c0_s1), .factor(2'b11), .data_out(c0_m3_s1));
    gf_arith u_c0_m2_s2 (.data_in(c0_s2), .factor(2'b10), .data_out(c0_m2_s2));
    gf_arith u_c0_m3_s2 (.data_in(c0_s2), .factor(2'b11), .data_out(c0_m3_s2));
    gf_arith u_c0_m2_s3 (.data_in(c0_s3), .factor(2'b10), .data_out(c0_m2_s3));
    gf_arith u_c0_m3_s3 (.data_in(c0_s3), .factor(2'b11), .data_out(c0_m3_s3));

    assign data_out[127:120] = c0_m2_s0 ^ c0_m3_s1 ^ c0_s2 ^ c0_s3;
    assign data_out[119:112] = c0_s0 ^ c0_m2_s1 ^ c0_m3_s2 ^ c0_s3;
    assign data_out[111:104] = c0_s0 ^ c0_s1 ^ c0_m2_s2 ^ c0_m3_s3;
    assign data_out[103:96]  = c0_m3_s0 ^ c0_s1 ^ c0_s2 ^ c0_m2_s3;

    // ---------------------------------------------------------
    // Column 1
    // ---------------------------------------------------------
    wire [7:0] c1_s0; assign c1_s0 = data_in[95:88];
    wire [7:0] c1_s1; assign c1_s1 = data_in[87:80];
    wire [7:0] c1_s2; assign c1_s2 = data_in[79:72];
    wire [7:0] c1_s3; assign c1_s3 = data_in[71:64];

    wire [7:0] c1_m2_s0, c1_m3_s0, c1_m2_s1, c1_m3_s1, c1_m2_s2, c1_m3_s2, c1_m2_s3, c1_m3_s3;

    gf_arith u_c1_m2_s0 (.data_in(c1_s0), .factor(2'b10), .data_out(c1_m2_s0));
    gf_arith u_c1_m3_s0 (.data_in(c1_s0), .factor(2'b11), .data_out(c1_m3_s0));
    gf_arith u_c1_m2_s1 (.data_in(c1_s1), .factor(2'b10), .data_out(c1_m2_s1));
    gf_arith u_c1_m3_s1 (.data_in(c1_s1), .factor(2'b11), .data_out(c1_m3_s1));
    gf_arith u_c1_m2_s2 (.data_in(c1_s2), .factor(2'b10), .data_out(c1_m2_s2));
    gf_arith u_c1_m3_s2 (.data_in(c1_s2), .factor(2'b11), .data_out(c1_m3_s2));
    gf_arith u_c1_m2_s3 (.data_in(c1_s3), .factor(2'b10), .data_out(c1_m2_s3));
    gf_arith u_c1_m3_s3 (.data_in(c1_s3), .factor(2'b11), .data_out(c1_m3_s3));

    assign data_out[95:88]   = c1_m2_s0 ^ c1_m3_s1 ^ c1_s2 ^ c1_s3;
    assign data_out[87:80]   = c1_s0 ^ c1_m2_s1 ^ c1_m3_s2 ^ c1_s3;
    assign data_out[79:72]   = c1_s0 ^ c1_s1 ^ c1_m2_s2 ^ c1_m3_s3;
    assign data_out[71:64]   = c1_m3_s0 ^ c1_s1 ^ c1_s2 ^ c1_m2_s3;

    // ---------------------------------------------------------
    // Column 2
    // ---------------------------------------------------------
    wire [7:0] c2_s0; assign c2_s0 = data_in[63:56];
    wire [7:0] c2_s1; assign c2_s1 = data_in[55:48];
    wire [7:0] c2_s2; assign c2_s2 = data_in[47:40];
    wire [7:0] c2_s3; assign c2_s3 = data_in[39:32];

    wire [7:0] c2_m2_s0, c2_m3_s0, c2_m2_s1, c2_m3_s1, c2_m2_s2, c2_m3_s2, c2_m2_s3, c2_m3_s3;

    gf_arith u_c2_m2_s0 (.data_in(c2_s0), .factor(2'b10), .data_out(c2_m2_s0));
    gf_arith u_c2_m3_s0 (.data_in(c2_s0), .factor(2'b11), .data_out(c2_m3_s0));
    gf_arith u_c2_m2_s1 (.data_in(c2_s1), .factor(2'b10), .data_out(c2_m2_s1));
    gf_arith u_c2_m3_s1 (.data_in(c2_s1), .factor(2'b11), .data_out(c2_m3_s1));
    gf_arith u_c2_m2_s2 (.data_in(c2_s2), .factor(2'b10), .data_out(c2_m2_s2));
    gf_arith u_c2_m3_s2 (.data_in(c2_s2), .factor(2'b11), .data_out(c2_m3_s2));
    gf_arith u_c2_m2_s3 (.data_in(c2_s3), .factor(2'b10), .data_out(c2_m2_s3));
    gf_arith u_c2_m3_s3 (.data_in(c2_s3), .factor(2'b11), .data_out(c2_m3_s3));

    assign data_out[63:56]   = c2_m2_s0 ^ c2_m3_s1 ^ c2_s2 ^ c2_s3;
    assign data_out[55:48]   = c2_s0 ^ c2_m2_s1 ^ c2_m3_s2 ^ c2_s3;
    assign data_out[47:40]   = c2_s0 ^ c2_s1 ^ c2_m2_s2 ^ c2_m3_s3;
    assign data_out[39:32]   = c2_m3_s0 ^ c2_s1 ^ c2_s2 ^ c2_m2_s3;

    // ---------------------------------------------------------
    // Column 3
    // ---------------------------------------------------------
    wire [7:0] c3_s0; assign c3_s0 = data_in[31:24];
    wire [7:0] c3_s1; assign c3_s1 = data_in[23:16];
    wire [7:0] c3_s2; assign c3_s2 = data_in[15:8];
    wire [7:0] c3_s3; assign c3_s3 = data_in[7:0];

    wire [7:0] c3_m2_s0, c3_m3_s0, c3_m2_s1, c3_m3_s1, c3_m2_s2, c3_m3_s2, c3_m2_s3, c3_m3_s3;

    gf_arith u_c3_m2_s0 (.data_in(c3_s0), .factor(2'b10), .data_out(c3_m2_s0));
    gf_arith u_c3_m3_s0 (.data_in(c3_s0), .factor(2'b11), .data_out(c3_m3_s0));
    gf_arith u_c3_m2_s1 (.data_in(c3_s1), .factor(2'b10), .data_out(c3_m2_s1));
    gf_arith u_c3_m3_s1 (.data_in(c3_s1), .factor(2'b11), .data_out(c3_m3_s1));
    gf_arith u_c3_m2_s2 (.data_in(c3_s2), .factor(2'b10), .data_out(c3_m2_s2));
    gf_arith u_c3_m3_s2 (.data_in(c3_s2), .factor(2'b11), .data_out(c3_m3_s2));
    gf_arith u_c3_m2_s3 (.data_in(c3_s3), .factor(2'b10), .data_out(c3_m2_s3));
    gf_arith u_c3_m3_s3 (.data_in(c3_s3), .factor(2'b11), .data_out(c3_m3_s3));

    assign data_out[31:24]   = c3_m2_s0 ^ c3_m3_s1 ^ c3_s2 ^ c3_s3;
    assign data_out[23:16]   = c3_s0 ^ c3_m2_s1 ^ c3_m3_s2 ^ c3_s3;
    assign data_out[15:8]    = c3_s0 ^ c3_s1 ^ c3_m2_s2 ^ c3_m3_s3;
    assign data_out[7:0]     = c3_m3_s0 ^ c3_s1 ^ c3_s2 ^ c3_m2_s3;

endmodule