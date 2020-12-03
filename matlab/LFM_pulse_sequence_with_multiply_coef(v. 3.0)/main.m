%------------------------------------------------------------------------------
% Editor: Kudriavcev Anton
% e-mail: Kudiavcev.Anton@yandex.ru
%------------------------------------------------------------------------------
clear all;
%-user variable----------------------------------------------------------------

f_carrier   = 1.3e9; % Hz
f_sampling  = 13e9;  % Hz

bit_depth = 12;
mult_coef = 16384;
array_dimention  = 2^bit_depth;

DAC_bit_resolution = 12;
DAC_output_voltage = 3.3; 

%-user param---------------

f_deviation  = 3e6*1;    % Hz
t_impulse    = 60e-6; % sec
t_repetition = 360e-6;
num_of_impulse = 1;

vobulation_array = zeros(1,num_of_impulse - 1);

for i = 1:1:(num_of_impulse - 1)
    vobulation_array(i) = t_repetition + (t_repetition * rand()*0);
end

vobulation_array

%-auxiliary variables----------------------------------------------------------

t_disc = 1/f_sampling;

num_of_sin_points  = (round(t_impulse/t_disc));

f_max = f_carrier + (f_deviation/2);
f_min = f_carrier - (f_deviation/2);

freq_max_div = floor((array_dimention * f_max)/ f_sampling);
freq_max_mod = mod((array_dimention * f_max), f_sampling);

dlt_step_denom = t_impulse/2 * f_sampling * f_sampling;
dlt_freq_div   = floor((array_dimention * (f_deviation))/dlt_step_denom);
dlt_freq_mod   = mod((array_dimention * (f_deviation)),dlt_step_denom);


%-sin points generator---------------------------------------------------------

sin_points = floor((sin(0:(2*pi/(array_dimention - 1)):2*pi) + 1)/2 * (2^DAC_bit_resolution - 1));

sin_phase_points = phase_accum(num_of_sin_points, array_dimention, f_sampling, t_disc, f_max, f_min, t_impulse,... 
                               freq_max_div, freq_max_mod, dlt_freq_div, dlt_freq_mod, dlt_step_denom);

sin_points = sin_points(sin_phase_points);

%-zero points generator--------------------------------------------------------

num_of_zero_points = zeros(1, num_of_impulse - 1);

for i = 1:1:(num_of_impulse - 1)
     num_of_zero_points(i) = round((vobulation_array(i) - t_impulse)/t_disc);
end

%-output signal generator------------------------------------------------------

DAC_input_signal = collect_a_packet(num_of_impulse, sin_points, num_of_zero_points, DAC_bit_resolution);
output_signal = output_signal_conv(DAC_input_signal, DAC_bit_resolution, DAC_output_voltage);

%------------------------------------------------------------------------------

% plotting DAC input signal
figure(1);
time_of_simulation = (num_of_impulse * t_impulse) + ((num_of_impulse - 1) * (t_repetition - t_impulse));

time_points = (0:1:length(DAC_input_signal) - 1) * time_of_simulation/length(DAC_input_signal);

plot(time_points, DAC_input_signal);
ylim([-500, 2^DAC_bit_resolution + 500]);
title('DAC input signal');
xlabel('Time, sec');
ylabel('DAC discharge number');
grid on;

% plotting output signal
figure(2);

plot(time_points, output_signal);
ylim([-DAC_output_voltage, DAC_output_voltage]);
title('Output signal');
xlabel('Time, sec');
ylabel('Voltage');
grid on;

% plotting spectrum
figure(3);
spectrum = abs(fft(output_signal));
spectrum = spectrum/max(spectrum);
frequ_points = (0:1:length(spectrum) - 1) * f_sampling/length(spectrum);

plot(frequ_points, spectrum);
xlim([f_carrier - 2*f_deviation - 100, f_carrier + 2*f_deviation + 100]);
% xlim([0, f_sampling/2])
ylim([0, max(spectrum)*1.5]);
title('Spectrum');
xlabel('Frequency, Hz');
grid on;

% plotting spectrum borders
hold on;
plot([f_min f_min],[0 1]);

hold on;
plot([f_max f_max],[0 1]);

% plotting ACF
figure(4);
acf = abs((xcorr(output_signal)));
acf = acf/max(acf);
tau = -time_of_simulation:2*time_of_simulation/(length(acf) - 1):time_of_simulation;
plot(tau, acf);
xlim([-time_of_simulation, time_of_simulation])
ylim([1.2 * min(acf), 1.2 * max(acf)]);
title('ACF');
xlabel('tau, sec');
ylabel('R(tau)');
grid on;

%------------------------------------------------------------------------------