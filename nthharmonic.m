% Computes relative delay of n'th harmonic peak in the impulse response
%
% Copyright 2022 - 2024 Teemu Ikonen
%
function t = nthharmonic(N, T, f1, f2)
  t = -T * log(N) / log(f2/f1);
endfunction
