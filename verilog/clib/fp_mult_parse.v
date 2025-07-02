/*
    the first stage of floating point multiplier
*/

module fp_mult_parse #(
    parameter data_format = `FP32
) (
    input wire [(`GET_FP_LEN(data_format)) - 1:0]a,
    input wire [(`GET_FP_LEN(data_format)) - 1:0]b,
    output wire sign,
    output wire [(`GET_EXP_LEN(data_format)) - 1:0] a_exp,
    output wire [(`GET_EXP_LEN(data_format)) - 1:0] b_exp,
    output wire [(`GET_MANTISSA_LEN(data_format)) + 1 - 1:0] a_frac,
    output wire [(`GET_MANTISSA_LEN(data_format)) + 1 - 1:0] b_frac,
    output wire a_zero,
    output wire b_zero,
    output wire a_inf,
    output wire b_inf,
    output wire a_nan,
    output wire b_nan
);

    // localparams
    localparam sign_bit = `GET_SIGN_BIT(data_format);
    localparam mant_high = `GET_MANTISSA_HIGH(data_format);
    localparam mant_low = `GET_MANTISSA_LOW(data_format);
    localparam exp_high = `GET_EXP_HIGH(data_format);
    localparam exp_low = `GET_EXP_LOW(data_format);

    // sign bit
    assign sign = a[sign_bit] ^ b[sign_bit];

    // exponent segment
    assign a_exp = a[exp_high : exp_low];
    assign b_exp = b[exp_high : exp_low];

    // frac segment
    // TODO: deal with non-normalized format
    assign a_frac = (|a[exp_high : exp_low])? {1'b1, a[mant_high: mant_low]} : 24'b0;
    assign b_frac = (|b[exp_high : exp_low])? {1'b1, b[mant_high: mant_low]} : 24'b0;

    // special value detection
    assign a_zero = (a[exp_high : mant_low] == 0);
    assign b_zero = (b[exp_high : mant_low] == 0);
    assign a_inf = (&a[exp_high : exp_low]) && (a[mant_high: mant_low] == 0);
    assign b_inf = (&b[exp_high : exp_low]) && (b[mant_high: mant_low] == 0);

endmodule