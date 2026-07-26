//------------------------------------------------------------
// Module      : shift_rows
// Function    : AES ShiftRows Transformation
// Description : Cyclically shifts the last three rows of the
//               AES state by 1, 2, and 3 bytes respectively.
// Inputs      : 128-bit AES State
// Outputs     : 128-bit Permuted State
// Latency     : 0 cycles (Combinational)
// Throughput  : 1 block/cycle
// Standard    : FIPS-197
// FPGA Target : Spartan-6 XC6SLX4
// Toolchain   : Xilinx ISE 14.7
// ------------------------------------------------------------

module shift_rows (
    input  wire [127:0] data_in,
    output wire [127:0] data_out
);

    // Explicit per-byte assignments aligned to FIPS-197 Big-Endian.
    // Byte 0 = [127:120], Byte 15 = [7:0]
    
    // Column 0
    assign data_out[127:120] = data_in[127:120]; // O0  <- I0  (R0C0)
    assign data_out[119:112] = data_in[87:80];   // O1  <- I5  (R1C0 <- R1C1)
    assign data_out[111:104] = data_in[47:40];   // O2  <- I10 (R2C0 <- R2C2)
    assign data_out[103:96]  = data_in[7:0];     // O3  <- I15 (R3C0 <- R3C3)

    // Column 1
    assign data_out[95:88]   = data_in[95:88];   // O4  <- I4  (R0C1)
    assign data_out[87:80]   = data_in[55:48];   // O5  <- I9  (R1C1 <- R1C2)
    assign data_out[79:72]   = data_in[15:8];    // O6  <- I14 (R2C1 <- R2C3)
    assign data_out[71:64]   = data_in[103:96];  // O7  <- I3  (R3C1 <- R3C0)

    // Column 2
    assign data_out[63:56]   = data_in[63:56];   // O8  <- I8  (R0C2)
    assign data_out[55:48]   = data_in[23:16];   // O9  <- I13 (R1C2 <- R1C3)
    assign data_out[47:40]   = data_in[111:104]; // O10 <- I2  (R2C2 <- R2C0)
    assign data_out[39:32]   = data_in[71:64];   // O11 <- I7  (R3C2 <- R3C1)

    // Column 3
    assign data_out[31:24]   = data_in[31:24];   // O12 <- I12 (R0C3)
    assign data_out[23:16]   = data_in[119:112]; // O13 <- I1  (R1C3 <- R1C0)
    assign data_out[15:8]    = data_in[79:72];   // O14 <- I6  (R2C3 <- R2C1)
    assign data_out[7:0]     = data_in[39:32];   // O15 <- I11 (R3C3 <- R3C2)

endmodule