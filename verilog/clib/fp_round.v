module fp_round #(
    parameter data_format = `FP32
) (
    input wire [1:0] special,
    input wire sign,
    input wire [(`GET_EXP_LEN(data_format)) - 1 : 0] exp,
    input wire [(`GET_MANTISSA_LEN(data_format)) + (`GET_PROTECT_LEN(data_format)) + 1 - 1 : 0] mant,
    output wire [(`GET_FP_LEN(data_format)) - 1 : 0] sum
);

    // local params
    localparam exp_len = `GET_EXP_LEN(data_format);
    localparam mant_len = `GET_MANTISSA_LEN(data_format);
    localparam protect_len = `GET_PROTECT_LEN(data_format); 
    
    localparam full_one_exp = {exp_len{1'b1}};
    localparam full_zero_exp = {exp_len{1'b0}};
    localparam full_zero_mant = {mant_len{1'b0}};
    localparam leading_one_mant = {1'b1, {(mant_len-1){1'b0}}};

    // final bit segments
    reg final_sign;
    reg [exp_len - 1 : 0] final_exp;
    reg [mant_len - 1:0] final_mant;

    // round strategy
    // TODO: fit different protection bits (especially for protection bit shorter than 3)
    wire G = mant[protect_len-1];      // protection bit
    wire R = mant[protect_len-2];      // round bit
    wire S = |mant[protect_len-3:0];   // sticky bit
    wire LSB = mant[protect_len];      // mantissa's LSB
    wire round_up = (G & (R | S)) | (G & ~R & ~S & LSB); // round toward even number

    // mantissa carry (allocate one carry bit: {carry, prefix one, mantissa}) 
    wire [mant_len + 1:0] rounded_mant;
    assign rounded_mant = {1'b0, mant[(mant_len + protect_len + 1) - 1:protect_len]} + round_up;

    // carry and exponent change
    wire carry = rounded_mant[mant_len+1];
    wire [exp_len:0] carry_exp = {1'b0, exp} + carry;
    wire [exp_len:0] full_one_exp_extended = {1'b0, full_one_exp};
    wire overflow = (carry_exp >= full_one_exp_extended);

    // handle special values
    always @(*) begin
        case (special)
            `INF:    final_sign = sign;
            `NAN:    final_sign = 1'b0; // NaN: positive
            `ZERO:   final_sign = sign;
            default: final_sign = sign;
        endcase
    end

    always @(*) begin
        case (special)
            `INF:    final_exp = full_one_exp;
            `NAN:    final_exp = full_one_exp;
            `ZERO:   final_exp = full_zero_exp;
            default: final_exp = overflow ? full_one_exp : carry_exp[exp_len-1:0];
        endcase
    end

    always @(*) begin
        case (special)
            `INF:    final_mant = full_zero_mant;
            `NAN:    final_mant = leading_one_mant; // NaN: mantissa {1'b1, 00000...}
            `ZERO:   final_mant = full_zero_mant;
            default: begin
                if (overflow) 
                    final_mant = full_zero_mant; // overflow, round up to infinity
                else if (carry)
                    final_mant = rounded_mant[mant_len:1];  // right shift for carry
                else 
                    final_mant = rounded_mant[mant_len-1:0]; // do not change for general case
            end
        endcase
    end

    assign sum = {final_sign, final_exp, final_mant};

endmodule