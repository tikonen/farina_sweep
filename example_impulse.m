% Demonstrates sweeps impulse response
%
% Copyright 2022 - 2024 Teemu Ikonen
%
function example_impulse()

  T = 1; % duration of the sweep
  f1 = 200; % start of sweep
  f2 = 6000; % end of sweep
  fs = 24800; % sample frequency

  % sample rate
  t = [0:1 / fs:T];

  % generate the sweep signal
  y = sinelog(t, T, f1, f2);

  L = length(y);

  % add 5% of silence to shift harmonics bit left for easier
  % presentation in plotting.
  tdelta = T * .1;
  y = padzero(y, (round(fs * tdelta) + L));

  % generate inverse filter
  f = isinelog(t, T, f1, f2);

  % pad also inverse filter to match the data
  f = padzero(f, (round(fs * tdelta) + L));

  t = [0: 1/fs: T + tdelta];
  figure
  plot(t, y);
  title("Sweep signal");
  figure
  plot(t, f);
  title("Inverse filter");

  % Deconvolution
  h = real((ifft(fft(y).*fft(f))));

  % Plotting the impulse response
  figure
  plot(linspace(-T, tdelta, length(h)), h);
  title("Impulse response");
  xlabel("t (s)")
  % y axis is unitless

endfunction

