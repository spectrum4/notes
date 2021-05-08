#!/bin/bash

cd "$(dirname "${0}")"

mkdir -p ../spectrum4/spectrum128k
cat zxspectrum_roms/Spectrum128K_ROM0.asm > ../spectrum4/src/spectrum128k/rom0.s
cat zxspectrum_roms/Spectrum128K_ROM1.asm > ../spectrum4/src/spectrum128k/rom1.s
