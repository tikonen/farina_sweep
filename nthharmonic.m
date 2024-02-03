% Computes relative delay of distortions n'th harmonic in log sine impulse response
function t = nthharmonic(N, T, f1, f2)
  t = -T * log(N) / log(f2/f1);
endfunction
