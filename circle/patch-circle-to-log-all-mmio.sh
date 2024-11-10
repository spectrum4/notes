#!/bin/bash

CIRCLE_DIR=~/git/circle
cd "${CIRCLE_DIR}"
find lib -name '*.cpp' | while read cppfile; do
  if grep -qF 'static const char From[]' "${cppfile}"; then
    continue
  fi
  if grep -q 'LOGMODULE *(' "${cppfile}"; then
    continue
  fi
  start_line=$(sed -n '/\/\/.*(C)/{=;q;}' "${cppfile}")
  comment_lines_plus_1=$(sed -n "${start_line},/^[^\/]/p" "${cppfile}" | wc -l)
  if [ -z "${start_line}" ]; then
    echo "Line not found: ${cppfile}"
	exit 1
  else
    if [ "${comment_lines_plus_1}" -lt 1 ]; then
      echo "Too few comment lines: ${comment_lines_plus_1}"
	  exit 1
    fi
	inject_at=$((comment_lines_plus_1 + start_line - 1))
    # Extract the filename without path and extension for the From variable
    logprefix=$(basename "$cppfile" .cpp)
  sed "${inject_at}i\\
\\
static const char From[] = \"${logprefix}\";\\
\\
" "${cppfile}" > temp_file
    cat temp_file > "${cppfile}"
    rm temp_file
  fi
done
