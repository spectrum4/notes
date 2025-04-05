#!/bin/bash

# It looks like this was looking for references in homescreen.s to labels
# defined in Spectrum128_ROM1.s. Homescreen was an initial project processed a
# screenshot of the original Spectrum menu screen, and adapted it to the new
# Spectrum4 character and screen dimensions to mock up what the main menu would
# (approximately) look like. No longer needed since Spectrum +4 can already
# render the main menu natively.

cd "$(dirname "${0}")"
cat homescreen.s | sed -n 's/.*\(L[0-9A-F][0-9A-F][0-9A-F][0-9A-F]\).*/\1/p' | sort -u | while read x; do grep -q "${x}:" homescreen.s || grep "^${x}:" ../notes/spectrum128/Spectrum128_ROM1.s; done
