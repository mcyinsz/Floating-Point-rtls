/*
    floating point multiplier stage 2.2 analysis special cases
*/

module fp_mult_special (
    // special bits
    input wire sign,
    input wire a_zero,
    input wire b_zero,
    input wire a_inf,
    input wire b_inf,
    input wire a_nan,
    input wire b_nan,
    // special cases with priority
    output wire nan,
    output wire inf,
    output wire zero
);

    assign nan = (a_nan || b_nan) ||  // any nan
                 (a_inf && b_zero) || // infinity multiply zero
                 (b_inf && a_zero);

    assign inf = (a_inf || b_inf) && !nan;

    assign zero = (a_zero || b_zero) && !nan;

endmodule