# It looks like for some reason spaces got added in some log output from tests. I don't think this is needed anymore.

(ltup -k) 2>&1 | tr '\n' ' ' | sed 's/FAIL:/\n&/g' | sed 's/h ave/have/' | sed 's/  / /' | sed 's/ ,/,/' | sed 's/\./&\n/' | grep '^FAIL:'
