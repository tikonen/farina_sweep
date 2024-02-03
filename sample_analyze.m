% Analyze sweep from frequency f1 to f2 in time T seconds. Assumes that the
% samplefile starts from t=0 and its length is very close to T /fs samples.
%
% Copyright 2022 - 2024 Teemu Ikonen
%
function sample_analyze(T, f1, f2, samplefile)
  [y, fs] = audioread(samplefile);
  y = transpose(y);
  printf('Sample rate %dHz. Duration %.2fs\n', fs, length(y)/fs);
  samplefile =  strsplit(samplefile, '/')(end){1,1};

  # Assume sample starts from t=0 and add silence in the sample
  tdelta = T * .1;
  y = padzero(y, (round(fs * tdelta) + length(y)));

  t = [0: 1/fs: T];
  f = isinelog(t, T, f1, f2);
  L = length(y);
  f = padzero(f, L);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Plot impulse response
  H = fft(y) .* fft(f);
  H(1) = 0; % No DC
  h = real( ifft(H) );
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
  outfile=sprintf('out/deconvoluted_impulse_%s', samplefile);
  audiowrite(outfile, h/max(h), fs);
  printf('Wrote %s\n', outfile);

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

  %outfile=sprintf('out/main_impulse_%s', samplefile);
  %audiowrite(outfile, hfundamental/max(hfundamental), fs);
  %printf('Wrote %s\n', outfile);

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

  % Dump data to a CSV file.
  csvfilename = sprintf('out/data_%s.csv', strsplit(samplefile, '.'){1});
  data = {freq, Hfdb, THD};
  fid = fopen(csvfilename,'w'); fprintf(fid, "Freq,Main(dB),THD(%%)\n"); fclose(fid);
  m = cell2mat (data')';
  dlmwrite(csvfilename, m, '-append');
  printf('Wrote %s\n', csvfilename);

endfunction

