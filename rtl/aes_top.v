//------------------------------------------------------------
// Module      : aes_top
// Function    : AES-128 Iterative Encryption Engine
// ------------------------------------------------------------

`include "aes_params.v"

module aes_top (
    input  wire                          clk,
    input  wire                          reset_n,
    input  wire                          start,
    input  wire [`AES_BLOCK_WIDTH-1:0]   plaintext,
    input  wire [`AES_KEY_WIDTH-1:0]     key,
    output wire [`AES_BLOCK_WIDTH-1:0]   ciphertext,
    output wire                          ciphertext_valid,
    output wire                          busy
);

    wire [`AES_CNT_WIDTH-1:0] round_num;
    wire                      state_load;
    wire                      state_enable;
    wire                      key_load;
    wire                      key_enable;
    wire                      counter_enable;
    wire                      counter_clear;
    wire                      final_round;
    wire                      done;

    wire [`AES_STATE_WIDTH-1:0] state_reg_out;
    wire [`AES_STATE_WIDTH-1:0] sb_out;
    wire [`AES_STATE_WIDTH-1:0] sr_out;
    wire [`AES_STATE_WIDTH-1:0] mc_out;
    wire [`AES_STATE_WIDTH-1:0] datapath_out;
    wire [`AES_STATE_WIDTH-1:0] ark_out;
    
    wire [`AES_KEY_WIDTH-1:0]   key_reg;
    wire [`AES_KEY_WIDTH-1:0]   next_key;

    aes_controller u_controller (
        .clk            (clk),
        .reset_n        (reset_n),
        .start          (start),
        .round_num      (round_num),
        .busy           (busy),
        .done           (done),
        .state_load     (state_load),
        .state_enable   (state_enable),
        .key_load       (key_load),
        .key_enable     (key_enable),
        .counter_enable (counter_enable),
        .counter_clear  (counter_clear),
        .final_round    (final_round)
    );

    round_counter u_round_counter (
        .clk        (clk),
        .reset_n    (reset_n),
        .clear      (counter_clear),
        .enable     (counter_enable),
        .round_num  (round_num)
    );

    sub_bytes u_sub_bytes (
        .data_in    (state_reg_out),
        .data_out   (sb_out)
    );

    shift_rows u_shift_rows (
        .data_in    (sb_out),
        .data_out   (sr_out)
    );

    mix_columns u_mix_columns (
        .data_in    (sr_out),
        .data_out   (mc_out)
    );

    assign datapath_out = final_round ? sr_out : mc_out;

    // FIX: Datapath must tap next_key to XOR with the current round's key
    add_round_key u_add_round_key (
        .data_in    (datapath_out),
        .round_key  (next_key),
        .data_out   (ark_out)
    );

    register_ce #(.WIDTH(`AES_STATE_WIDTH)) u_state_register (
        .clk         (clk),
        .reset_n     (reset_n),
        .enable      (state_enable),
        .load        (state_load),
        .load_data   (plaintext ^ key), 
        .next_state  (ark_out),
        .state_out   (state_reg_out)
    );

    register_ce #(.WIDTH(`AES_KEY_WIDTH)) u_key_register (
        .clk         (clk),
        .reset_n     (reset_n),
        .enable      (key_enable),
        .load        (key_load),
        .load_data   (key),
        .next_state  (next_key),
        .state_out   (key_reg)
    );

    key_expansion u_key_expansion (
        .current_key (key_reg),
        .round_num   (round_num),
        .next_key    (next_key)
    );

    assign ciphertext       = state_reg_out;
    assign ciphertext_valid = done;

endmodule