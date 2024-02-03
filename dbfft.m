% Computes single-sided dBV/f FFT of x time series with sample frequency of Fs
%
% Copyright 2022 - 2024 Teemu Ikonen
%
function [freq, Xdb] = dbfft(x, Fs)
   [freq, X] = ssfft(x, Fs);
   Xdb = 20*log10(X);
endfunction

