`define ANGLE 1'b0
`define HYPERBOLICAL 1'b1

module int_vector_rotate #(
    parameter int_width = 24,
    
    parameter iter = 2,
    parameter mode = `HYPERBOLICAL
) (
    input wire signed [int_width - 1:0] x,
    input wire signed [int_width - 1:0] y,
    input wire signed [int_width - 1:0] z,
    input wire signed [int_width - 1:0] theta,
    output wire signed [int_width - 1:0] result_x,
    output wire signed [int_width - 1:0] result_y,
    output wire signed [int_width - 1:0] result_z
);

    // determine rotate orientation (z > 0)
    wire d;
    assign d = (z > 0);

    // sign logic
    wire x_sign, y_sign;
    // Hyperbolic mode: d=1 -> add, d=0 -> minus
    // Angle mode:     d=1 -> minus, d=0 -> add
    assign x_sign = (mode == `HYPERBOLICAL) ? ~d : d;
    assign y_sign = ~d; // y_sign === ~d

    // arithmetic right-shift (>>>) to keep 
    wire signed [int_width - 1:0] y_shifted = y >>> iter;
    wire signed [int_width - 1:0] x_shifted = x >>> iter;

    // fix y_size -> y_sign
    assign result_x = x_sign ? x - y_shifted : x + y_shifted;
    assign result_y = y_sign ? y - x_shifted : y + x_shifted;
    assign result_z = d ? z - theta : z + theta;

endmodule