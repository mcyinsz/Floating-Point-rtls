`ifndef FP_PARAMS_VH
`define FP_PARAMS_VH

// get total length of floating point number
`define GET_FP_LEN(format) \
    ((format) == `FP32) ? `FP32_LEN : \
    ((format) == `FP16) ? `FP16_LEN : \
    `FP32_LEN

// exponent segment length
`define GET_EXP_LEN(format) \
    ((format) == `FP32) ? `FP32_EXP_LEN : \
    ((format) == `FP16) ? `FP16_EXP_LEN : \
    `FP32_EXP_LEN

// mantissa segment length
`define GET_MANTISSA_LEN(format) \
    ((format) == `FP32) ? `FP32_MANTISSA_LEN : \
    ((format) == `FP16) ? `FP16_MANTISSA_LEN : \
    `FP32_MANTISSA_LEN  

// get sign bit position
`define GET_SIGN_BIT(format) \
    ((format) == `FP32) ? `FP32_SIGN_BIT : \
    ((format) == `FP16) ? `FP16_SIGN_BIT : \
    `FP32_SIGN_BIT

// get exponent highest bit position
`define GET_EXP_HIGH(format) \
    ((format) == `FP32) ? `FP32_EXP_HIGH : \
    ((format) == `FP16) ? `FP16_EXP_HIGH : \
    `FP32_EXP_HIGH  

// get exponent lowest bit position
`define GET_EXP_LOW(format) \
    ((format) == `FP32) ? `FP32_EXP_LOW : \
    ((format) == `FP16) ? `FP16_EXP_LOW : \
    `FP32_EXP_LOW

// get mantissa highest bit position
`define GET_MANTISSA_HIGH(format) \
    ((format) == `FP32) ? `FP32_MANTISSA_HIGH : \
    ((format) == `FP16) ? `FP16_MANTISSA_HIGH : \
    `FP32_MANTISSA_HIGH

// get mantissa lowest bit position
`define GET_MANTISSA_LOW(format) \
    ((format) == `FP32) ? `FP32_MANTISSA_LOW : \
    ((format) == `FP16) ? `FP16_MANTISSA_LOW : \
    `FP32_MANTISSA_LOW

// get protect (preserved segment) length during align stage
`define GET_PROTECT_LEN(format) \
    ((format) == `FP32) ? `FP32_PROTECT_LEN : \
    ((format) == `FP16) ? `FP16_PROTECT_LEN : \
    `FP32_PROTECT_LEN

`endif