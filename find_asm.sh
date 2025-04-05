#!/bin/bash

# It looks like this was an attempt to write a script to find all the unique
# aarch64 asm instructions used by Spectrum +4 project, probably so I could
# focus on those instructions first when writing my own assembler for the
# project (probably on the SAM Coupé). Never got any further with this.

# quick and dirty, only wrote/ran this once, not to be maintained
find ~/git/spectrum4/src/spectrum4 -name '*.s' | xargs cat | sed '/^#/d' | sed '/^$/d' | sort -u | sed 's/\/\/.*//' | sed 's/^[[:space:]]*[a-zA-Z0-9_]*:.*//' | sed '/^$/d' | sort -u | sed '/\.quad/d' | grep -v msgreg | grep -v '^\.set' | grep -v '\.include' | grep -v '^ *\.' | grep -v logarm | grep -v '^ *_' | sed 's/^ *//' | sort -u | grep -v '^#' | sed '/^$/d' | grep -v logreg | grep -vF '\' | grep -v lognzcv | while read a b; do echo "${a}"; done | sort -u | grep -v nzcv
