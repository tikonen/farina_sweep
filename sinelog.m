
% Computes logaritmic sine sweep. T is total time (s), f1 and f2 are start end frequency (Hz).
% t is vector of timesteps.
%
% Copyright 2022 - 2024 Teemu Ikonen
%
function ret = sinelog(t, T, f1, f2)
   R = log(f2/f1);
   ret = sin(2*pi*f1*T/R*(exp(R*t/T)-1));
endfunction
