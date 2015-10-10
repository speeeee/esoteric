wavlang
====

*wavlang* is a very simplistic stack-based language used for modifying WAV files.  More specifically, it works with single-channel WAV files with a sampling rate of 44100 samples/second where there are 16 bits per sample.

wavlang is built in Racket, and takes whatever code is passed to it and creates an equivalent C file.

Compared to other projects, this is probably my least stable.  As of now, it has only been tested on Mac OSX (10.10) using wav files with durations of aroundd two seconds, so there cannot be much to be said about stability.

# Setup

wavlang is very easy to set up; all that is needed a C compiler (C99 required, though only because anything before C99 did not allow declaration of variables in for loops), the Racket compiler, and the actual `.rkt` file of the language.

Once all of this is obtained, use the Racket compiler to compile the `.rkt` file to an executable (there is documentation for compilation in Racket).

# Compilation

Once the `wavlang` executable is made, it can now be used to modify wav files as it is supposed to.  The process is as shown: call `wavlang` on a `.wl` file to compile it to C, call any C compiler (`gcc` will be used as an example) to create the executable, and finally call the executable to create the new WAV file.

```
./wavlang [INPUT] [OUTPUT]
gcc -o [EXE] [OUTPUT].c
./[EXE]
```

More on wavlang is in DOCS.md.

**NOTE:** GitHub recognizes `.wl` as Mathematica, and will color it as such.