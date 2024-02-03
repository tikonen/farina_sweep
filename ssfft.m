
% Computes single-sided FFT of x time series with sample frequency of Fs
%
% Copyright 2022 - 2024 Teemu Ikonen
%
function [freq, X] = ssfft(x, Fs, rms)
   L = length(x);
   X = abs(fft(x)) / L;
   X = X(1:L/2 + 1);
   X(2:end-1) = 2*X(2:end-1);
   freq = Fs*(0:(L/2))/L;
endfunction
