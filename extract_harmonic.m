% extracts Nth harmonic from the impulse response
%
% Copyright 2022 - 2024 Teemu Ikonen
%
function [hn, t1, t2] = extract_harmonic(T, f1, f2, Fs, h, N)
  t2 = nthharmonic((N - 1) + 0.5, T, f1, f2) + T;
  t1 = nthharmonic(N + 0.5, T, f1, f2) + T;

  hn = h(round(Fs * t1):round(Fs * t2));
endfunction
