/*
    a five-stage floating point adder
*/

module fp_pipeline_adder #(
    parameter data_format = `FP32
) (
    input wire clock,
    input wire reset,
    input wire [(`GET_FP_LEN(data_format))-1:0] a,
    input wire [(`GET_FP_LEN(data_format))-1:0] b,
    input wire a_valid,
    input wire b_valid,
    output wire a_ready,
    output wire b_ready,
    output wire [(`GET_FP_LEN(data_format))-1:0] sum,
    output wire sum_valid,
    input wire sum_ready
);

    // localparams
    localparam fp_len = `GET_FP_LEN(data_format);
    localparam mantissa_len = `GET_MANTISSA_LEN(data_format);
    localparam exp_len = `GET_EXP_LEN(data_format);
    localparam protect_len = `GET_PROTECT_LEN(data_format);

    // stage 1 intermediate varieable
    wire [fp_len-1:0]stage_1_a_s;
    wire [fp_len-1:0]stage_1_b_s;
    wire [fp_len-1:0]stage_1_a_q;
    wire [fp_len-1:0]stage_1_b_q;
    wire [1:0]stage_1_special_s;
    wire [1:0]stage_1_special_q;
    wire stage_1_ready; // stage 1 -> input
    wire stage_1_valid; // stage 1 -> stage 2

    // stage 2 intermediate varieable
    wire stage_2_largeexp_sign_s;
    wire stage_2_largeexp_sign_q;
    wire stage_2_smallexp_sign_s;
    wire stage_2_smallexp_sign_q;
    wire [mantissa_len + protect_len + 1 - 1:0]stage_2_largeexp_mantissa_s;
    wire [mantissa_len + protect_len + 1 - 1:0]stage_2_largeexp_mantissa_q;
    wire [mantissa_len + protect_len + 1 - 1:0]stage_2_smallexp_mantissa_s;
    wire [mantissa_len + protect_len + 1 - 1:0]stage_2_smallexp_mantissa_q;
    wire [exp_len - 1:0] stage_2_exp_s;
    wire [exp_len - 1:0] stage_2_exp_q;
    wire [1:0]stage_2_special_s;
    wire [1:0]stage_2_special_q;
    wire stage_2_ready;
    wire stage_2_valid;

    // stage 3 intermediate varieable
    wire stage_3_sign_s;
    wire stage_3_sign_q;
    wire [mantissa_len + protect_len + 2 - 1:0] stage_3_mantissa_s;
    wire [mantissa_len + protect_len + 2 - 1:0] stage_3_mantissa_q;
    wire stage_3_op_s;
    wire stage_3_op_q;
    wire [exp_len - 1:0] stage_3_exp_s;
    wire [exp_len - 1:0] stage_3_exp_q;
    wire [1:0]stage_3_special_s;
    wire [1:0]stage_3_special_q;
    wire stage_3_ready;
    wire stage_3_valid;

    // stage 4 intermediate varieable
    wire stage_4_sign_s;
    wire stage_4_sign_q;
    wire [mantissa_len + protect_len + 1 - 1:0] stage_4_mantissa_s;
    wire [mantissa_len + protect_len + 1 - 1:0] stage_4_mantissa_q;
    wire [exp_len - 1:0] stage_4_exp_s;
    wire [exp_len - 1:0] stage_4_exp_q;
    wire [1:0]stage_4_special_s;
    wire [1:0]stage_4_special_q;
    wire stage_4_ready;  // stage 4 -> stage 3
    wire stage_4_valid;  // stage 4 -> output

    // stage 1: parse_special
    fp_adder_parse_special #(
        .data_format(data_format)
    ) stage_1 (
        .a(a),
        .b(b),
        .special(stage_1_special_s)
    );

    wire in_valid = a_valid && b_valid;
    wire in_fire = in_valid && stage_1_ready;
    decouple_pipeline_ctrl stage_1_ctrl (
        .clock(clock),
        .reset(reset),
        .in_valid(in_valid),
        .out_ready(stage_2_ready),
        .in_ready(stage_1_ready),
        .out_valid(stage_1_valid)
    );

    dff #(
        .width(fp_len)
    ) stage_1_a_dff (
        .clk(clock),
        .reset(reset),
        .active(in_fire),
        .d(stage_1_a_s),
        .q(stage_1_a_q)
    );

    dff #(
        .width(fp_len)
    ) stage_1_b_dff (
        .clk(clock),
        .reset(reset),
        .active(in_fire),
        .d(stage_1_b_s),
        .q(stage_1_b_q)
    );

    dff #(
        .width(2)
    ) stage_1_special_dff (
        .clk(clock),
        .reset(reset),
        .active(in_fire),
        .d(stage_1_special_s),
        .q(stage_1_special_q)
    );

    // stage 2: mantissa align
    fp_adder_mantissa_align #(
        .data_format(data_format)
    ) stage_2 (
        .a(stage_1_a_q),
        .b(stage_1_b_q),
        .a_sign(stage_2_largeexp_sign_s),
        .b_sign(stage_2_smallexp_sign_s),
        .exp(stage_2_exp_s),
        .mant_a(stage_2_largeexp_mantissa_s),
        .mant_b(stage_2_smallexp_mantissa_s)
    );

    decouple_pipeline_ctrl stage_2_ctrl (
        .clock(clock),
        .reset(reset),
        .in_valid(stage_1_valid),
        .out_ready(stage_3_ready),
        .in_ready(stage_2_ready),
        .out_valid(stage_2_valid)
    );

    wire stage_1_fire;
    assign stage_1_fire = stage_1_valid && stage_2_ready;

    dff #(
        .width(1)
    ) stage_2_largeexp_sign_dff (
        .clk(clock),
        .reset(reset),
        .active(stage_1_fire),
        .d(stage_2_largeexp_sign_s),
        .q(stage_2_largeexp_sign_q)
    );

    dff #(
        .width(1)
    ) stage_2_smallexp_sign_dff (
        .clk(clock),
        .reset(reset),
        .active(stage_1_fire),
        .d(stage_2_smallexp_sign_s),
        .q(stage_2_smallexp_sign_q)
    );

    dff #(
        .width(mantissa_len + protect_len + 1)
    ) stage_2_largeexp_mantissa_dff (
        .clk(clock),
        .reset(reset),
        .active(stage_1_fire),
        .d(stage_2_largeexp_mantissa_s),
        .q(stage_2_largeexp_mantissa_q)
    );

    dff #(
        .width(mantissa_len + protect_len + 1)
    ) stage_2_smallexp_mantissa_dff (
        .clk(clock),
        .reset(reset),
        .active(stage_1_fire),
        .d(stage_2_smallexp_mantissa_s),
        .q(stage_2_smallexp_mantissa_q)
    );

    dff #(
        .width(exp_len)
    ) stage_2_exp_dff (
        .clk(clock),
        .reset(reset),
        .active(stage_1_fire),
        .d(stage_2_exp_s),
        .q(stage_2_exp_q)
    );

    assign stage_2_special_s = stage_1_special_q;
    dff #(
        .width(2)
    ) stage_2_special_dff (
        .clk(clock),
        .reset(reset),
        .active(stage_1_fire),
        .d(stage_2_special_s),
        .q(stage_2_special_q)
    );

    // stage 3: mantissa calculation
    fp_adder_mantissa_cal #(
        .data_format(data_format)
    ) stage_3 (
        .a_sign(stage_2_largeexp_sign_q),
        .b_sign(stage_2_smallexp_sign_q),
        .a_mant(stage_2_largeexp_mantissa_q),
        .b_mant(stage_2_smallexp_mantissa_q),
        .cal_result(stage_3_mantissa_s),
        .cal_sign(stage_3_sign_s),
        .effective_op(stage_3_op_s)
    );

    decouple_pipeline_ctrl stage_3_ctrl (
        .clock(clock),
        .reset(reset),
        .in_valid(stage_2_valid),
        .out_ready(stage_4_ready),
        .in_ready(stage_3_ready),
        .out_valid(stage_3_valid)
    );

    wire stage_2_fire;
    assign stage_2_fire = stage_2_valid && stage_3_ready;

    dff #(
        .width(1)
    ) stage_3_sign_dff (
        .clk(clock),
        .reset(reset),
        .active(stage_2_fire),
        .d(stage_3_sign_s),
        .q(stage_3_sign_q)
    );

    dff #(
        .width(mantissa_len + protect_len + 2)
    ) stage_3_mantissa_dff (
        .clk(clock),
        .reset(reset),
        .active(stage_2_fire),
        .d(stage_3_mantissa_s),
        .q(stage_3_mantissa_q)
    );

    dff #(
        .width(1)
    ) stage_3_op_dff (
        .clk(clock),
        .reset(reset),
        .active(stage_2_fire),
        .d(stage_3_op_s),
        .q(stage_3_op_q)
    );

    assign stage_3_exp_s = stage_2_exp_q;
    dff #(
        .width(exp_len)
    ) stage_3_exp_dff (
        .clk(clock),
        .reset(reset),
        .active(stage_2_fire),
        .d(stage_3_exp_s),
        .q(stage_3_exp_q)
    );

    assign stage_3_special_s = stage_2_special_q;
    dff #(
        .width(2)
    ) stage_3_special_dff (
        .clk(clock),
        .reset(reset),
        .active(stage_2_fire),
        .d(stage_3_special_s),
        .q(stage_3_special_q)
    );

    // stage 4: standardizing
    fp_adder_standardizing #(
        .data_format(data_format)
    ) stage_4 (
        .exp(stage_3_exp_q),
        .cal_result(stage_3_mantissa_q),
        .effective_op(stage_3_op_q),
        .mant(stage_4_mantissa_s),
        .standardizing_exp(stage_4_exp_s)
    );

    decouple_pipeline_ctrl stage_4_ctrl (
        .clock(clock),
        .reset(reset),
        .in_valid(stage_3_valid),
        .out_ready(sum_ready),
        .in_ready(stage_4_ready),
        .out_valid(stage_4_valid)
    );

    wire stage_3_fire;
    assign stage_3_fire = stage_3_valid && stage_4_ready;
    
    dff #(
        .width(mantissa_len + protect_len + 1)
    ) stage_4_mantissa_dff (
        .clk(clock),
        .reset(reset),
        .active(stage_3_fire),
        .d(stage_4_mantissa_s),
        .q(stage_4_mantissa_q)
    );

    dff #(
        .width(exp_len)
    ) stage_4_exp_dff (
        .clk(clock),
        .reset(reset),
        .active(stage_3_fire),
        .d(stage_4_exp_s),
        .q(stage_4_exp_q)
    );

    assign stage_4_special_s = stage_3_special_q;
    dff #(
        .width(2)
    ) stage_4_special_dff (
        .clk(clock),
        .reset(reset),
        .active(stage_3_fire),
        .d(stage_4_special_s),
        .q(stage_4_special_q)
    );

    assign stage_4_sign_s = stage_3_sign_q;
    dff #(
        .width(1)
    ) stage_4_sign_dff (
        .clk(clock),
        .reset(reset),
        .active(stage_3_fire),
        .d(stage_4_sign_s),
        .q(stage_4_sign_q)
    );

    // stage 5: round
    fp_adder_round #(
        .data_format(data_format)
    ) stage_5 (
        .special(stage_4_special_q),
        .sign(stage_4_sign_q),
        .exp(stage_4_exp_q),
        .mant(stage_4_mantissa_q),
        .sum(sum)
    );

    // i/o decouple logic
    assign stage_1_a_s = a;
    assign stage_1_b_s = b;
    assign sum_valid = stage_4_valid;
    assign a_ready = stage_1_ready;
    assign b_ready = stage_1_ready;

endmodule