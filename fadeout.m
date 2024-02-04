% fades out series y starting from time ts within duration of ft. fs is sample rate.
%
% Copyright 2022 - 2024 Teemu Ikonen
%
function y = fadeout(y, ts, ft, fs)

  % fade out filter
  t = [0: 1/fs : ft];
  f = cos(t/ft*pi) * 0.5 + 0.5;

  idx = round(ts*fs);
  length = min(length(f), length(y) - idx);

  % apply filter and clear rest of the data
  y(idx:idx + length - 1) .*= f(1:length);
  y(idx+length:end) = 0;
endfunction

