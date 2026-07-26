//------------------------------------------------------------
// Module      : key_expansion
// Function    : AES-128 Key Expansion (Combinational)
// ------------------------------------------------------------

`include "aes_params.v"

module key_expansion (
    input  wire [`AES_KEY_WIDTH-1:0]   current_key,
    input  wire [`AES_CNT_WIDTH-1:0]   round_num,
    output wire [`AES_KEY_WIDTH-1:0]   next_key
);

    wire [31:0] w0;
    wire [31:0] w1;
    wire [31:0] w2;
    wire [31:0] w3;

    assign w0 = current_key[127:96];
    assign w1 = current_key[95:64];
    assign w2 = current_key[63:32];
    assign w3 = current_key[31:0];

    wire [31:0] rot_word;
    assign rot_word = {w3[23:16], w3[15:8], w3[7:0], w3[31:24]};

    wire [7:0] sub_b0;
    wire [7:0] sub_b1;
    wire [7:0] sub_b2;
    wire [7:0] sub_b3;

    sbox u_sub_b0 (.data_in(rot_word[31:24]), .data_out(sub_b0));
    sbox u_sub_b1 (.data_in(rot_word[23:16]), .data_out(sub_b1));
    sbox u_sub_b2 (.data_in(rot_word[15:8]),  .data_out(sub_b2));
    sbox u_sub_b3 (.data_in(rot_word[7:0]),   .data_out(sub_b3));

    wire [31:0] sub_word;
    assign sub_word = {sub_b0, sub_b1, sub_b2, sub_b3};

    localparam [7:0] RCON_1  = 8'h01;
    localparam [7:0] RCON_2  = 8'h02;
    localparam [7:0] RCON_3  = 8'h04;
    localparam [7:0] RCON_4  = 8'h08;
    localparam [7:0] RCON_5  = 8'h10;
    localparam [7:0] RCON_6  = 8'h20;
    localparam [7:0] RCON_7  = 8'h40;
    localparam [7:0] RCON_8  = 8'h80;
    localparam [7:0] RCON_9  = 8'h1b;
    localparam [7:0] RCON_10 = 8'h36;

    reg [7:0] rcon;
    always @(*) begin
        // FIX: Realigned case indices. 
        // When round_num=1, we compute K1, requiring RCON_1.
        case (round_num)
            4'd1:  rcon = RCON_1;
            4'd2:  rcon = RCON_2;
            4'd3:  rcon = RCON_3;
            4'd4:  rcon = RCON_4;
            4'd5:  rcon = RCON_5;
            4'd6:  rcon = RCON_6;
            4'd7:  rcon = RCON_7;
            4'd8:  rcon = RCON_8;
            4'd9:  rcon = RCON_9;
            4'd10: rcon = RCON_10;
            default: rcon = 8'h00;
        endcase
    end

    wire [31:0] w0_prime;
    wire [31:0] w1_prime;
    wire [31:0] w2_prime;
    wire [31:0] w3_prime;

    assign w0_prime = w0 ^ sub_word ^ {rcon, 24'h0};
    assign w1_prime = w1 ^ w0_prime;
    assign w2_prime = w2 ^ w1_prime;
    assign w3_prime = w3 ^ w2_prime;

    assign next_key = {w0_prime, w1_prime, w2_prime, w3_prime};

endmodule