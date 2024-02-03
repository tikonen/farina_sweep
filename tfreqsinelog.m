% calculates the time when sweep defined by parameters T, f1 and f2 has an instaneous frequency f
function ret = tfreqsinelog(f, T, f1, f2)
   R = log(f2/f1);
   ret = T/R*log(f/f1);
endfunction
