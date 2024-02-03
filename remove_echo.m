% Function removes echo spikes from the sinesweep impulse response. Assume
% that main impulse center is at 0.
%
% Copyright 2022 - 2024 Teemu Ikonen
%
function ret = remove_echo(h, T, Fs, f1, f2, echodelay)
    % remove main impulse echo
    w2 = round(echodelay * Fs /3 / 2); % window size/2
    i = round(echodelay * Fs); % location of main echo pulse
    h(i-w2:i+w2) = h(i+w2:i+w2*3); % copy signal after echo over echo spike

    % remove 6 first harmonic echos
    for n = 2:6
      t = nthharmonic(n, T, f1, f2) + T; % location of nthharmonic in time
      i = round((t + echodelay) * Fs); % index location of echo pulse
      h(i-w2:i+w2) = h(i+w2:i+w2*3); % replace echo with signal data after the echo
    endfor

    ret = h;
endfunction

