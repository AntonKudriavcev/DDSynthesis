%------------------------------------------------------------------------------
% Editor: Kudriavcev Anton
% e-mail: Kudiavcev.Anton@yandex.ru
%------------------------------------------------------------------------------
clear all;
%------------------------------------------------------------------------------

DAC_bit_resolution = 12;
DAC_output_voltage = 3.3;

N = 2^DAC_bit_resolution; %% количество дискретных случайных величин
disc_rnd_values = 0:1:N-1; %% все возможные дискретные случайные велинчины

m = N/2; %% матожидание 
sigma = m/3; %% зададим матожидание как величину в 3 сигмы

step = 16;
mult_coef = 264980; %% коэффициент для перевода плотности вероятности в область целых чисел !!!ПОДБИРАТЬ ДЛЯ КАЖДОГО step!!!

avg_disc_rnd_values = 0:1:round(N/step - 1);

num_of_simulation_points = 100000;

%------------------------------------------------------------------------------

probability_density = 1/(sqrt(2*pi) * sigma) * exp(-((disc_rnd_values - m).^2)/(2 * sigma^2)); %% гауссовская плотность распределения вероятности
average_probability_density = convert_to_avg_prob_density(probability_density, step);          %% "сжатие" исходной ГПРВ с учетом шага усреднения

% plotter(disc_rnd_values, probability_density, 'Гауссовская плотность распр. вер-ти', 1);
% plotter(avg_disc_rnd_values, average_probability_density, 'Усредненная гауссовская плотность распр. вер-ти', 2);

probability_density = floor(mult_coef * probability_density); %% перевод ПРВ в область целых чисел путем умножения 
                                                              % на mult_coef и отбрасывания дробной части
                                                                            
average_probability_density = floor(mult_coef * average_probability_density); %% перевод усредненной ПРВ в область целых чисел путем
                                                                              % умножения на mult_coef и отбрасывания дробной части                                                                         
scaling_coef = 1:1:N;
scaling_coef = ceil(scaling_coef/step);
% plotter(disc_rnd_values, average_probability_density(scaling_coef), 'Усредненная гауссовская плотность распр. вер-ти переведенная в область целых чисел', 3);

sum(average_probability_density)

uniform_rnd_values = create_average_uniform_values(1, sum(average_probability_density), num_of_simulation_points); % генерирование массива равном. распр. сл.величин от 1 до sum(average_probability_density)
% plotter(1:1:num_of_simulation_points, uniform_rnd_values, 'Сл. величины, распр. равномерно', 4)

avg_gauss_values = uniform_to_gauss_convertor(uniform_rnd_values, average_probability_density, num_of_simulation_points); % преобразование равнорм. сл.в в норм. распр сл.в
% plotter(1:1:num_of_simulation_points, avg_gauss_values, 'Усредненные сл. величины, распр. нормально', 5);

non_avg_gauss_values = expand_values(avg_gauss_values, step, num_of_simulation_points); % ре-усреднение усредненных значений к исходным 
plotter(1:1:num_of_simulation_points, non_avg_gauss_values, 'Неусредненные сл. величины, распр. нормально', 6)

output_signal = dig_to_analog_convertor(DAC_output_voltage, DAC_bit_resolution, non_avg_gauss_values); % перевод дискр значений к "аналоговым"
plotter(1:1:num_of_simulation_points, output_signal, 'Выходное напряжение', 7)

[ACF, tau] = xcorr(output_signal,output_signal);
ACF = abs(ACF)/(max(ACF));
plotter(tau, 10*log10(ACF), 'Автокорреляционная функция', 8);

uniform_rnd_values = uniform_rnd_values/max(uniform_rnd_values) - 0.5;

% [ACF, tau] = xcorr(uniform_rnd_values,uniform_rnd_values);
% ACF = abs(ACF)/(max(ACF));
% plotter(tau, 10*log10(ACF), 'Автокорреляционная функция равном', 9);

figure (10);
histogram(non_avg_gauss_values);

spectrum = abs(fft(output_signal));
plotter(1:1:length(spectrum)/2, spectrum(1:1:end/2), 'Спектр', 10);
