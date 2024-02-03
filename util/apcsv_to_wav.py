import argparse
import os
try:
    import numpy as np
except Exception as e:
    print("ERROR: Please install numpy (https://pypi.org/project/numpy/)")
    raise e

try:
    import soundfile as sf
except Exception as e:
    print("ERROR: Please install soundfile (https://pypi.org/project/soundfile)")
    raise e


# Convert Audio Precision csv exports to wav files.
#
# Required libraries
# * soundfile (https://pypi.org/project/soundfile)
# * numpy (https://pypi.org/project/numpy/)

def main():
    parser = argparse.ArgumentParser(description='CSV to WAV')
    parser.add_argument('--verbose', action='store_true', help='verbose mode')
    parser.add_argument('-r', '--rate', type=int, help='Sample Rate in Hz')
    parser.add_argument("-d", '--delim', type=str, help='Delimiter')
    parser.add_argument("csvfile", type=str)
    args = parser.parse_args()

    print("Processing file", args.csvfile)

    delim = ','
    if args.delim:
        delim = args.delim

    print("Delimiter:", delim)

    data = open(args.csvfile).readlines()
    samples = []
    for line in data:
        items = line.split(delim)
        if len(items) >= 2:
            t = items[0]
            v = items[1]
            try:
                # Attempt to parse two floats
                samples.append((float(t), float(v)))
            except ValueError:
                if args.verbose:
                    print("Discarding", line)

    if len(samples) < 2:
        raise "Minimum 2 samples required"

    # examine samplerate
    rate = round(1 / (samples[1][0] - samples[0][0]))
    print("Native rate", rate, "Hz")
    if args.rate:
        rate = args.rate
    print("Export rate", rate, "Hz")

    name = os.path.split(args.csvfile)[1]
    name, ext = os.path.splitext(name)
    filename = name + ".wav"

    with sf.SoundFile(filename, mode='w', samplerate=rate, channels=1, subtype='FLOAT') as f:
        data = np.array([x[1] for x in samples])
        # Ensure that samples are in range [-1, 1]
        scale = max(data)
        if (scale > 1.0):
            print("Max value", scale, "Normalizing data")
            data /= scale

        # write data to wav file
        f.write(data)
        print("Output", filename)


if __name__ == '__main__':
    main()
