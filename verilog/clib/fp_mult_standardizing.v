/*
    floating point multiplier standardizing stage (stage 4)
*/

module fp_mult_standardizing #(
    parameter data_format = `FP32
) (
    input wire [2 * (`GET_FP_LEN(data_format) + 1) - 1:0] prod,
    input wire [(`GET_EXP_LEN(data_format)) + 1 - 1:0] exp,
    // standardized exponent
    output wire [(`GET_EXP_LEN(data_format)) + 1 - 1:0] stand_exp,
    // standardized mantissa
    output wire [(`GET_MANTISSA_LEN(data_format)) - 1:0] stand_frac,
    // standardized GRS bits for round
    output wire guard,
    output wire round,
    output wire sticky
);

    // local parameters
    localparam exp_len = `GET_EXP_LEN(data_format);
    localparam mant_len = `GET_MANTISSA_LEN(data_format);

    // product stage would generate 2 * (mantissa + 1) bits
    // 1.xxx * 1.xxx -> 1.xxx or 11.xxx, the extra highest 1 bit would be in 2 * (mantissa + 1) - 1 position
    // if the extra highest 1 bit exists, the exponent segment would require +1
    wire highest;
    assign highest = prod[2 * (mant_len + 1) - 1];

    // handle exponent
    assign stand_exp = highest? exp + 1 : exp;

    // handle fraction
    assign stand_frac = highest? prod[2 * (mant_len + 1) - 2 -: mant_len]:
                                 prod[2 * (mant_len + 1) - 3 -: mant_len];

    // handle GRS
    assign guard = highest? prod[mant_len]:
                            prod[mant_len - 1];

    assign round = highest? prod[mant_len - 1]:
                            prod[mant_len - 2];

    assign sticky = highest? |prod[mant_len - 2:0]:
                             |prod[mant_len - 3:0];

endmodule