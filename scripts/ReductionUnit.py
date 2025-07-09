from ModulePPA import *
from ExpUnit import get_ExpUnit_Area_Power
import math

def ReductionUnit_Area_Power(
   exp_lut_number: int = 16 
) -> (float, float):

    # initialize total area/power
    total_area = 0
    total_power = 0

    # get max
    # requires one fp compare unit
    total_area += COMPARE_AREA
    total_power += COMPARE_POWER

    # subtract max exponent
    # requires two fp add unit
    total_area += 2 * ADD_AREA
    total_power += 2 * ADD_POWER

    # calculate exp
    # requires two fp exp unit
    total_area += 2 * get_ExpUnit_Area_Power(exp_lut_number)[0]
    total_power += 2 * get_ExpUnit_Area_Power(exp_lut_number)[1]

    # l * e^{m_i - m}
    # requires two fp mult unit
    total_area += 2 * MULT_AREA
    total_power += 2 * MULT_POWER

    # reduce l
    # requires one fp add unit
    total_area += ADD_AREA
    total_power += ADD_POWER

    # div reduced l
    # requires two fp div unit
    total_area += DIV_AREA
    total_power += DIV_POWER

    return total_area, total_power

if __name__ == "__main__":
    print("Reduction Unit (area(um^2), power(W)):", ReductionUnit_Area_Power())