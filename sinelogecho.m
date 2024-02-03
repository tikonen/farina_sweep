% Computes logaritmic sine sweeps echo. T is total time (s), f1 and f2 are start end frequency (Hz).
% t are the timesteps. f3 is frequency where echo is assumed to be fully absorbed by environment.
% delay is delay of the echo in seconds.
%
% Copyright 2022 - 2024 Teemu Ikonen
%
function ret = sinelogecho(t, T, f1, f2, f3, delay, a)
   % Attenuation formula a = is 1-(f/f3).^3;
   y = a * echo(f1*(exp(log(f2/f1)*t/T)), f3) .* sin(2*pi*f1*T/log(f2/f1)*(exp(log(f2/f1)*t/T)-1));
   Fs = length(t)/T; % samplerate
   s = round(Fs * delay); % shift in samples
   y(end-s:end) = 0;
   ret = shift(y, s);
endfunction

% Returns echo strength at the frequency f up to limit frequency (where it tapers to 0)
function a = echo(f, flimit)
  a = max(0, 1 - (f/flimit) .^ 3);
endfunction
