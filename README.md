# Distortion analysis using "Farina Sweep" method.

"Farina Sweep" is a method for measuring impulse response and distortion with a single logarithmic sine sweep.  ([[1]](#1), [[4]](#1)).

Basic algorithm of Farina method:
1. Generate logarithmic sweep excitation signal of known length, start and end frequency.
2. Play the signal and record the response.
3. Construct an inverse filter for the excitation signal and deconvolve the measured signal to get an impulse response.
4. Fundamentals and harmonics appear as distinct impulse peaks in the impulse response and can be extracted separately for further analysis.

This project demonstrates the core of this analysis method. It may be useful for learning and basis for further development. Written for [GNU Octave 8.3.0](https://octave.org/) but almost any version should work. Matlab should also run the scripts with minor modifications.

Filtering, frequency bin shifting, fading, smoothing, windowing methods etc. are often utilized with farina sweep to get cleaner results. See ([[2]](#2), [[3]](#3)) for some details. These methods are not used in the examples, except for the frequency response averaging (smoothing) for cleaner graph plotting.

Copyright 2022 - 2024 Teemu Ikonen
<br>
MIT License.

# Examples

### example_impulse
`example_impulse()` Ideal case. implements a pure undistorted sweep signal deconvolution that produces an impulse.

![Impulse](images/impulse.png "Impulse Response")

### example_harmonics
`example_harmonics()` demonstrates analysis of an distorted signal. The example adds asymmetric clipping distortion in the signal that creates large order of odd and even harmonics and demonstrates how these harmonics fall on known delayed times in the impulse response.

![Harmonics](images/harmonics.png "Impulse Response with harmonics")

### example_thd_analyze
`example_thd_analyze(T, fstart, fend, samplerate)` Total Harmonic Distortion (THD) analysis. Function accepts sweep duration, start and end frequency and the sample rate. It generates a sweep signal and adds known amount of 2nd, 3rd and 4th harmonics that should always produce 6.4% THD. This signal is then analyzed and results plotted.

    >> T = 1
    >> fstart = 100
    >> fend = 6000
    >> fs = 14400
    >> example_thd_analyze(T, fstart, fend, fs);

Frequency plot y-axis absolute dB values are meaningless and depend on the sweep length. Only relative dB difference between the main and harmonics is important.

![Frequency response](images/freq_response.png "Frequency Response")
![Harmonics](images/thd.png "Total Harmonic Distortion (THD)")

### sample_analyze
`sample_analyze(T, fstart, fend, filename)` Reads measured sample file and performs THD analysis. Analysis intermediate files and results are stored in `out` folder. `data` folder has a stimulus sweep and its recording. Sweep was played through Genelec speaker and recorded on UMIK-1 microphone.

    >> filename = data/closed_loop.wav;
    >> sample_analyze(5, 20, 5500, filename);
    Sample rate 44100Hz. Duration 5.06s
    Wrote out/deconvoluted_impulse_closed_loop.wav
    Wrote out/data_closed_loop.csv

The frequency response is presentative of a Hi-Fi speaker and the THD is minimal as expected.

![Sample frequency response](images/sample_freq_response.png "Frequency Response")

**NOTE** Data must start immediately in the samplefile. The sweep range parameters must match exactly the excitation sweep that was used to obtain the sample file. Wrong frequency skews the results.
As an example in the following 50Hz was used as analysis starting frequency instead of the correct 20Hz. The result is completely corrupted.

![Corrupted frequency response](images/sample_freq_response_wrong_freq.png "Corrupted frequency response")


### Bandwidth and Harmonics

Deconvolution inverse filter removes all frequencies higher than the end of the sweep frequency. Higher frequencies in the harmonics disappear. The sweep must be done further to capture ever more higher frequency harmonics. Also sample rate must be high enough to capture frequencies of interest. (*Figure 6a* [[2]](#2))

For example let end of sweep `fend` = 6000Hz and sample rate `fs` >= 12000Hz. The 2nd order harmonics end for fundamental 3000Hz, 3rd order for 2000Hz fundamental and so on. Increasing sample rate has no effect as deconvolution removes all frequencies beyond 6000Hz. This can be easily experimented with the `example_thd_analyze()` function.

This is not an major issue for audio sweeps to 20kHz. Human ear can't really hear harmonics above that frequency. For example 2nd harmonics of 10kHz fundamental cannot be heard, 3rd harmonics of 6.7kHz and so on.

If you want to analyze 2nd harmonics up to e.g. 6000Hz you must generate the sweep up to 12000Hz (and use 24000Hz sample rate). If you want to analyze 3rd harmonics up to 6000Hz the sweep must be generated up to 3*6000 = 18000Hz and sample rate must be naturally twice that, 36000Hz. And so on. On measurement sweep signal needs to be played only up to fundamental end frequency (6000Hz in this example). Use function `tfreqsinelog()` to figure out when to stop. Another way would be to low pass filter the sweep signal before playback.

    >> T = 3;
    >> fstart = 200;
    >> ftarget = 6000;
    >> fend = ftarget * 3; % up to 3rd harmonic
    >> fs = fend * 2;
    >> t = [0: 1/fs: T];
    >> x = sinelog(t, T, fstart, fend);
    >> ts = tfreqsinelog(ftarget, T, fstart, fend)
    ts = 2.4921
    >> x = fadeout(x, ts, .05, fs);

 Check that the generated sweep ends at the target frequency

    >> [freq, Xdb] = dbfft(x, fs);
    >> plot(freq, Xdb);

The recording has to to match the filter length. e.g. To analyze up to 6000hz a 1 second long sweep generated to 18000, the playback can be stopped at 0.7559s. but recording length must match the deconvolution filter so it must last for the full 1 second, or just pad recorded data with zeroes.

    >> y = padzeros(y, length(x))

## Main Library  functions
Examples are based on following functions.

### sinelog, isinelog
`y = sinelog(t, fstart, fend, samplerate)` and `isinelog(t, fstart, fend, samplerate)` generate a sweep and its inverse filter.

    >> T = 1
    >> f1 = 100
    >> f2 = 6000
    >> fs = 14400
    >> t = [0: 1/fs: T];
    >> y = sinelog(t, T, f1, f2) * 0.5;
    >> plot(t,y);
    >>

### dbfft_smooth
`[freq, Xdb] = dbfft_smooth(x, fs, N)` Smoothed out frequency power spectrum in dB. Returns frequency points for Renard 40 frequencies up to sampling rate averaged over by 1/N octaves.

    >> [freq, Ydb] = dbfft_smooth(y, fs, 8);
    >> plot(freq, Ydb)
    >> set(gca, "xscale", "log");

### nthharmonic
`t = nthharmonic(N, T, f1, f2)` Returns the expected time delay for Nth harmonic for the given sweep parameters.

### extract_harmonic
`[hn, t1, t2] = extract_harmonic(T, f1, f2, Fs, h, N)` extracts the Nth harmonic impulse from the deconvolution result h. The t1 and t2 are the end and start times of the extracted pulse.

## References

<a id="1">[1]</a>  Angelo Farina, "Simultaneous measurement of impulse response and distortion with a swept-sine technique", AES 108th Convention 2000  February  19-22 Paris, France.
<br>
<a id="2">[2]</a>  Antonín Novák, Laurent Simon, Pierrick Lotton. "Synchronized Swept-Sine: Theory, Application, and Implementation". Journal of the Audio Engineering Society, 2015, 63 (10), pp.786-798.
ff10.17743/jaes.2015.0071ff. ffhal-02504321.
<br>
<a id="3">[3]</a> Katja Vetter, Serafino di Rosario, "ExpoChirpToolbox: a Pure Data implementation of ESS impulse response measurement", Rotterdam/London, July 2011
<br>
<a id="4">[4]</a> Ian H. Chan, "Swept Sine Chirps for Measuring Impulse Response", Publication of Stanford Research Systems, Inc.




