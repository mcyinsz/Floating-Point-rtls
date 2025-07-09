# Area unit: um^2
# Power unit: w

# FP32 multiplier
MULT_AREA = 6922.351
MULT_POWER = 0.0021016

# FP32 adder
ADD_AREA = 4126.023
ADD_POWER = 0.00117034

# FP32 divider
DIV_AREA = 6922.351
DIV_POWER = 1e-3

# FP32 compare
COMPARE_AREA = 1000
COMPARE_POWER = 1e-4

# SRAM per bit
SRAM_BITAREA = 60000/(300 * 1e3)
SRAM_BITPOWER = 1e-3 / (0.12 * 1e3)

# ========================================================

# optional params

# fp32 naive adder
# "Post-Syn Timing": 194,
# "Post-Syn Power": 0.00117034,
# "Post-Syn Area": 4126.023,

# fp onecycle adder (fp32)
# "Post-Syn Timing": 432,
# "Post-Syn Power": 0.00053673,
# "Post-Syn Area": 2309.472,

# fp pipeline adder (fp32)
# "Post-Syn Timing": 293,
# "Post-Syn Power": 0.00114224,
# "Post-Syn Area": 3614.207,

# fp32 naive multiplier
# "Post-Syn Timing": 398,
# "Post-Syn Power": 0.0021016,
# "Post-Syn Area": 6922.351,