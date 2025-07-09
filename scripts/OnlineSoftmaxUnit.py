from ModulePPA import *
from ExpUnit import get_ExpUnit_Area_Power
import math

def OnlineSoftmaxUnit_Area_Power(
    vector_length: int,
    exp_lut_number: int = 16
):

    # initialize total area/power
    total_area = 0
    total_power = 0

    # get max exponent
    # requires vector_length + 1 - 1 compare unit (compare tree)
    total_area += (vector_length) * COMPARE_AREA
    total_power += (vector_length) * COMPARE_POWER

    # subtract max exponent
    # requires vector_length + 1 fp adder unit
    total_area += (vector_length + 1) * ADD_AREA
    total_power += (vector_length + 1) * ADD_POWER

    # calculate exp
    # requires vector_length + 1 fp adder unit
    total_area += (vector_length + 1) * get_ExpUnit_Area_Power(exp_lut_number)[0]
    total_power += (vector_length + 1) * get_ExpUnit_Area_Power(exp_lut_number)[1]

    # l_{i-1} * e^(m_{i-1} - m_i)
    # requires 1 fp mult unit
    total_area += MULT_AREA
    total_power += MULT_POWER

    # get l_i
    # adder tree, requires vector_length + 1 - 1 adder
    total_area += (vector_length) * ADD_AREA
    total_power += (vector_length) * ADD_POWER

    # div l_i
    # requires 1 fp div unit
    total_area += (vector_length + 1) * DIV_AREA
    total_power += (vector_length + 1) * DIV_POWER

    return total_area, total_power

if __name__ == "__main__":
    vector_length = 16
    print(f"{vector_length} len OSU, (area(um^2), power(W)):",OnlineSoftmaxUnit_Area_Power(16))