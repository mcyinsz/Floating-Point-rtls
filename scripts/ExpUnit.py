from ModulePPA import *
import math

# exp unit
# compare tree, one mult, one add
# LUT number area and slop
# a[i] + k[i] * (x-x[i])
# assume x[i] does not need restore (high bits)
def get_ExpUnit_Area_Power(
    LUT_number: int = 16
) -> (float, float):

    # initialize total area/power
    total_area = LUT_number * COMPARE_AREA + MULT_AREA + ADD_AREA + (2 * LUT_number) * (SRAM_BITAREA * 32)
    total_power = LUT_number * COMPARE_POWER + MULT_POWER + ADD_POWER + (2 * LUT_number) * (SRAM_BITPOWER * 32)
    return total_area, total_power

if __name__ == "__main__":
    print(get_ExpUnit_Area_Power(16))