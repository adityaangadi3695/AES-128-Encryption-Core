//------------------------------------------------------------
// Module      : add_round_key
// Function    : AES AddRoundKey Transformation
// Description : Bitwise XOR of the 128-bit state and round key.
// Inputs      : 128-bit AES State, 128-bit Round Key
// Outputs     : 128-bit Result State
// Latency     : 0 cycles (Combinational)
// Throughput  : 1 block/cycle
// Standard    : FIPS-197
// FPGA Target : Spartan-6 XC6SLX4
// Toolchain   : Xilinx ISE 14.7
// ------------------------------------------------------------

module add_round_key (
    input  wire [127:0] data_in,
    input  wire [127:0] round_key,
    output wire [127:0] data_out
);

    assign data_out = data_in ^ round_key;

endmodule