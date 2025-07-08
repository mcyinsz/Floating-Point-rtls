/*
    multiplier module for uint data format
*/

module uint_mult #(
    parameter data_width = 32
) (
    input wire [data_width - 1:0] a,
    input wire [data_width - 1:0] b,
    output wire [2 * data_width - 1:0] prod
);

    assign prod = a * b;

endmodule