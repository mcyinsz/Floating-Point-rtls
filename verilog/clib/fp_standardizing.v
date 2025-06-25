/*
    the fourth stage for floating point adder
        * deal with two situations: 
            * the actual operation is add, and carry bit is 1: then require exp + 1 and choose the higher bit of mantissa
            * the actual operation is subtract, and there is at least 1 leading zero: require left shift the mantissa and subtract exponent value
*/

module fp_standardizing #(
    parameter data_format = `FP32
) (
    input wire [(`GET_EXP_LEN(data_format)) - 1 : 0] exp, // exponent segment after stage 1,2,3
    input wire [(`GET_MANTISSA_LEN(data_format)) + (`GET_PROTECT_LEN(data_format)) + 2 - 1 : 0] cal_result, // calculated mantissa result
    input wire effective_op,        // can be `ADD or `SUB
    output wire [(`GET_MANTISSA_LEN(data_format)) + (`GET_PROTECT_LEN(data_format)) + 1 - 1:0] mant,
    output wire [(`GET_EXP_LEN(data_format)) - 1 : 0] standardizing_exp
);

    // local parameters
    localparam aligned_mantissa_length = (`GET_MANTISSA_LEN(data_format)) + (`GET_PROTECT_LEN(data_format)) + 1;
    localparam aligned_mantissa_with_carry_length = aligned_mantissa_length + 1;

    // calculate how many zeros is on the high bit
    // leading zeros
    function [$clog2(aligned_mantissa_length) - 1:0] lzc;
        input [aligned_mantissa_length - 1:0] mant;
        integer i;
        begin
            lzc = 0;
            for (i = aligned_mantissa_length - 1; i >= 0; i = i - 1) begin
                if (mant[i]) begin
                    lzc = aligned_mantissa_length - 1 - i;
                    break;
                end
            end
        end
    endfunction

    // carry bit at stage 3
    wire add_carry;
    assign add_carry = cal_result[aligned_mantissa_with_carry_length - 1];

    // subtract result with leading zeros
    wire sub_lz;
    assign sub_lz = (effective_op==`SUB) && cal_result[aligned_mantissa_with_carry_length - 2];

    // leading zeros and left-shift bits
    wire [$clog2(`GET_MANTISSA_LEN(data_format) + `GET_PROTECT_LEN(data_format)) - 1:0] leading_zeros_count; // leading zeros count
    assign leading_zeros_count = (add_carry)? 0:
                 (sub_lz)? lzc(cal_result[aligned_mantissa_with_carry_length - 2:0]):
                 0;

    // constraint left-shift bits
    wire [$clog2(aligned_mantissa_length) - 1:0] shift_amt;
    assign shift_amt = (leading_zeros_count > exp)? exp[$clog2(aligned_mantissa_length+1)-1:0] : leading_zeros_count;
    
    // exponent change (+1: for carry bit in add operation; -shift_amt: for leading zero shifting)
    assign standardizing_exp = (add_carry)? exp + 1:
                                (sub_lz)? exp - shift_amt:
                                exp;

    // mantissa change
    assign mant = (add_carry)? cal_result[aligned_mantissa_with_carry_length - 1: 1] :
                    (sub_lz)? cal_result[aligned_mantissa_with_carry_length - 2: 0] << shift_amt:
                    cal_result[aligned_mantissa_with_carry_length - 2: 0];

endmodule