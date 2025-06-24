module mantissa_align #(
    parameter data_format = `FP32
) (
    
    input wire [`GET_FP_LEN(data_format) - 1 : 0] a,
    input wire [`GET_FP_LEN(data_format) - 1 : 0] b,
    output wire sign,                                                                              // aligned sign
    output wire [`GET_EXP_LEN(data_format) - 1:0] exp,                                             // shared exponent
    output wire [`GET_MANTISSA_LEN(data_format) + `GET_PROTECT_LEN(data_format) + 1 - 1:0] mant_a, // larger mantissa
    output wire [`GET_MANTISSA_LEN(data_format) + `GET_PROTECT_LEN(data_format) + 1 - 1:0] mant_b // smaller mantissa

);
    // local params
    localparam exp_high = `GET_EXP_HIGH(data_format);
    localparam exp_low = `GET_EXP_LOW(data_format);
    localparam mantissa_high = `GET_MANTISSA_HIGH(data_format);
    localparam mantissa_low = `GET_MANTISSA_LOW(data_format);
    localparam mantissa_len = `GET_MANTISSA_LEN(data_format);
    localparam exp_len = `GET_EXP_LEN(data_format);
    localparam protect_len = `GET_PROTECT_LEN(data_format);

    // sign bit
    wire a_sign;
    wire b_sign;
    assign a_sign = a[`GET_SIGN_BIT(data_format)];
    assign b_sign = b[`GET_SIGN_BIT(data_format)];

    // exp bits
    wire [exp_len - 1:0] a_exp;
    wire [exp_len - 1:0] b_exp;
    assign a_exp = a[exp_high: exp_low];
    assign b_exp = b[exp_high: exp_low];

    // original mantissa bits
    wire [mantissa_len - 1:0] a_frac;
    wire [mantissa_len - 1:0] b_frac;
    assign a_frac = a[mantissa_high: mantissa_low];
    assign b_frac = b[mantissa_high: mantissa_low];

    // get the larger number
    wire a_large;
    assign a_large = (a_exp > b_exp) || (a_exp == b_exp && a_frac > b_frac);
    assign exp = (a_large) ? a_exp : b_exp;
    assign sign = (a_large) ? a_sign : b_sign;

    // extend mantissa value (prefix 1'b1 and protect bits)
    wire [mantissa_len + protect_len + 1 - 1:0] a_mant;
    wire [mantissa_len + protect_len + 1 - 1:0] b_mant;
    assign a_mant = (a_exp != 0) ? {1'b1, a_frac, {protect_len{1'b0}}} : {1'b0, a_frac, {protect_len{1'b0}}};
    assign b_mant = (b_exp != 0) ? {1'b1, b_frac, {protect_len{1'b0}}} : {1'b0, b_frac, {protect_len{1'b0}}};

    // calculate exponent difference
    wire [exp_len - 1:0] exp_diff_original;
    wire [exp_len - 1:0] exp_diff;
    assign exp_diff_original = (a_exp > b_exp) ? (a_exp - b_exp) : (b_exp - a_exp);
    assign exp_diff = (exp_diff_original > mantissa_len + protect_len) ? mantissa_len + protect_len : exp_diff_original;

    // align mantissa bits
    assign mant_a = (a_large) ? a_mant : b_mant;
    assign mant_b = (a_large) ? (b_mant >> exp_diff) : (a_mant >> exp_diff);

endmodule