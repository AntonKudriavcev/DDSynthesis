##-----------------------------------------------------------------------------

##-----------------------------------------------------------------------------

import matplotlib.pyplot as plt
import numpy as np

##-----------------------------------------------------------------------------

f_sampling = 13e9  ## Hz  
f_carrier  = 1.3e9 + 0 ## Hz
t_impulse  = 10e-6  ## 
t_period   = 2e-6  ## 
num_of_imp = 1  ## 
deviation  = 3e6

mult_coef = 16384
accum_bit_deph     = 12
DAC_bit_resolution = 12

M = (mult_coef * 2**accum_bit_deph * f_carrier)/f_sampling
print('Шаг =\t', M)

M = int(M)
print('Округленный шаг =\t', M)

f_out = (M * f_sampling)/(mult_coef * 2**accum_bit_deph)
print('Требуемая вых. частота =\t', f_carrier)
print('Смоделировнная вых. частота =\t', f_out)

delta = (f_sampling)/(mult_coef * 2**accum_bit_deph)
print('Допустимое отклонение частоты от требуемой = %.3f\t' %delta)

time_of_simulation = (num_of_imp - 1) * t_period + t_impulse
num_of_samples     = (((num_of_imp - 1) * t_period) + t_impulse) * f_sampling

print('Неокругленное количество отсчетов в сигнале\t=', num_of_samples)

num_of_samples = int(num_of_samples)

print('Oкругленное количество отсчетов в сигнале\t=', num_of_samples)

##-----------------------------------------------------------------------------

path = 'D:/study/6_year/diploma/Diploma/code/DDSynthesis/Modelsim/PSK/data/output_signal.txt'

with open(path) as file:
    data = file.read().split()

signal = []

for i in range(len(data)):
    if (data[i] == 'z'):
        # data[i] = -1000
        pass
    else:
        signal.append(int(data[i], 10))
        # data[i] = int(data[i], 10)



signal = np.array(signal[0:num_of_samples])

# fig, (ax1, ax2) = plt.subplots(nrows = 2, ncols = 1)

# time = np.linspace(0, 1, num_of_samples) * time_of_simulation
# ax1.plot(time, signal[0:num_of_samples])
# ax1.grid()


signal = signal/(2**DAC_bit_resolution - 1) - 0.5

# spectrum = abs(np.fft.fft(signal, n = 1*len(signal), axis = -1))
# spectrum/= spectrum.max()
# frequ_points = np.linspace(0, 1, len(spectrum)) * f_sampling

# ax2.plot(frequ_points, spectrum)
# ax2.set_xlim(0, f_sampling/2)
# ax2.grid()

# simulated_freq = np.argmax(spectrum) * f_sampling/(len(spectrum)-1)
# print('Частота смоделированного сигнала =\t', simulated_freq)

acf = abs(np.correlate(signal, signal, 'full'))
acf /= acf.max()
acf = 10 * np.log10(acf)
plt.plot(acf)
plt.grid()
plt.show()