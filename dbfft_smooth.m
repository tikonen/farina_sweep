% Computes single-sided dBV/f FFT of time series x with sample frequency of Fs.
% with 1/Nth octave averaging. Return Renard 40 frequencies up to Fs.
%
% Copyright 2022 - 2024 Teemu Ikonen
%
function [freq, Xdb] = dbfft_smooth(x, Fs, N)
  L = length(x);
  [_, X] = ssfft(x, Fs);

  hFs = round(Fs/2);

  source renard.m
  freqs = generate_r40(hFs);

  % Compute averages for the renard frequencies
  for i=1:length(freqs)
    % get index of the matching frequency bin
    k = max(1, round(freqs(i) / Fs * L));

    a = round(k * 2^(-1/(2*N)));
    a = max(1, a);
    b = round(k * 2^(1/(2*N)));
    b = min(b, length(X));
    acc = 0;
    for j=a:b
      acc += X(j);
    endfor
    val = acc/(b - a + 1);
    Xpow(i) = val;
  endfor

  Xdb = 20*log10(Xpow); % dB

  freq = freqs;
endfunction
