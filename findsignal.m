% Find start position of signal needle from the signal haystack.
% Useful for finding a e.g. 1kHz pilot signal from the recorded sample.
%
% Copyright 2022 - 2024 Teemu Ikonen
%
function pos = findsignal(haystack, needle)
  % Compute cross correlation and return position in haystack where it
  % reaches peak.
  [x, lags] = xcorr(haystack, needle);
  x = abs(x);
  A = sum(x);
  z = (0:length(x)-1);
  d = round(1/A * sum(z .* x)); % center of mass for x-coordinate
  pos = lags(d);
endfunction

