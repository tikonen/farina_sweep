% Calculates the time when sweep defined by parameters T, f1 and f2 has an instaneous frequency f
%
% Copyright 2022 - 2024 Teemu Ikonen
%
function t = tfreqsinelog(f, T, f1, f2)
   R = log(f2/f1);
   t = T/R*log(f/f1);
endfunction
