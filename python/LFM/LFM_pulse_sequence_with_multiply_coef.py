##-----------------------------------------------------------------------------
## Editor: Kudriavcev Anton
## e-mail: Kudiavcev.Anton@yandex.ru
##-----------------------------------------------------------------------------

from matplotlib import pyplot as plt
import numpy as np  

##-----------------------------------------------------------------------------

def step_coef(array_dimention, mult_coef, f_sampling, t_disc, f_max, f_min, t_impulse, step_num):

    global freq_max_div
    global freq_max_cnt
    global freq_max_mod
    global dlt_freq_div
    global dlt_freq_cnt
    global dlt_freq_mod
    global accum
    global imp_counter
    global half_imp_cnt
    global half_imp_flag
    global add_to_accum
    
    imp_counter  += 1
    freq_max_cnt += freq_max_mod
    

    if (freq_max_cnt >= f_sampling):
        # print(accum)
        accum += 1
        freq_max_cnt -= (f_sampling)

    if ((imp_counter) < t_impulse/t_disc/2):
        half_imp_cnt += 1
        dlt_freq_cnt += half_imp_cnt * dlt_freq_mod

        if (dlt_freq_cnt >= 2 * (t_impulse/2 * f_sampling * f_sampling)):
            accum -= 2
            dlt_freq_cnt -= 2 * (t_impulse/2 * f_sampling * f_sampling)
        elif (dlt_freq_cnt >= (t_impulse/2 * f_sampling * f_sampling)):
            accum -= 1
            dlt_freq_cnt -= (t_impulse/2 * f_sampling * f_sampling)
        freq_max_div -= dlt_freq_div
    else:
        dlt_freq_cnt = dlt_freq_cnt + 2 * (t_impulse/2 * f_sampling * f_sampling) - half_imp_cnt * dlt_freq_mod
        half_imp_cnt -= 1
        # dlt_freq_cnt += half_imp_cnt * dlt_freq_mod

        # print(half_imp_cnt)

        if (dlt_freq_cnt >= 2 * (t_impulse/2 * f_sampling * f_sampling)):
            # accum += 2
            dlt_freq_cnt -= 2 * (t_impulse/2 * f_sampling * f_sampling)
        elif (dlt_freq_cnt >= (t_impulse/2 * f_sampling * f_sampling)):
            accum -= 1
            dlt_freq_cnt -= (t_impulse/2 * f_sampling * f_sampling)
        else:
            accum -= 2

        freq_max_div += dlt_freq_div
            

    M = freq_max_div

    return M

##-----------------------------------------------------------------------------

def phase_accum(num_of_points, array_dimention, mult_coef, f_sampling, t_disc, f_max, f_min, t_impulse):

    phase_points = [0]  ## начинаем индексирование с нулевого элемента
    # accum = int(0)
    global accum

    for step_num in range(1, num_of_points):

        var = step_coef(array_dimention, mult_coef, f_sampling, t_disc, f_max, f_min, t_impulse, step_num)+0.0
        accum = (accum + var)
        # print(accum)
        # phase = int(accum/mult_coef) & (array_dimention - 1)

        phase = int(accum) & (array_dimention - 1)
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
f_sampling  = 13e9         # Hz
t_disc      = 1/f_sampling # sec

bit_depth = 12
mult_coef = 16384

array_dimention  = 2**bit_depth

DAC_bit_resolution = 12

##-user param-------------
f_deviation  = 3e6*1 # Hz
t_impulse    = 25e-6 # sec
t_repetition = 1000e-6
num_of_impulse = 1



##-----------------------------------------------------------------------------

t_disc = 1/f_sampling

num_of_sin_points  = int(t_impulse/t_disc)

f_max = f_carrier + (f_deviation/2)
f_min = f_carrier - (f_deviation/2)

accum = int(0)
freq_max_div = ((array_dimention * f_max) // f_sampling)
freq_max_mod = int((array_dimention * f_max) %  f_sampling)
freq_max_cnt = 0
print((array_dimention * f_max) / f_sampling)
print(freq_max_div)
print(freq_max_mod)

dlt_freq_div = (array_dimention * (f_deviation)) // (t_impulse/2 * f_sampling * f_sampling)
dlt_freq_mod = (array_dimention * (f_deviation)) %  (t_impulse/2 * f_sampling * f_sampling)
dlt_freq_cnt = 0
print((array_dimention * (f_max - f_min)) / (t_impulse * f_sampling * f_sampling))
print(dlt_freq_div)
print(dlt_freq_mod)

half_imp_cnt  = 0
imp_counter   = 0
half_imp_flag = 0

add_to_accum = 0

# dlt_step = 0
MM = (mult_coef * array_dimention * f_carrier)/f_sampling
# print('Шаг =\t', MM)

MM = int(MM)
# print('Округленный шаг =\t', MM)

f_delta = f_sampling/(mult_coef * array_dimention)
print(f_delta)

sin_points = np.longlong((np.sin(np.linspace(0, 2 * np.pi, array_dimention)) + 1)/2 * (2**DAC_bit_resolution - 1))# creating an array of sin signal values

sin_phase_points = phase_accum(num_of_sin_points, array_dimention, mult_coef, f_sampling, t_disc, f_max, f_min, t_impulse)
print(sin_phase_points[0:1000])

sin_points = sin_points[sin_phase_points]

##-----------------------------------------------------------------------------

num_of_zero_points = int((t_repetition - t_impulse)/t_disc)

zero_points        = np.longlong((np.zeros(num_of_zero_points, dtype= np.int32) + 1)/2 * (2**DAC_bit_resolution - 1))

##-----------------------------------------------------------------------------

output_signal = collect_a_packet(num_of_impulse, sin_points, zero_points)

print(output_signal[1])

##-----------------------------------------------------------------------------

fig, (ax1, ax2) = plt.subplots(nrows = 2, ncols = 1)

time_of_simulation = (num_of_impulse * t_impulse) + ((num_of_impulse - 1) * (t_repetition - t_impulse))
print(time_of_simulation)
time_points = np.linspace(0, 1, len(output_signal)) * time_of_simulation
ax1.plot(time_points, output_signal)
ax1.grid()

output_signal = output_signal/(2**DAC_bit_resolution - 1) - 0.5

spectrum = abs(np.fft.fft(output_signal, n = 1 * len(output_signal),  axis = -1))
spectrum/= spectrum.max()
frequ_points = np.linspace(0, 1, len(spectrum)) * f_sampling
ax2.plot(frequ_points, spectrum)
ax2.set_xlim(f_carrier - f_deviation, f_carrier + f_deviation)
ax2.grid()
plt.show()

simulated_freq = np.argmax(spectrum) * f_sampling/(len(spectrum)-1)
print('Частота смоделированного сигнала =\t', simulated_freq)


