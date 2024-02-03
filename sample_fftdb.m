% Reads sample file and computes FFT power in dB
function sample_fftdb(samplefile)
  [y, fs] = audioread(samplefile);
  [freq, Ydb] = dbfft_smooth(y, fs, 8);
  figure
  plot(freq, Ydb);
  title(samplefile);
  xlabel("Hz")
  ylabel("dB");
  set(gca, "xscale", "log");
  grid on;
endfunction

