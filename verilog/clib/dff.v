//==============================================================================
// d flip-flop
//==============================================================================

module dff #(
    parameter width = 32,
    parameter offset = 0,
    parameter [offset + width - 1 : offset] reset_value = {width{1'b0}}
) (
    input clk,
    input reset,
    input active,
    input [offset + width - 1 : offset] d,
    output reg [offset + width - 1 : offset] q
);

generate
    always @(posedge clk, posedge reset) begin
        if (reset)
            q <= reset_value;
        else if (active)
            q <= d;
    end
endgenerate

endmodule