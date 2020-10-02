##-----------------------------------------------------------------------------
## Editor: Kudriavcev Anton
## e-mail: Kudiavcev.Anton@yandex.ru
##-----------------------------------------------------------------------------

import numpy as np
from scipy import signal
from matplotlib import pyplot as plt


##-----------------------------------------------------------------------------

def plotter(values, title, figure_num, show):
    plt.figure(figure_num)
    plt.plot(values)
    plt.grid()
    plt.title(title)
    if show:
        plt.show()

##-----------------------------------------------------------------------------

def convert_to_avg_prob_density(probability_density, step):

    average_probability_density = []

    for i in range(0, len(probability_density), step):
        average_probability_density.append(sum(probability_density[i:i + step])/step)

    average_probability_density = np.array(average_probability_density)

    return average_probability_density

##-----------------------------------------------------------------------------

def create_probability_distribution(probability_density):

    probability_distribution = np.zeros(len(probability_density))

    for i in range(len(probability_density)):

        probability_distribution[i] = sum(probability_density[0 : i + 1])

    return probability_distribution

##-----------------------------------------------------------------------------

## генерирование равномено распр. num_of_variables сл. величин в интервале от minn до maxx

def create_average_uniform_values(minn, maxx, num_of_variables):

    m  = int(np.log2(maxx))
    l  = 31
    z  = []
    u  = 1

    bit_deph = 32
    z_curr = int(2**(m - 2))

    for i in range(num_of_variables):
        z_next = ((l * z_curr + u) & (2**bit_deph - 1))

        # z.append((z_next >> m) & (2**m - 1) + 1)

        z.append(((z_next >> (bit_deph - m)) & (2**m - 1) ) + minn)
        z_curr = z_next

    # X = np.random.randint(minn, maxx, num_of_variables)

    return z

##-----------------------------------------------------------------------------

def uniform_to_gauss_convertor(uniform_rnd_values, probability_density):

    counter = 0
    probability_interval_num = []

    for rnd_num in uniform_rnd_values:
        for i in range(len(probability_density)):
            counter += probability_density[i]
            if rnd_num <= counter:
                probability_interval_num.append(i)
                counter = 0
                break

    return probability_interval_num

##-----------------------------------------------------------------------------

def creare_probability_density(disc_rnd_values, gauss_values):

    experimental_prob_density   = []
    num_of_points  = 0

    for value in disc_rnd_values:
        for z in gauss_values:
            if z == value:
                num_of_points += 1

        experimental_prob_density.append(num_of_points)
        num_of_points = 0

    experimental_prob_density = np.array(experimental_prob_density)

    return experimental_prob_density

##-----------------------------------------------------------------------------

def expand_values(avg_gauss_values, step):

    m = int(np.log2(step))
    l = 31
    u = 1

    bit_deph = 31
    z_curr   = int(2**(m - 2))

    expanded_values = []

    for value in avg_gauss_values:

        z_next = ((l * z_curr + u) & (2**bit_deph - 1))
        step_rnd_value = ((z_next >> (bit_deph - m)) & (2**m - 1))
        expanded_values.append(step * value + step_rnd_value)

        z_curr = z_next

    expanded_values = np.array(expanded_values)

    return expanded_values

##-----------------------------------------------------------------------------

def dig_to_analog_convertor(DAC_output_voltage, DAC_bit_resolution, digital_values):

    output_values = (digital_values/(2**DAC_bit_resolution - 1) * DAC_output_voltage) - (DAC_output_voltage/2)

    return output_values

##-----------------------------------------------------------------------------

def create_ACF(data):

    acf = np.correlate(data, data, 'full')
    # acf/= max(acf) 

    return acf

##-----------------------------------------------------------------------------

DAC_bit_resolution = 12
DAC_output_voltage = 3.3

N = 2**DAC_bit_resolution ## количество дискретных случайных величин
disc_rnd_values = np.linspace(0, N - 1, N) ## все возможные дискретные случайные велинчины

