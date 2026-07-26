//------------------------------------------------------------
// Module      : gf_arith
// Function    : Galois Field GF(2^8) Arithmetic for AES
// Description : Constant factor multiplier (x1, x2, x3)
// Inputs      : 8-bit data_in, 2-bit factor
// Outputs     : 8-bit data_out
// Latency     : 0 cycles (Combinational)
// Standard    : FIPS-197
// FPGA Target : Spartan-6 XC6SLX4
// Toolchain   : Xilinx ISE 14.7
// ------------------------------------------------------------

module gf_arith (
    input  wire [7:0] data_in,
    input  wire [1:0] factor, 
    output reg  [7:0] data_out
);

    localparam MUL1 = 2'b01;
    localparam MUL2 = 2'b10;
    localparam MUL3 = 2'b11;

    wire msb;
    assign msb = data_in[7];

    // xtime: multiplication by 2 in GF(2^8)
    wire [7:0] mul2;
    assign mul2 = {data_in[6:0], 1'b0} ^ (msb ? 8'h1b : 8'h00);

    always @(*) begin
        case (factor)
            MUL1:   data_out = data_in;
            MUL2:   data_out = mul2;
            MUL3:   data_out = mul2 ^ data_in;
            default: data_out = 8'hxx; 
        endcase
    end

endmodule