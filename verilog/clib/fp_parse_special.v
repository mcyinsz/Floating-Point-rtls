/*
    the first stage for floating point adder
        * arbitrate whether there is any special value
*/

module fp_parse_special #(
    parameter data_format = `FP32
) (
    input wire [(`GET_FP_LEN(data_format))-1:0] a,
    input wire [(`GET_FP_LEN(data_format))-1:0] b,
    output reg [1:0] special 
);
    
    // data format bit segments
    localparam sign_bit = (`GET_FP_LEN(data_format)) - 1;
    localparam exp_high = `GET_EXP_HIGH(data_format);
    localparam exp_low = `GET_EXP_LOW(data_format);
    localparam exp_len = `GET_EXP_LEN(data_format);
    localparam mantissa_high = `GET_MANTISSA_HIGH(data_format);
    localparam mantissa_low = `GET_MANTISSA_LOW(data_format);

    // special logic
    always @(*) begin
        if (is_nan(a) || is_nan(b)) begin
            special = `NAN;
        end else if (is_inf(a) && is_inf(b)) begin
            special = (a[sign_bit] == b[sign_bit]) ? `INF : `NAN;
        end else if (is_inf(a) || is_inf(b)) begin
            special = `INF;
        end else if (is_zero(a) && is_zero(b)) begin
            special = `ZERO;
        end else begin
            special = `NORMAL;
        end
    end

    // functions
    function is_nan;
        input [`GET_FP_LEN(data_format) - 1:0] val;
        begin
            is_nan = (val[exp_high:exp_low] == {exp_len{1'b1}}) && (val[mantissa_high:mantissa_low] != 0);
        end
    endfunction

    function is_inf;
        input [`GET_FP_LEN(data_format) - 1:0] val;
        begin
            is_inf = (val[exp_high:exp_low] == {exp_len{1'b1}}) && (val[mantissa_high:mantissa_low] == 0);
        end
    endfunction

    function is_zero;
        input [`GET_FP_LEN(data_format) - 2:0] val; // skip sign bit
        begin
            is_zero = (val[`GET_FP_LEN(data_format) - 2 : 0] == 0);
        end
    endfunction

endmodule