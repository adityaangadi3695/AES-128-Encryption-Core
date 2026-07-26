//------------------------------------------------------------
// Module      : sub_bytes
// Function    : AES SubBytes Transformation
// Description : 16 parallel S-Boxes
// Inputs      : 128-bit AES State
// Outputs     : 128-bit Substituted State
// Latency     : 0 cycles (Combinational)
// Throughput  : 1 block/cycle
// Standard    : FIPS-197
// FPGA Target : Spartan-6 XC6SLX4
// Toolchain   : Xilinx ISE 14.7
// ------------------------------------------------------------

module sub_bytes (
    input  wire [127:0] data_in,
    output wire [127:0] data_out
);

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : GEN_SBOX
            sbox u_sbox (
                .data_in (data_in[i*8 +: 8]),
                .data_out(data_out[i*8 +: 8])
            );
        end
    endgenerate

endmodule