# Pad series with zeroes
function x = padzero(x, l)
   if l > 0
      x = [x zeros(1, l - length(x))];
   else
      x = [zeros(1, abs(l) - length(x)) x];
   endif
endfunction

