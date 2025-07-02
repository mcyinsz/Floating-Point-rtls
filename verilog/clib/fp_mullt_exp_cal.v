/*
 stage 2.1 in floating point multiplier 
 * sum two exps, get exp value (by minus bias value, e.g. FP32 -127)

*/

module fp_mult_exp_cal #(
    parameter data_format = `FP32
) (
    input wire [(`GET_EXP_LEN(data_format)) - 1:0] a_exp,
    input wire [(`GET_EXP_LEN(data_format)) - 1:0] b_exp,
    output wire [(`GET_EXP_LEN(data_format)) + 1 - 1:0] sum_exp
);

    // localparam
    localparam exp_len = `GET_EXP_LEN(data_format);
    localparam bias = (1 << (exp_len - 1)) - 1;

    assign sum_exp = {1'b0, a_exp} + {1'b0, b_exp} - bias;

endmodule