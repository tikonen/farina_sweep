% Pad vector with zeroes up to length l. If l is negative the
% vector is left padded.
%
% Copyright 2022 - 2024 Teemu Ikonen
%
function x = padzero(x, l)
   if l > 0
      x = [x zeros(1, l - length(x))];
   else
      x = [zeros(1, abs(l) - length(x)) x];
   endif
endfunction

