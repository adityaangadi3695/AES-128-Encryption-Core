//------------------------------------------------------------
// Module      : register_ce
// Function    : Generic Parameterized Register with Clock Enable
// Description : Reusable register for state, key, or general
//               datapath pipeline storage.
// ------------------------------------------------------------

`include "aes_params.v"

module register_ce #(
    parameter WIDTH = 8
)(
    input  wire             clk,
    input  wire             reset_n,
    input  wire             enable,
    input  wire             load,
    input  wire [WIDTH-1:0] load_data,
    input  wire [WIDTH-1:0] next_state,
    output reg  [WIDTH-1:0] state_out
);

    always @(posedge clk) begin
        if (!reset_n) begin
            state_out <= {WIDTH{1'b0}};
        end else if (enable) begin
            state_out <= load ? load_data : next_state;
        end
    end

endmodule