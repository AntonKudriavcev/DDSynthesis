
x = randn(100000,1) + j * randn(100000,1);

plot(abs(fft(real(x))))