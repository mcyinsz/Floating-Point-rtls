`ifndef FP_PARAMS_VH
`define FP_PARAMS_VH

// 获取浮点数总长度
`define GET_FP_LEN(format) \
    ((format) == `FP32) ? `FP32_LEN : \
    ((format) == `FP16) ? `FP16_LEN : \
    `FP32_LEN  // 默认返回FP32长度

`define GET_EXP_LEN(format) \
    ((format) == `FP32) ? `FP32_EXP_LEN : \
    ((format) == `FP16) ? `FP16_EXP_LEN : \
    `FP32_EXP_LEN  // 默认返回FP32长度

`define GET_MANTISSA_LEN(format) \
    ((format) == `FP32) ? `FP32_MANTISSA_LEN : \
    ((format) == `FP16) ? `FP16_MANTISSA_LEN : \
    `FP32_MANTISSA_LEN  // 默认返回FP32长度

// 获取符号位位置
`define GET_SIGN_BIT(format) \
    ((format) == `FP32) ? `FP32_SIGN_BIT : \
    ((format) == `FP16) ? `FP16_SIGN_BIT : \
    `FP32_SIGN_BIT  // 默认返回FP32符号位

// 获取指数域高位位置
`define GET_EXP_HIGH(format) \
    ((format) == `FP32) ? `FP32_EXP_HIGH : \
    ((format) == `FP16) ? `FP16_EXP_HIGH : \
    `FP32_EXP_HIGH  // 默认返回FP32指数高位

// 获取指数域低位位置
`define GET_EXP_LOW(format) \
    ((format) == `FP32) ? `FP32_EXP_LOW : \
    ((format) == `FP16) ? `FP16_EXP_LOW : \
    `FP32_EXP_LOW  // 默认返回FP32指数低位

// 获取尾数域高位位置
`define GET_MANTISSA_HIGH(format) \
    ((format) == `FP32) ? `FP32_MANTISSA_HIGH : \
    ((format) == `FP16) ? `FP16_MANTISSA_HIGH : \
    `FP32_MANTISSA_HIGH  // 默认返回FP32尾数高位

// 获取尾数域低位位置
`define GET_MANTISSA_LOW(format) \
    ((format) == `FP32) ? `FP32_MANTISSA_LOW : \
    ((format) == `FP16) ? `FP16_MANTISSA_LOW : \
    `FP32_MANTISSA_LOW  // 默认返回FP32尾数低位

`endif