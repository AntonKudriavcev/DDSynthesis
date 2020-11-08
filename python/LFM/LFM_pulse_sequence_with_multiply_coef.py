##-----------------------------------------------------------------------------
## Editor: Kudriavcev Anton
## e-mail: Kudiavcev.Anton@yandex.ru
##-----------------------------------------------------------------------------

from matplotlib import pyplot as plt
import numpy as np  

##-----------------------------------------------------------------------------

def step_coef(array_dimention, mult_coef, f_sampling, t_disc, f_max, f_min, t_impulse, step_num):

    if ((step_num * t_disc) < t_impulse/2):
        M = int(mult_coef * (array_dimention/f_sampling) * (f_max - ((f_max - f_min)/(t_impulse/2)) * (step_num * t_disc)))
    else:
        M = int(mult_coef * (array_dimention/f_sampling) * (-(f_max - 2 * f_min) + ((f_max - f_min)/(t_impulse/2)) * (step_num * t_disc)))

    return M

##-----------------------------------------------------------------------------

def phase_accum(num_of_points, array_dimention, mult_coef, f_sampling, t_disc, f_max, f_min, t_impulse):

    phase_points = [0]  ## начинаем индексирование с нулевого элемента
    accum = int(0)

    for step_num in range(1, num_of_points):

        accum = int((accum + step_coef(array_dimention, mult_coef, f_sampling, t_disc, f_max, f_min, t_impulse, step_num)))
        # accum = int(accum + 6710888) & (2**26 - 1)
        phase = int(accum/mult_coef) & (array_dimention - 1)

        phase_points.append(phase)
   
    # phase_points[len(phase_points)-1] = 0
    phase_points = np.longlong(np.array(phase_points))

    return phase_points

##-----------------------------------------------------------------------------

def collect_a_packet(num_of_impulse, sin_points, zero_points):

    packet = np.array([])

    for i in range(num_of_impulse - 1):
        packet = np.concatenate((packet, sin_points), axis=0)
        packet = np.concatenate((packet, zero_points), axis=0)

    packet = np.concatenate((packet, sin_points), axis=0)

    return packet

##-----------------------------------------------------------------------------

f_carrier   = 1.3e9       # Hz
f_sampling  = 13e9   	   # Hz
t_disc      = 1/f_sampling # sec

bit_depth = 12
mult_coef = 16384
array_dimention  = 2**bit_depth

DAC_bit_resolution = 12

##-user param-------------
f_deviation  = 3e6*1 # Hz
t_impulse    = 10e-6 # sec
t_repetition = 400e-6
num_of_impulse = 1

##-----------------------------------------------------------------------------

t_disc = 1/f_sampling

num_of_sin_points  = int(t_impulse/t_disc)

f_max = f_carrier + (f_deviation/2)
f_min = f_carrier - (f_deviation/2)

MM = (mult_coef * 2**DAC_bit_resolution * f_carrier)/f_sampling
# print('Шаг =\t', MM)

MM = int(MM)
# print('Округленный шаг =\t', MM)

sin_points = np.longlong((np.sin(np.linspace(0, 2 * np.pi, array_dimention)) + 1)/2 * (2**DAC_bit_resolution - 1))# creating an array of sin signal values

sin_phase_points = phase_accum(num_of_sin_points, array_dimention, mult_coef, f_sampling, t_disc, f_max, f_min, t_impulse)

sin_points = sin_points[sin_phase_points]

##-----------------------------------------------------------------------------

num_of_zero_points = int((t_repetition - t_impulse)/t_disc)

zero_points        = np.longlong((np.zeros(num_of_zero_points, dtype= np.int32) + 1)/2 * (2**DAC_bit_resolution - 1))

##-----------------------------------------------------------------------------

output_signal = collect_a_packet(num_of_impulse, sin_points, zero_points)

print(output_signal[1])

##-----------------------------------------------------------------------------

fig, (ax2) = plt.subplots(nrows = 1, ncols = 1)

time_of_simulation = (num_of_impulse * t_impulse) + ((num_of_impulse - 1) * (t_repetition - t_impulse))
print(time_of_simulation)
time_points = np.linspace(0, 1, len(output_signal)) * time_of_simulation
# ax1.plot(time_points, output_signal)
# ax1.grid()

output_signal = output_signal/(2**DAC_bit_resolution - 1) - 0.5

spectrum = abs(np.fft.fft(output_signal, n = 1*len(output_signal),  axis = -1))
spectrum/= spectrum.max()
frequ_points = np.linspace(0, 1, len(spectrum)) * f_sampling
ax2.plot(frequ_points, spectrum)
ax2.set_xlim(f_carrier - f_deviation, f_carrier + f_deviation)
ax2.grid()
plt.show()

simulated_freq = np.argmax(spectrum) * f_sampling/(len(spectrum)-1)
print('Частота смоделированного сигнала =\t', simulated_freq)


