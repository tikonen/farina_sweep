% Computes single-sided dBv/f FFT of time series x with sample frequency of Fs.
% with 1/Nth octave averaging. Return Renard 40 frequencies up to Fs.
% Before smoothing spectrum is remapped by n.
%
% Copyright 2022 - 2024 Teemu Ikonen
%
function [freq, Xdb] = dbfft_smooth_shift(x, Fs, N, n)
  L = length(x);
  [_, X] = ssfft(x, Fs);

  % remap frequncies
  for i=1:floor(length(X)/n)
    X(i) = X(i*n);
  endfor
  % Set rest to zero as there are no higher frequencies
  X(ceil(length(X)/n):end) = 0;

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

