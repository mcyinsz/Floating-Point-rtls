module fp_convert_int #(
    parameter data_format = `FP32,
    parameter result_interger_len = 1,     // result integer part length
    parameter result_mantissa_len = `GET_MANTISSA_LEN(data_format)  // result mantissa len
) (
    input wire clock,
    input wire reset,
    input wire [(`GET_FP_LEN(data_format))-1:0] a,
    output wire [(result_interger_len + result_mantissa_len + 1) - 1:0] result // result format: binary fixed-point two's complement
);

    // floating point parameters
    localparam sign_bit = `GET_SIGN_BIT(data_format);
    localparam exp_len = `GET_EXP_LEN(data_format);
    localparam exp_high = `GET_EXP_HIGH(data_format);
    localparam exp_low = `GET_EXP_LOW(data_format);
    localparam mant_high = `GET_MANTISSA_HIGH(data_format);
    localparam mant_low = `GET_MANTISSA_LOW(data_format);
    localparam mant_len = `GET_MANTISSA_LEN(data_format);
    
    // result segment params
    localparam result_value_len = result_interger_len + result_mantissa_len;
    localparam result_extend_len = result_value_len - (mant_len + 1); // full mantissa len

    // calculate bias value
    localparam bias = (1 << (exp_len - 1)) - 1;
    
    // extract sign, exponent and mantissa segment
    wire sign = a[sign_bit];
    wire [exp_len-1:0] exponent = a[exp_high:exp_low];
    wire [mant_len-1:0] mantissa = a[mant_high:mant_low];
    
    // calculate actual exponent value
    wire signed [exp_len:0] exp_val;  // extend one bit for sign
    assign exp_val = (exponent == 0) ? (1 - bias) : (exponent - bias);
    
    // construct complete mantissa (include extra 1 bit)
    wire [mant_len:0] mantissa_full;
    assign mantissa_full = (exponent == 0) ? {1'b0, mantissa} : {1'b1, mantissa};
    
    // calculate exact right shift number
    wire signed [exp_len:0] scaled_exp = (result_interger_len - 1) - exp_val;
    
    // place unshifted result number
    wire [(result_interger_len + result_mantissa_len) - 1:0] unshifted_result_value;
    assign unshifted_result_value = (result_extend_len > 0)? {mantissa_full, {result_extend_len{1'b0}}} : mantissa_full[mant_len -: result_value_len];

    // right shift
    reg [result_interger_len + result_mantissa_len - 1:0] shifted_result_value;
    always @(*) begin
        if (scaled_exp >= 0) begin
            // right shift
            shifted_result_value = unshifted_result_value >> scaled_exp;
        end else begin
            // left shift
            shifted_result_value = unshifted_result_value << (-scaled_exp);
        end
    end
    
    // complement result value
    reg [result_value_len:0] result_reg;
    always @(*) begin
        if (sign) begin
            result_reg = -{1'b0, shifted_result_value};
        end else begin
            result_reg = {1'b0, shifted_result_value};
        end
    end
    assign result = result_reg;

endmodule