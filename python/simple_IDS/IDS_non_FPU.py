##-----------------------------------------------------------------------------
## Editor: Kudriavcev Anton
## e-mail: Kudiavcev.Anton@yandex.ru
##-----------------------------------------------------------------------------

from matplotlib import pyplot as plt
import numpy as np  

##-----------------------------------------------------------------------------

def phase_accum(step_coef, array_dimention, mult_coef):

	phase_points = []
	phase = 0
	accum = 0

	while phase < array_dimention:

		phase_points.append(phase)

		accum += step_coef
		phase = int(accum / mult_coef)

	phase_points = np.longlong(np.array(phase_points))

	return phase_points

def concantenate_arrays(sin_points, num_of_period):

	array = sin_points

	for i in range(num_of_period - 1):

		sin_points = np.concatenate((sin_points, array), axis=0)

	return sin_points

def result(multiply_spectrum):

	maxx = multiply_spectrum[:int(len(multiply_spectrum)/2):].argmax()
	freq = maxx * (f_sampling/len(multiply_spectrum))
	print('Частота смоделированного выходного сигнала %.5fГц' %freq)

	if freq > f_HF:
		error = abs(f_HF + f_sin - freq)/(f_HF + f_sin) * 100
		print('Требуемая частота выходного сигнала %.3fГц' %(f_HF + f_sin))
	else:
		error = abs(f_HF - f_sin - freq)/(f_HF - f_sin) * 100
		print('Требуемая частота выходного сигнала %.3fГц' %(f_HF - f_sin))

	print('Отклонение требуемого значения относительно расчитанного %.5f процентов' %error)

f_out = 10110

mult_coef = 1024*1

 # set sin signal frequency (Hz)
f_sampling      = int(1e6) # set sampling frequency (Hz)
array_dimention = int(128)
f_HF            = int(1e4) # set high frequency (Hz)

f_sin = f_out - f_HF

 # set sin signal frequency (Hz)

step_coef = int(mult_coef * array_dimention * f_sin / f_sampling) ## the amount of the increment phase 

sin_points = np.sin(np.linspace(0, 2 * np.pi, array_dimention)) # creating an array of sin signal values

sin_phase_points = phase_accum(step_coef, array_dimention, mult_coef)

sin_points = sin_points[sin_phase_points]

num_of_period = 30 # number of period of sin signal using for simulation 

sin_points = concantenate_arrays(sin_points, num_of_period)

num_of_points = int(len(sin_points)) 

time_of_simulation = num_of_points / f_sampling

HF_phase_points = np.linspace(0, time_of_simulation, num_of_points)

noise           = np.random.uniform(-1/(2 * f_sampling), 1/(2 * f_sampling), num_of_points) * 0

HF_points = np.sin(2 * np.pi * f_HF * (HF_phase_points + noise)) # creating an array of intermediate signal values

#-----------------------------------------------------------------------------

fig, (ax1, ax3) = plt.subplots(nrows = 2, ncols = 1)

sin_spectrum = abs(np.fft.fft(sin_points, n = 10 * num_of_points, axis = -1))
frequ_points = np.linspace(0, 1, len(sin_spectrum)) * f_sampling

sin_spectrum /= sin_spectrum.max()
ax1.plot(frequ_points, sin_spectrum)
# ax1.set_xlim(0, f_HF)
ax1.set_title('Приращение фазы = %.3f\nНормированный спектр синусоидального сигнала' %step_coef)
ax1.set_xlabel('Частота, Гц')
ax1.grid()

# interm_spectrum = abs(np.fft.fft(intermediate_points, n = None, axis = -1))
# interm_spectrum /= interm_spectrum.max()
# ax2.stem(frequ_points, interm_spectrum[ : int(len(interm_spectrum)/2):], use_line_collection = True)
# ax2.set_title('Нормированный спектр сигнала гетеродина')
# ax2.set_xlim(0, 1.6e4)
# ax2.set_xlabel('Частота, Гц')
# ax2.grid()

multiply_spectrum = abs(np.fft.fft((sin_points * HF_points), n = 10 * num_of_points, axis = -1))
frequ_points = np.linspace(0, 1, len(multiply_spectrum)) * f_sampling

multiply_spectrum /= multiply_spectrum.max()
ax3.plot(frequ_points, multiply_spectrum)
ax3.set_title('Нормированный спектр синала после переноса')
# ax3.set_xlim(0, 4 * f_HF)
ax3.set_xlabel('Частота, Гц')
ax3.grid()

plt.subplots_adjust(hspace = 0.55)

result(multiply_spectrum)

plt.show()


