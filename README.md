# **Armed Police Batrider quality of life patches.**

Program rom patches for Armed Police Batrider (B version only) that add some convenience and functionality.

This is pretty much an adaptation of some of the @zakk4223 's [Quality-of-life patches for Battle Garegga](https://github.com/zakk4223/battle-garegga-patches), but modified to work with Batrider. Thanks a lot for your research and previous work on it! 🍻

Includes:

 - Rank mulplier value is always set as $100 (easier) at startup, in the same way as pressing Start button on the Test menu. No matter if Test is enabled or not.
 - Rank display. Real time display of current game rank.
 - Rank change display: Per-frame display of rank change during the frame. This excludes per-frame rank adjustments and any rank changes due to shooting (normal and option). (*STILL NOT WORKING*)
 - Rank percentage display.
 - Per frame rank display.

Rank and rank change are shown in hexadecimal. Per frame is shown in decimal.

## How to use

Extract any B version rom set (i.e. `batrider`, `batrideru`, `batriderc`, `batriderj` or `batriderk`). Use your favorite IPS patch applier to patch `prg0_____.u22` and `prg1b.u23` using the respective IPS files in this repo. `prg0.u22` could have different name for each supported rom set, that's why I put underscores on it.

Mame will complain about incorrect rom checksums. You can ignore this.

## Source

patch.s contains the assembly source to recreate this patch.  Use http://john.ccac.rwth-aachen.de:8000/as/ and https://www.mankier.com/1/p2bin to assemble it. You must combine `prg0_____.u22` and `prg1b.u23` into a single interleaved binary. See build.sh for exact command line arguments for various tools.
