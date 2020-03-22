#!/bin/bash
cd "$(dirname "${0}")"
cat homescreen.s | sed -n 's/.*\(L[0-9A-F][0-9A-F][0-9A-F][0-9A-F]\).*/\1/p' | sort -u | while read x; do grep -q "${x}:" homescreen.s || grep "^${x}:" ../notes/spectrum128/Spectrum128_ROM1.s; done
