#!/bin/bash

# It looks like this code attempts to estimate how far I am through the
# Spectrum4 project by working out which labels (L35FB ....) have been
# implemented out of all the routines that need to be implemented.

cd "$(dirname "${0}")"
./convert.sh >/dev/null
REMAINING_LINES=$(cat *.s | sed 's/#.*//' | sed 's/\/\/.*//' | sed 's/[[:space:]]*$//' | sed '/^$/d' | sed 's/^[LX][0-9A-F][0-9A-F][0-9A-F][0-9A-F]:/      /' | sed 's/^[A-Z_0-9]*:$//' | wc -l | sed 's/ //g')

cd ../zxspectrum_roms
TOTAL_LINES=$(cat *.s | sed 's/#.*//' | sed 's/\/\/.*//' | sed 's/[[:space:]]*$//' | sed '/^$/d' | sed 's/^[LX][0-9A-F][0-9A-F][0-9A-F][0-9A-F]:/      /' | sed 's/^[A-Z_0-9]*:$//' | wc -l | sed 's/ //g')

COMPLETED_LINES=$((TOTAL_LINES - REMAINING_LINES))

X=$(( 10000 * COMPLETED_LINES / TOTAL_LINES))
while [ ${#X} -lt 3 ]; do
  X=0${X}
done
echo "~${X%??}.${X: -2}% of the way (translated ${COMPLETED_LINES}/${TOTAL_LINES} lines)"

FRACTION=$(( TOTAL_LINES / COMPLETED_LINES ))
echo "Approximately 1/${FRACTION} of the way..."