m = N/2 - 1 ## матожидание 
sigma = m/3 ## зададим матожидание как величину в 3 сигмы

mult_coef = 264975 ## коэффициент для перевода плотности внероятности в область целых чисел !!!ПОДБИРАТЬ ДЛЯ КАЖДОГО step!!!

step = 16

avg_disc_rnd_values = np.linspace(0, int((N/step - 1)), int(N/step))

##-----------------------------------------------------------------------------

probability_density = 1/(np.sqrt(2*np.pi) * sigma) * np.exp(-((disc_rnd_values - m)**2)/(2 * sigma**2)) ## гауссовская плотность распределения вероятности

average_probability_density = convert_to_avg_prob_density(probability_density, step) ## "сжатие" исходной ГПР с учетом шага усреднения

# plotter(probability_density, 'Гауссовская плотность распр. вер-ти', 1, show = 0)
# plotter(average_probability_density, 'Усредненная гауссовская плотность распр. вер-ти', 2, show = 0)

probability_density         = np.longlong(mult_coef * probability_density)         ## перевод ПРВ в область целых чисел путем умножения на mult_coef и отбрасывания дробной части
average_probability_density = np.longlong(mult_coef * average_probability_density) ## перевод усредненной ПРВ в область целых чисел путем умножения на mult_coef и отбрасывания дробной части

scaling_coef = np.longlong(np.linspace(0, len(probability_density) - 1, len(probability_density))/len(probability_density) * len(average_probability_density)) ## коэффициент для масштабирования усредненной ПРВ в область исходных случайных чисел 

# plotter(probability_density, 'Гауссовская плотность распр. вер-ти\nпереведенная в область целых чисел', 3, show = 0)
plotter(average_probability_density[scaling_coef], 'Усредненная гауссовская плотность распр. вер-ти\nпереведенная в область целых чисел', 4, show = 0)

# print('Площадь под функцией полотности вероятности = ',             sum(probability_density))
print('Площадь под усредненной функцией полотности вероятности = ', sum(average_probability_density))

uniform_rnd_values = create_average_uniform_values(1, sum(average_probability_density), 100000) ## генерирование массива равном. распр. сл.величин от 1 до sum(average_probability_density)
# plotter(uniform_rnd_values, 'Сл. величины, распр. равномерно', 5, show = 0)

avg_gauss_values = np.array(uniform_to_gauss_convertor(uniform_rnd_values, average_probability_density), dtype = 'longlong' ) ## преобразование равнорм. сл.в в норм. распр сл.в
# plotter(avg_gauss_values, 'Усредненные сл. величины, распр. нормально', 6, show = 0)

# avg_experimental_prob_density = creare_probability_density(avg_disc_rnd_values, avg_gauss_values) ## нахождение экспериментальной ПРВ для усредненной ПРВ
# plotter(avg_experimental_prob_density[scaling_coef], 'Усредненная экспериментальная плотность распределения', 7, show = 0)

non_avg_gauss_values = expand_values(avg_gauss_values, step) ## ре-усреднение усредненных значений в исходным 
# plotter(non_avg_gauss_values, 'Неусредненные сл. величины, распр. нормально', 8, show = 1)

# experimental_prob_density = creare_probability_density(disc_rnd_values, non_avg_gauss_values)
# plotter(experimental_prob_density, 'Неусредненная экспериментальная плотность распределения', 9, show = 1)

output_signal = dig_to_analog_convertor(DAC_output_voltage, DAC_bit_resolution, non_avg_gauss_values) ## перевод дискр значений к "аналоговым"
plotter(output_signal, 'Выходное напряжение', 10, 0)

acf = create_ACF(non_avg_gauss_values) ## нахождение АКФ
plotter(acf, 'Автокорреляционная функция', 11, 1)

# spectrum = abs(np.fft.fft(output_signal))
# plotter(spectrum, 'Спектр сигнала', 12, 1)