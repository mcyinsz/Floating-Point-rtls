/* 
     floating point round stage module (stage 5)
*/

module fp_mult_round #(
    parameter data_format = `FP32
) (
    // GRS bits
    input wire guard,
    input wire round,
    input wire sticky,
    // special bits
    input wire nan,
    input wire inf,
    input wire zero,
    // exponent segment
    input wire sign,
    input wire [(`GET_EXP_LEN(data_format)) + 1 - 1:0] exp, // exp with protect highest carry bit
    input wire [(`GET_MANTISSA_LEN(data_format)) - 1:0] frac, // frac after standardizing and befor round
    // result
    output wire [(`GET_FP_LEN(data_format)) - 1:0] result
);

    // local params
    localparam exp_len = `GET_EXP_LEN(data_format);
    localparam mant_len = `GET_MANTISSA_LEN(data_format);
    
    localparam full_one_exp = {exp_len{1'b1}};
    localparam extend_full_one_exp = {1'b0, full_one_exp};
    localparam full_zero_exp = {exp_len{1'b0}};
    localparam full_zero_mant = {mant_len{1'b0}};
    localparam leading_one_mant = {1'b1, {(mant_len-1){1'b0}}};

    // special sign
    wire special;
    assign special = nan || inf || zero;

    // round up sign
    wire round_up;
    assign round_up = (guard & (round | sticky)) | 
                      (guard & ~(round | sticky) & frac[0]); // >0.1 round up, < 0.1 do not round up, 1.1000... round up

    // handle round 
    wire exp_round_up;
    assign exp_round_up = ({1'b0, frac} + 1) >> mant_len;

    wire [mant_len - 1:0] round_mant;
    assign round_mant = (round_up)? (exp_round_up? full_zero_mant : frac + 1):
                                    frac;

    wire [exp_len + 1 - 1:0] round_exp;
    assign round_exp = (round_up && exp_round_up)? exp + 1 : exp;

    // overflow
    wire overflow;
    assign overflow = (round_exp >= extend_full_one_exp);

    // underflow
    // TODO: handle non-normal fp values
    wire underflow;
    assign underflow = (round_exp == 0);

    // result
    assign result = (special)? (
                        nan? {sign, full_one_exp, leading_one_mant}:
                        inf? {sign, full_one_exp, full_zero_mant}:
                        zero? {sign, full_zero_exp, full_zero_mant}:
                        {sign, full_one_exp, leading_one_mant}): 
                    (overflow)? {sign, full_one_exp, full_zero_mant}:
                    (underflow)? {sign, full_zero_exp, round_mant}:
                    {sign, round_exp[exp_len - 1:0], round_mant};

endmodule