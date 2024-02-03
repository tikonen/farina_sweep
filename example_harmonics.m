% Demonstrates nth order harmonics spikes in the impulse response
function example_harmonics()

  T = 1; % duration of the sweep
  f1 = 200; % start of sweep
  f2 = 6000; % end of sweep
  fs = 14400; % sample frequency

  % sample rate
  t = [0:1 / fs:T];

  % generate the simulated measured sweep signal and
  % emulate some odd and even harmonics distortion and attenuation. Without
  % distortion only a single impulse peak appears (fundamentals)
  y = sinelog(t, T, f1, f2);
  y = min(.8, max(-.9, y));
  y *= .3;

  L = length(y);

  % add 5% of silence to shift harmonics bit left for easier
  % presentation in plotting.
  tdelta = T * .1;
  y = padzero(y, (round(fs * tdelta) + L));

  % generate inverse filter
  f = isinelog(t, T, f1, f2);

  % pad also inverse filter to match the data
  f = padzero(f, (round(fs * tdelta) + L));

  % Deconvolution
  h = real((ifft(fft(y).*fft(f))));

  % Plotting the impulse response
  plot(linspace(-T, tdelta, length(h)), h);
  title("Impulse response");
  xlabel("t(s)")
  % y axis is unitless
  ylim([-20 40]);

  % mark place of main, nth order harmonics
  h1 = nthharmonic(1, T, f1, f2);
  h2 = nthharmonic(2, T, f1, f2);
  h3 = nthharmonic(3, T, f1, f2);
  h4 = nthharmonic(4, T, f1, f2);
  h5 = nthharmonic(5, T, f1, f2);

  text(h1, 10, "1st (main)");
  text(h2, 5, "2nd");
  text(h3, 5, "3rd");
  text(h4, 5, "4th");
  text(h5, 5, "5th");

endfunction

