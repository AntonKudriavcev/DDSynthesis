%------------------------------------------------------------------------------
% Editor: Kudriavcev Anton
% e-mail: Kudiavcev.Anton@yandex.ru
%------------------------------------------------------------------------------
clear all;
%-user variable----------------------------------------------------------------

f_carrier   = 1.3e9; % Hz
f_sampling  = 26e9;  % Hz

bit_depth = 12;
mult_coef = 16384;
array_dimention  = 2^bit_depth;

DAC_bit_resolution = 12;

%-user param---------------

f_deviation  = 3e6;    % Hz
t_impulse    = 60e-6; % sec
t_repetition = 400e-6;
num_of_impulse = 5;

vobulation_array = zeros(1,num_of_impulse - 1);

for i = 1:1:(num_of_impulse - 1)
    vobulation_array(i) = t_repetition + (t_repetition * rand());
end

vobulation_array

%-auxiliary variables----------------------------------------------------------

t_disc = 1/f_sampling;

num_of_sin_points  = (round(t_impulse/t_disc));

f_max = f_carrier + (f_deviation/2);
f_min = f_carrier - (f_deviation/2);

%-sin points generator---------------------------------------------------------

sin_points = int32((sin(0:(2*pi/array_dimention):2*pi) + 1)/2 * (2^DAC_bit_resolution - 1));

sin_phase_points = phase_accum(num_of_sin_points, array_dimention, mult_coef, f_sampling, t_disc, f_max, f_min, t_impulse);

sin_points = sin_points(sin_phase_points);

%-zero points generator--------------------------------------------------------

num_of_zero_points = zeros(1, num_of_impulse - 1);

for i = 1:1:(num_of_impulse - 1)
     num_of_zero_points(i) = round((vobulation_array(i) - t_impulse)/t_disc);
end

%-output signal generator------------------------------------------------------

output_signal = collect_a_packet(num_of_impulse, sin_points, num_of_zero_points, DAC_bit_resolution);

%------------------------------------------------------------------------------

% plotting output signal
figure(1);
time_of_simulation = (num_of_impulse * t_impulse) + ((num_of_impulse - 1) * (t_repetition - t_impulse));
time_points = 0:time_of_simulation/(length(output_signal) - 1):time_of_simulation;

plot(time_points, output_signal);
title('ADC output signal');
ylim([-500, 2^DAC_bit_resolution + 500]);
xlabel('Time, sec');
ylabel('ADC discharge number');
grid on;

% % plotting spectrum
% figure(2);
% spectrum = abs(fft(output_signal));
% spectrum = spectrum/max(spectrum);
% frequ_points = 0:f_sampling/(length(spectrum) - 1):f_sampling;
% 
% plot(frequ_points, spectrum);
% title('Spectrum');
% xlim([f_carrier - 2*f_deviation, f_carrier + 2*f_deviation]);
% ylim([0, max(spectrum)/15]);
% xlabel('Frequency, Hz');
% grid on;
% 
% % plotting spectrum borders
% hold on;
% plot([f_min f_min],[0 1]);
% 
% hold on;
% plot([f_max f_max],[0 1]);
%------------------------------------------------------------------------------



