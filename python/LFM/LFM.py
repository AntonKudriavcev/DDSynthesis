##-----------------------------------------------------------------------------
## Editor: Kudriavcev Anton
## e-mail: Kudiavcev.Anton@yandex.ru
##-----------------------------------------------------------------------------

from matplotlib import pyplot as plt
import numpy as np  

##-----------------------------------------------------------------------------

def step_coef(array_dimention, f_sampling, t_disc, f_max, f_min, t_impulse, step_num):

    if ((step_num * t_disc) < t_impulse/2):
        M = int( (array_dimention/f_sampling) * (f_max - ((f_max - f_min)/(t_impulse/2)) * (step_num * t_disc))) & (array_dimention - 1)  ## оставить только младшие разряды 
    else:
        M = int( (array_dimention/f_sampling) * (-(f_max - 2 * f_min) + ((f_max - f_min)/(t_impulse/2)) * (step_num * t_disc))) & (array_dimention - 1)  ## оставить только младшие разряды 

    return M

##-----------------------------------------------------------------------------

def phase_accum(num_of_points, array_dimention, f_sampling, t_disc, f_max, f_min, t_impulse):

    phase_points = [0]  ## начинаем индексирование с нулевого элемента
    accum = 0

    for step_num in range(1, num_of_points):

        accum = int((accum + step_coef(array_dimention, f_sampling, t_disc, f_max, f_min, t_impulse, step_num))) & (array_dimention - 1) ## оставить только младшие разряды 
        phase_points.append(accum)

    phase_points = np.longlong(np.array(phase_points))

    return phase_points

##-----------------------------------------------------------------------------

f_carrier   = 1.3e9        # Hz
f_sampling  = 35e9   	   # Hz
t_disc      = 1/f_sampling # sec
accum_bit_depth  = 16
array_dimention  = 2**accum_bit_depth

##-user param-------------
f_deviation  = 3e6    # Hz
t_impulse    = 60e-6 # sec
# t_repetition = 0
# num_of_impulse = 0

##-----------------------------------------------------------------------------

t_disc = 1/f_sampling

time_of_simulation = t_impulse
num_of_points      = int(t_impulse/t_disc)

f_max = f_carrier + (f_deviation/2)
f_min = f_carrier - (f_deviation/2)

sin_points = np.sin(np.linspace(0, 2 * np.pi, array_dimention)) # creating an array of sin signal values

phase_points = phase_accum(num_of_points, array_dimention, f_sampling, t_disc, f_max, f_min, t_impulse)

sin_points = sin_points[phase_points]


fig, (ax1, ax2) = plt.subplots(nrows = 2, ncols = 1)



ax1.plot(sin_points)


spectrum = abs(np.fft.fft(sin_points, n = 10 * num_of_points, axis = -1))
spectrum/= spectrum.max()
frequ_points = np.linspace(0, 1, len(spectrum)) * f_sampling
ax2.plot(frequ_points, spectrum)
ax2.set_xlim(f_carrier - f_deviation, f_carrier + f_deviation)
ax2.grid()
plt.show()


