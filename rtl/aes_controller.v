//------------------------------------------------------------
// Module      : aes_controller
// Function    : AES-128 Iterative Controller (FSM)
// ------------------------------------------------------------

`include "aes_params.v"

module aes_controller (
    input  wire                            clk,
    input  wire                            reset_n,
    input  wire                            start,
    input  wire [`AES_CNT_WIDTH-1:0]       round_num,
    output reg                             busy,
    output reg                             done,
    output reg                             state_load,
    output reg                             state_enable,
    output reg                             key_load,
    output reg                             key_enable,
    output reg                             counter_enable,
    output reg                             counter_clear,
    output reg                             final_round
);

    localparam [2:0] S_IDLE  = 3'd0;
    localparam [2:0] S_LOAD  = 3'd1;
    localparam [2:0] S_RUN   = 3'd2;
    localparam [2:0] S_FINAL = 3'd3;
    localparam [2:0] S_DONE  = 3'd4;

    reg [2:0] current_state, next_state;

    // 3-Stage Synchronizer to safely resolve metastability 
    // before performing edge-detection.
    reg start_sync_1;
    reg start_sync_2;
    reg start_sync_3;
    wire start_pulse;

    always @(posedge clk) begin
        if (!reset_n) begin
            start_sync_1 <= 1'b0;
            start_sync_2 <= 1'b0;
            start_sync_3 <= 1'b0;
        end else begin
            start_sync_1 <= start;
            start_sync_2 <= start_sync_1;
            start_sync_3 <= start_sync_2;
        end
    end

    // Edge detect on the fully stabilized signal
    assign start_pulse = start_sync_2 & ~start_sync_3;

    always @(posedge clk) begin
        if (!reset_n) begin
            current_state <= S_IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always @(*) begin
        case (current_state)
            S_IDLE: begin
                if (start_pulse) next_state = S_LOAD;
                else             next_state = S_IDLE;
            end
            S_LOAD: begin
                next_state = S_RUN;
            end
            S_RUN: begin
                if (round_num == 4'd9) next_state = S_FINAL;
                else                   next_state = S_RUN;
            end
            S_FINAL: begin
                next_state = S_DONE;
            end
            S_DONE: begin
                next_state = S_IDLE;
            end
            default: next_state = S_IDLE;
        endcase
    end

    always @(*) begin
        // Default assignments to prevent latch inference
        busy           = 1'b0;
        done           = 1'b0;
        state_load     = 1'b0;
        state_enable   = 1'b0;
        key_load       = 1'b0;
        key_enable     = 1'b0;
        counter_enable = 1'b0;
        counter_clear  = 1'b0;
        final_round    = 1'b0;

        case (current_state)
            S_IDLE: begin
                counter_clear  = 1'b1;
            end
            S_LOAD: begin
                busy           = 1'b1;
                state_load     = 1'b1;
                state_enable   = 1'b1;
                key_load       = 1'b1;
                key_enable     = 1'b1;
                counter_enable = 1'b1;
            end
            S_RUN: begin
                busy           = 1'b1;
                state_enable   = 1'b1;
                key_enable     = 1'b1;
                counter_enable = 1'b1;
            end
            S_FINAL: begin
                busy           = 1'b1;
                state_enable   = 1'b1;
                final_round    = 1'b1;
            end
            S_DONE: begin
                done           = 1'b1;
            end
            default: begin
                // hold defaults
            end
        endcase
    end

endmodule