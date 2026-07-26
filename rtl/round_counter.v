//------------------------------------------------------------
// Module      : round_counter
// Function    : AES Round Counter
// Description : Synchronous 4-bit up counter tracking AES rounds.
//               Holds at 10 when finished. Supports clear.
// ------------------------------------------------------------

module round_counter (
    input  wire       clk,
    input  wire       reset_n,
    input  wire       clear,   // NEW: Clears counter to 0 for new block
    input  wire       enable,
    output reg  [3:0] round_num,
    output wire       done
);

    localparam [3:0] ROUND_INIT = 4'd0;
    localparam [3:0] MAX_ROUND  = 4'd10;

    assign done = (round_num == MAX_ROUND);

    always @(posedge clk) begin
        if (!reset_n || clear) begin
            round_num <= ROUND_INIT;
        end else if (enable) begin
            if (round_num < MAX_ROUND) begin
                round_num <= round_num + 4'd1;
            end else begin
                round_num <= MAX_ROUND;
            end
        end
    end

endmodule