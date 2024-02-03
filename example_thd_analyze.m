% Analyze sweep from frequency f1 to f2 in time T seconds.
%
% Copyright 2022 - 2024 Teemu Ikonen
%
function example_thd_analyze(T, f1, f2, fs)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Generate simulated measure signal by distoring the sweep signal
  t = [0: 1/fs: T];
  y = sinelog(t, T, f1, f2);
  % emulate some harmonics distortion and attenuation in measurement. These harmonics give ~6.4% THD
  % THD = sqrt( 0.05^2 + 0.01^2 + 0.005^2 ) / 0.8 = ~0.064
  y = 0.8*y + 0.05*sinelog(t, T, f1*2, f2*2) + 0.01*sinelog(t, T, f1*3, f2*3) + 0.005*sinelog(t, T, f1*4, f2*4);
  L = length(y);

  % IMPORTANT
  % Deconvolution removes all frequencies beyond end of the sweep frequency f2.
  % Effect of higher frequencies in the harmonics disappear. The sweep (and it's inverse) must go further to higher
  % frequencies to capture ever more higher frequency harmonics. Also sample rate must be high enough!
  %
  % For example let end of sweep f2 = 6000Hz and sample rate fs >= 12000Hz.
  % The 2nd order harmonics end in 3000Hz, 3rd order 2000Hz and so on. Increasing sample
  % rate has no effect as deconvolution filter removes all frequencies above 6000Hz.
  %
  % However this is not an major issue with audio when sweep ends at 20kHz because
  % human ear can't really hear harmonics above that frequency. For example 2nd harmonics
  % beyond 10kHz fundamental cannot be heard, 3rd harmonics beyond 6.7kHz and so on.
  %
  % If you want to analyze 2nd harmonics up to e.g. 6000Hz you must generate the sweep up to 12000Hz (and use
  % 24000Hz sample rate). If you want to analyze 3rd harmonics up to 6000Hz the sweep must be generated up
  % to 3*6000 = 18000Hz and sample rate must be naturally twice that, 36000Hz. And so on.

  % You only need to play the sweep signal up to fundamental end frequency (6000Hz in this example)
  % when doing e.g. speaker or a mic test. Use function tfreqsinelog() to figure out when to stop. Another way
  % would be to low pass filter the sweep signal before playing it. The recording has to be full length.
  % to match the filter length.
  %
  % e.g. To analyze up to 6000hz a 1 second long sweep generated to 18000,
  % the playback can be stopped at 0.7559s.
  % >> tfreqsinelog(6000, 1, 200, 18000)
  % ans = 0.7559
  %

  %[freq, Ydb] = dbfft_smooth(y, fs, 8);
  %plot(freq, Ydb);
  %set(gca, "xscale", "log");
  %return

  % add some margin for nicer plotting
  tdelta = T * .2;

  y = padzero(y, (round(fs * tdelta) + L));

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Deconvolution

  % generate inverse filter and apply it to the data
  f = isinelog(t, T, f1, f2);

  f = padzero(f, (round(fs * tdelta) + L));
  %t = [0: 1/fs: T + tdelta];


  % Plot signal and inverse filter
  %[freq, Fdb] = dbfft_smooth(f, fs, 8);
  %plot(freq, Fdb);
  %hold on;
  %[freq, Ydb] = dbfft_smooth(y, fs, 8);
  %plot(freq, Ydb);
  %set(gca, "xscale", "log");
  %return;

  % Compute impulse response
  H = fft(y) .* fft(f);
  H(1) = 0; % No DC
  h = real( ifft(H) );

  % Note that dB magnitude depends on the sample rate and amplitude. If you want
  % sample rate independent level normalize the impulse response.
  %[freq, Hdb] = dbfft_smooth(h/max(h), fs, 12);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Plot impulse response
  figure;
  plot(linspace(-T, tdelta, length(h)), h);
  title("Impulse response");
  grid on;
  % Mark few first harmonics
  hr = nthharmonic(2, T, f1, f2);
  line([hr hr], [-30 0]);
  hr = nthharmonic(3, T, f1, f2);
  line([hr hr], [-30 0]);
  hr = nthharmonic(4, T, f1, f2);
  line([hr hr], [-30 0]);
  axis([-T tdelta -50 100]);
  xlabel("t (s)");
  grid on;

  dbTicks = [-100: 10: 110];
  dbScale = [f1/2 fs -80 +3];

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Plot frequency response of full impulse
  [freq, Hdb] = dbfft_smooth(h, fs, 12);
  figure;
  plot(freq, Hdb);
  title('Impulse response');
  xlabel("Hz")
  ylabel("dB");
  axis(dbScale);
  set(gca, "xscale", "log");
  yticks(dbTicks);
  grid on;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Main impulse
  cut = nthharmonic(1.05, T, f1, f2) + T;
  cutn = round(cut * fs);
  hfundamental = h(cutn : end);
  hfundamental *= length(hfundamental)/length(h); % scale impulse amplitude to match length
  %audiowrite('main_impulse.wav', hfundamental, fs);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Plot frequency response of the main impulse
  [freq, Hfdb] = dbfft_smooth(hfundamental, fs, 12);
  figure;
  plot(freq, Hfdb, 'DisplayName', 'Main');
  title("Frequency response");
  xlabel("Hz")
  ylabel("dB");
  axis(dbScale);
  set(gca, "xscale", "log");
  yticks(dbTicks);
  grid on;
  hold on;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Plot frequency response of 3 first harmonic impulses
  for i=2:4
    %figure
    [hi, t1, t2] = extract_harmonic(T, f1, f2, fs, h, i);
    % debug extraction
    %printf('Harmonic %d (%f, %f)\n', i, t1 - T, t2 - T);
    %plot(linspace(t1 - T, t2 - T, length(hi)), hi);

    hi *= length(hi)/length(h);
    % Harmonic is shifted in frequency so that it can be mapped on to the original
    % fundamental.
    [freq, Xdb] = dbfft_smooth_shift(hi, fs, 8, i);
    if i <= 4
      plot(freq, Xdb, 'DisplayName', sprintf('Harmonic %d', i));
    endif
    hrs(i,:) = 10.^(Xdb/20);
  endfor

  legend('location', 'southoutside', "orientation", "horizontal");

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % THD as percentage
  figure
  X = 10.^(Hfdb/20);

  for i=2:size(hrs)(1)
    hrs(1,:) = hrs(1,:) + hrs(i,:).^2;
  endfor

  THD = sqrt(hrs(1,:))./X * 100;
  plot(freq, THD);
  title("THD %");
  axis([f1 f2 0 10]);
  set(gca, "xscale", "log");
  xlabel("Hz")
  ylabel("THD %");
  grid on;

endfunction

