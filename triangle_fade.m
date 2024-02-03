% Triangle window function
%
% Copyright 2022 - 2024 Teemu Ikonen
%
function w = triangle_fade(r, n)
  n1 = round(r * n);
  n2 = n - n1;
  w = [linspace(0, 1, n1) linspace(1, 0, n2 + 1)(2 : end)];
endfunction
