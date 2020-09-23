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

def create_probability_distribution(probability_density):

    probability_distribution = np.zeros(len(probability_density))

    for i in range(len(probability_density)):

        probability_distribution[i] = sum(probability_density[0 : i + 1])

    return probability_distribution



##-----------------------------------------------------------------------------

def create_uniform_values(minn, maxx, num_of_variables):

    m   = 18
    l   = 13
    z   = [189601]
    u   = 1023  

    for i in range(num_of_variables - 1):
        z_next = ((l * z[i]) & (2**m - 1))
        z.append(z_next + 1)



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

    return experimental_prob_density

##-----------------------------------------------------------------------------

def dig_to_analog_convertor(DAC_output_voltage, DAC_bit_resolution, digital_values):

    output_values = (digital_values/(2**DAC_bit_resolution - 1) * DAC_output_voltage) - (DAC_output_voltage/2)

    return output_values

##-----------------------------------------------------------------------------

def create_ACF(data):

    acf = np.correlate(data, data, 'full')

    return acf

##-----------------------------------------------------------------------------

DAC_bit_resolution = 12
DAC_output_voltage = 3.3

N = 2**DAC_bit_resolution ## количество дискретных случайных величин
disc_rnd_values = np.linspace(0, N - 1, N) ## все возможные дискретные случайные велинчины

m = N/2 - 1 ## матожидание 
sigma = m/3 ## зададим матожидание как величину в 3 сигмы

mult_coef = 264933.3 ## коэффициент для перевода плотности внероятности в область целых чисел

##-----------------------------------------------------------------------------

probability_density = 1/(np.sqrt(2*np.pi) * sigma) * np.exp(-((disc_rnd_values - m)**2) / (2 * sigma**2)) ## гауссовская плотность распределения вероятности

# plotter(probability_density, 'Гауссовская плотность распр. вер-ти', 1, 0)

probability_density = np.longlong(mult_coef * probability_density)

# plotter(probability_density, 'Гауссовская плотность распр. вер-ти\nпереведенная в область целых чисел', 2, 0)

print('Площадь под функцией полотности вероятности = ', sum(probability_density))

uniform_rnd_values = create_uniform_values(1, sum(probability_density), 10000)
print(min(uniform_rnd_values))
print(max(uniform_rnd_values))
# plotter(uniform_rnd_values, 'Сл. величины, распр. равномерно', 3, 0)

gauss_values = np.array(uniform_to_gauss_convertor(uniform_rnd_values, probability_density), dtype = 'longlong' )
plotter(gauss_values, 'Сл. величины, распр. нормально', 4, 0)

experimental_prob_density = creare_probability_density(disc_rnd_values, gauss_values)
plotter(experimental_prob_density, 'Экспериментальная плотность распределения', 5, 0)


output_signal = dig_to_analog_convertor(DAC_output_voltage, DAC_bit_resolution, gauss_values)
plotter(output_signal, 'Выходное напряжение', 6, 0)

acf = create_ACF(output_signal)
plotter(acf, 'Автокорреляционная функция', 7, 1)
