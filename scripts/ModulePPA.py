# Area unit: um^2
# Power unit: w

# FP32 multiplier
MULT_AREA = 6922.351
MULT_POWER = 0.0021016

# FP32 adder
ADD_AREA = 4126.023 # 2309.472
ADD_POWER = 0.00117034 # 0.00053673

# FP32 divider
DIV_AREA = 4391.263
DIV_POWER = 0.00145984

# FP32 compare
COMPARE_AREA = 395.41
COMPARE_POWER = 6.88259e-05

# SRAM per bit
SRAM_BITAREA = 60000/(300 * 1e3) * (7/28)**2 # 28nm -> 7nm
SRAM_BITPOWER = 1e-3 / (0.12 * 1e3) # TODO: scale this param

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

# fp32 naive compare unit
# "Post-Syn Timing": 123,
# "Post-Syn Power": 6.88259e-05,
# "Post-Syn Area": 395.41,

# fp32 naive divider unit
# "Post-Syn Timing": 191,
# "Post-Syn Power": 0.00145984,
# "Post-Syn Area": 4391.263,