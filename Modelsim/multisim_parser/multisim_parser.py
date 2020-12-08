##-----------------------------------------------------------------------------

##-----------------------------------------------------------------------------

import matplotlib.pyplot as plt
import numpy as np

##-----------------------------------------------------------------------------

f_sampling = 13e9  ## Hz  
f_carrier  = 1.3e9 + 0 ## Hz
t_impulse  = 1e-6  ## 

vobulation  = 1
num_of_imp  = 3  ## 

t_period_1  = 2e-6  ## 
t_period_2  = 3e-6  ## 
t_period_3  = 4e-6  ## 
t_period_4  = 2e-6  ## 
t_period_5  = 2e-6  ## 
t_period_6  = 2e-6  ## 
t_period_7  = 2e-6  ## 
t_period_8  = 2e-6  ## 
t_period_9  = 2e-6  ## 
t_period_10 = 2e-6  ## 
t_period_11 = 2e-6  ## 
t_period_12 = 2e-6  ## 
t_period_13 = 2e-6  ## 
t_period_14 = 2e-6  ## 
t_period_15 = 2e-6  ## 
t_period_16 = 2e-6  ## 
t_period_17 = 2e-6  ## 
t_period_18 = 2e-6  ## 
t_period_19 = 2e-6  ## 
t_period_20 = 2e-6  ## 
t_period_21 = 2e-6  ## 
t_period_22 = 2e-6  ## 
t_period_23 = 2e-6  ## 
t_period_24 = 2e-6  ## 
t_period_25 = 2e-6  ## 
t_period_26 = 2e-6  ## 
t_period_27 = 2e-6  ## 
t_period_28 = 2e-6  ## 
t_period_29 = 2e-6  ## 
t_period_30 = 2e-6  ## 
t_period_31 = 2e-6  ## 
t_period_32 = 2e-6  ## 


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

if vobulation:
    time_of_simulation = (t_impulse + 
                         (t_period_1  * (num_of_imp > 1))  +
                         (t_period_2  * (num_of_imp > 2))  +
                         (t_period_3  * (num_of_imp > 3))  + 
                         (t_period_4  * (num_of_imp > 4))  + 
                         (t_period_5  * (num_of_imp > 5))  + 
                         (t_period_6  * (num_of_imp > 6))  + 
                         (t_period_7  * (num_of_imp > 7))  + 
                         (t_period_8  * (num_of_imp > 8))  + 
                         (t_period_9  * (num_of_imp > 9))  + 
                         (t_period_10 * (num_of_imp > 10)) +
                         (t_period_11 * (num_of_imp > 11)) +
                         (t_period_12 * (num_of_imp > 12)) +
                         (t_period_13 * (num_of_imp > 13)) + 
                         (t_period_14 * (num_of_imp > 14)) + 
                         (t_period_15 * (num_of_imp > 15)) + 
                         (t_period_16 * (num_of_imp > 16)) + 
                         (t_period_17 * (num_of_imp > 17)) + 
                         (t_period_18 * (num_of_imp > 18)) + 
                         (t_period_19 * (num_of_imp > 19)) + 
                         (t_period_20 * (num_of_imp > 20)) +
                         (t_period_21 * (num_of_imp > 21)) +
                         (t_period_22 * (num_of_imp > 22)) +
                         (t_period_23 * (num_of_imp > 23)) + 
                         (t_period_24 * (num_of_imp > 24)) + 
                         (t_period_25 * (num_of_imp > 25)) + 
                         (t_period_26 * (num_of_imp > 26)) + 
                         (t_period_27 * (num_of_imp > 27)) + 
                         (t_period_28 * (num_of_imp > 28)) + 
                         (t_period_29 * (num_of_imp > 29)) + 
                         (t_period_30 * (num_of_imp > 30)) +
                         (t_period_31 * (num_of_imp > 31)) +
                         (t_period_32 * (num_of_imp > 32)))
else:
    time_of_simulation = (num_of_imp - 1) * t_period_1 + t_impulse

num_of_samples     = time_of_simulation * f_sampling

print('Неокругленное количество отсчетов в сигнале\t=', num_of_samples)

num_of_samples = int(num_of_samples)

print('Oкругленное количество отсчетов в сигнале\t=', num_of_samples)

##-----------------------------------------------------------------------------

path = 'D:/study/6_year/diploma/Diploma/code/DDSynthesis/Modelsim/digital_synthesizer_v1.2.1/data/output_signal.txt'

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

m_tr     = int(2**DAC_bit_resolution/2 - 1) ## требуемое значение матожидания выходного процесса
sigma_tr = int(m_tr/3) ## требуемое значение СКО выходного процесса

# x = np.linspace(0, 4095, 4096)
# w = 1/(np.sqrt(2*np.pi) * sigma_tr) * np.exp(-(x - m_tr)**2/(2*sigma_tr**2))
# plt.hist(signal, bins = 100, density = True)
# plt.plot(x, w)
# plt.show()

fig, (ax1, ax2) = plt.subplots(nrows = 2, ncols = 1)

time = np.linspace(0, 1, num_of_samples) * time_of_simulation
ax1.plot(time, signal[0:num_of_samples], linewidth = 0.5)
ax1.grid()

signal = signal/(2**DAC_bit_resolution - 1) - 0.5

spectrum = abs(np.fft.fft(signal, n = 1*len(signal), axis = -1))
spectrum/= spectrum.max()
frequ_points = np.linspace(0, 1, len(spectrum)) * f_sampling

ax2.plot(frequ_points, spectrum, linewidth = 0.5)
ax2.set_xlim(0, f_sampling/2)
ax2.grid()
plt.show()

simulated_freq = np.argmax(spectrum) * f_sampling/(len(spectrum)-1)
print('Частота смоделированного сигнала =\t', simulated_freq)

acf = abs(np.correlate(signal, signal, 'full'))
acf /= acf.max()
# acf = 10 * np.log10(acf)
plt.plot(acf, linewidth = 0.5)
plt.grid()
plt.show()


# print(4096*3000000/(13000000000*10/2*13000))
# print(2*3000000/(25390625*10*1625))
# print(4096/13000000000 * (1301500000 - 3000000/(10*)))