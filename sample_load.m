% loads samplefile and locates the signal of length T by a pilot wave (if defined)
% Pilot wave is typically a short 1kHz burst followed by silence before the actual
% signal follows.
%
% For example:
% Find 3s signal from samplefile that has 1kHz 0.5s pilot wave and 0.5s of
% silence after it before the signal.
% [x, fs] = sample_load('data/pilot.wav', 3, 1000, 0.5, 0.5);
%
% Plot and analyze the signal
% plot(linspace(0, 3, length(x)), x);
% analyze(x, 3, 100, 10000, fs);
%
% Copyright 2022 - 2024 Teemu Ikonen
%
function [x, fs] = sample_load(samplefile, T, pilotFreq, pilotT, pilotDelayT)
  [x, fs] = audioread(samplefile);
  x = transpose(x);

  d = 1;
  if pilotFreq > 0
    pilot = sin(2*pi*pilotFreq*[0: 1/fs: pilotT]);
    d = findsignal(x, pilot);
    d += round((pilotDelayT + pilotT) * fs);
  endif

  x = x(d:min(d+round(T * fs), length(x)));

endfunction
