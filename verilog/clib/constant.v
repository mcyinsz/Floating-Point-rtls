/*
    special values
*/

// NORMAL value for reset state
`define NORMAL 2'b00

// infinity value (1'b1 for all exponent bits, 1'b0 for all mantissa bits, 1'b1/0 for sign bit)
`define INF 2'b01

// not-a-number value (1'b1 for all exponent bits, 1'b0 for all mantissa bits, 0 for sign bit)
`define NAN 2'b10

// zero value
`define ZERO 2'b11

/*
    bit segment for floating point numbers
*/

`define FP32_EXP_LEN 8
`define FP32_MANTISSA_LEN 23

`define FP16_EXP_LEN 5
`define FP16_MANTISSA_LEN 10

`define FP32_EXP_HIGH 30
`define FP32_EXP_LOW 23
`define FP32_MANTISSA_HIGH 22
`define FP32_MANTISSA_LOW 0

`define FP16_EXP_HIGH 14
`define FP16_EXP_LOW 10
`define FP16_MANTISSA_HIGH 9
`define FP16_MANTISSA_LOW 0
