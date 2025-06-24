module mantissa_cal #(
    parameter data_format = `FP32
) (
    input wire a_sign,
    input wire b_sign,
    input wire aligned_sign, // sign after exponent alignment
    input wire [`GET_MANTISSA_LEN(data_format) + `GET_PROTECT_LEN(data_format) + 1 - 1 : 0] a_mant, // mantissa with the larger exponent
    input wire [`GET_MANTISSA_LEN(data_format) + `GET_PROTECT_LEN(data_format) + 1 - 1 : 0] b_mant,  // mantissa with the lower exponent
    output wire [`GET_MANTISSA_LEN(data_format) + `GET_PROTECT_LEN(data_format) + 2 - 1 : 0] cal_result,
    output wire cal_sign,    // result sign after mantissa calculation
    output wire effective_op // actual executed operation (add or subtract)
);

    // preserve one bit for overflow
    wire [`GET_MANTISSA_LEN(data_format) + `GET_PROTECT_LEN(data_format) + 2 - 1 : 0] preserve_a_mant;
    wire [`GET_MANTISSA_LEN(data_format) + `GET_PROTECT_LEN(data_format) + 2 - 1 : 0] preserve_b_mant;
    assign preserve_a_mant = {1'b0, a_mant};
    assign preserve_b_mant = {1'b0, b_mant};

    // whether the sign is same
    wire sign_same;
    assign sign_same = (a_sign == b_sign);

    // mantissa comparison (whether the mantissa with the larger exponent is larger than the mantissa with the smaller exponent)
    wire a_large;
    assign a_large = (a_mant >= b_mant);

    // calculate result mantissa
    assign cal_result = (sign_same)? preserve_a_mant + preserve_b_mant :
                        (a_large)? preserve_a_mant - preserve_b_mant:
                        preserve_b_mant - preserve_a_mant;
    
    // assign effective operation
    assign effective_op = (sign_same)? `ADD : `SUB;

    // assign result sign
    assign cal_sign = (sign_same)? aligned_sign :
                      (cal_result==0)? 1'b0:
                      (a_large)? aligned_sign:
                      ~aligned_sign;

endmodule