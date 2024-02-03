% Reads sample file and computes FFT power in dB
function sample_fftdb(samplefile)
  [y, fs] = audioread(samplefile);
  if size(y)(1) < size(y)(2)
    y = transpose(y)
  endif

  % if stereo track take left track
  if size(y)(2) > 1
    y = y(:,1);
  endif

  [freq, Ydb] = dbfft_smooth(y, fs, 8);
  figure
  plot(freq, Ydb);
  title(samplefile);
  xlabel("Hz")
  ylabel("dB");
  set(gca, "xscale", "log");
  grid on;
endfunction

