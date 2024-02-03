% Inverse filter of the sinelog
function x = isinelog(t, T, f1, f2)
  x = sinelog(t, T, f1, f2);
  x = flip(x)./exp(t/T*log(f2/f1));
endfunction
