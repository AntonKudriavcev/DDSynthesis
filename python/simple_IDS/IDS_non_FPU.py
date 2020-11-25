##-----------------------------------------------------------------------------
## Editor: Kudriavcev Anton
## e-mail: Kudiavcev.Anton@yandex.ru
##-----------------------------------------------------------------------------

from matplotlib import pyplot as plt
import numpy as np  

##-----------------------------------------------------------------------------

def phase_accum(step_coef, num_of_points, mult_coef):

    phase_points = [0]
    phase = 0
    accum = 0

    for i in range(num_of_points - 1):

        accum += step_coef
        phase = int(accum / mult_coef) % (128)
        phase_points.append(phase)

    phase_points = np.array(phase_points)

    return phase_points


def result(spectrum):

    maxx = spectrum[:int(len(spectrum)/2):].argmax()
    freq = maxx * (f_sampling/len(spectrum))
    print('Частота смоделированного выходного сигнала %.5fГц' %freq)

    print('Требуемая частота выходного сигнала %.3fГц' %(f_sin))

    error = abs(f_sin - freq)/f_sin * 100
    print('Отклонение требуемого значения относительно расчитанного %.5f процентов' %error)
    

f_sin = 10110

mult_coef = 1024

 # set sin signal frequency (Hz)
f_sampling      = int(1e6) # set sampling frequency (Hz)
array_dimention = int(128)

time_of_simulation = 10e-3

num_of_points = int(time_of_simulation * f_sampling)

##-----------------------------------------------------------------------------

step_coef = int(mult_coef * array_dimention * f_sin / f_sampling) ## the amount of the increment phase 
print(step_coef)

sin_points = np.sin(np.linspace(0, 2 * np.pi, array_dimention)) # creating an array of sin signal values

sin_phase_points = phase_accum(step_coef, num_of_points, mult_coef)

sin_points = sin_points[sin_phase_points]

#-----------------------------------------------------------------------------

fig, (ax1) = plt.subplots(nrows = 1, ncols = 1)

sin_spectrum = abs(np.fft.fft(sin_points, n = 10 * num_of_points, axis = -1))
frequ_points = np.linspace(0, 1, len(sin_spectrum)) * f_sampling

sin_spectrum /= sin_spectrum.max()
ax1.plot(frequ_points, sin_spectrum)
ax1.set_xlim(f_sin - 8000, f_sin + 8000)
ax1.set_title('Приращение фазы = %.3f\nНормированный спектр синусоидального сигнала' %step_coef)
ax1.set_xlabel('Частота, Гц')
ax1.grid()

result(sin_spectrum)

plt.show()


