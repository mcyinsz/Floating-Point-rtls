/*
    the third stage for floating point 
        * get the final sign bit
        * do the mantissa calculation
*/

module fp_mantissa_cal #(
    parameter data_format = `FP32
) (
    input wire a_sign, // sign from the original value with the larger exponent
    input wire b_sign, // sign from the original value with the smaller exponent
    input wire [(`GET_MANTISSA_LEN(data_format)) + (`GET_PROTECT_LEN(data_format)) + 1 - 1 : 0] a_mant, // mantissa with the larger exponent
    input wire [(`GET_MANTISSA_LEN(data_format)) + (`GET_PROTECT_LEN(data_format)) + 1 - 1 : 0] b_mant,  // mantissa with the lower exponent
    output wire [(`GET_MANTISSA_LEN(data_format)) + (`GET_PROTECT_LEN(data_format)) + 2 - 1 : 0] cal_result,
    output wire cal_sign,    // result sign after mantissa calculation
    output wire effective_op // actual executed operation (add or subtract)
);

    // localparams
    localparam mant_len = `GET_MANTISSA_LEN(data_format);
    localparam protect_len = `GET_PROTECT_LEN(data_format);

    // preserve one bit for overflow
    wire [mant_len + protect_len + 2 - 1 : 0] preserve_a_mant;
    wire [mant_len + protect_len + 2 - 1 : 0] preserve_b_mant;
    assign preserve_a_mant = {1'b0, a_mant};
    assign preserve_b_mant = {1'b0, b_mant};

    // whether the sign is same
    wire sign_same;
    assign sign_same = (a_sign == b_sign);

    // for a_mant is always larger than b_mant, do not require extra compare operatio
    
    // calculate mantissa bits
    assign cal_result = sign_same ? preserve_a_mant + preserve_b_mant 
                                 : preserve_a_mant - preserve_b_mant;
    
    assign effective_op = sign_same ? `ADD : `SUB;

    // result sign
    assign cal_sign = (sign_same) ? a_sign : 
                     ((cal_result == 0) && (~sign_same)) ? 1'b0 : a_sign;

endmodule