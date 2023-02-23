#!/bin/sh

asl patch.s -i . -n -U -o batrider.o
p2bin batrider.o batrider.bin
rm batrider.o
split -b 1M batrider.bin batrider
rm batrider.bin
rm batriderab
deinterleave batrideraa prg
mv prg.even /mame/roms/batriderj/prg0b.u22
mv prg.odd /mame/roms/batrider/prg1b.u23
