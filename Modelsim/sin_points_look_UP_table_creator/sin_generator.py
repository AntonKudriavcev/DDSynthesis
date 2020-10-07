##-----------------------------------------------------------------------------
import numpy as np
import matplotlib.pyplot as plt

from hexadec_creator import hexadec_creator
##-----------------------------------------------------------------------------

bit_depth = 12
array_dimention  = 2**bit_depth

DAC_bit_resolution = 12

sin_points = np.longlong((np.sin(np.linspace(0, 2 * np.pi, array_dimention)) + 1)/2 * (2**DAC_bit_resolution - 1)) ## creating an array of sin signal values
plt.plot(sin_points)
plt.show()

# hexadec_creator(sin_points, DAC_bit_resolution) ## creating a hexadecimal file