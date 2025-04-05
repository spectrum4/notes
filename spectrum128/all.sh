#!/bin/bash -eu

# It looks like this was an early version of the build process for the
# spectrum4 project, before switching to tup. No longer used.

# This bash script builds spectrum4 kernel and places all files for SD card
# under 'dist' directory. To specify a custom toolchain for assembling/linking
# etc, export environment variable TOOLCHAIN_PREFIX.

# verify_and_show_tool checks that a given toolchain command is present on the
# filesystem and reports its location.
#
# Inputs:
#   $1: Human readable description of the tool, right-padded with spaces to 12 chars
#   $2: Executable name (excluding toolchain prefix, if TOOLCHAIN_PREFIX set)
function verify_and_show_tool {
  if ! which "${TOOLCHAIN_PREFIX}${2}" >/dev/null; then
    echo "ERROR: Cannot find '${TOOLCHAIN_PREFIX}${2}' in PATH. Have you set TOOLCHAIN_PREFIX appropriately? Exiting." >&2
    exit 64
  fi
  echo "  ${1}  $(which ${TOOLCHAIN_PREFIX}${2})" >&2
}

# show_active_toolchain verifies that all required toolchain binaries are
# present and logs the file location of each of them.
function show_active_toolchain {
  verify_and_show_tool "Assembler:  " as
  verify_and_show_tool "Linker:     " ld
  verify_and_show_tool "Read ELF:   " readelf
  verify_and_show_tool "Object copy:" objcopy
  verify_and_show_tool "Object dump:" objdump
}

# Set default toolchain prefix to `aarch64-unknown-linux-gnu-` if no
# TOOLCHAIN_PREFIX already set. Note, if no prefix is required,
# TOOLCHAIN_PREFIX should be explicitly set to the empty string before calling
# this script (e.g. using `export TOOLCHAIN_PREFIX=''`).
if [ "${TOOLCHAIN_PREFIX+_}" != '_' ]; then
  TOOLCHAIN_PREFIX=aarch64-unknown-linux-gnu-
  echo "No TOOLCHAIN_PREFIX specified, therefore using default toolchain prefix '${TOOLCHAIN_PREFIX}':" >&2
  show_active_toolchain
else
  echo "TOOLCHAIN_PREFIX specified: '${TOOLCHAIN_PREFIX}':" >&2
  show_active_toolchain
fi

# Change into directory containing this script (in case the script is executed
# from a different directory).
cd "$(dirname "${0}")"

# Remove any previous build artifacts, and ensure build directory exists.
rm -rf build
mkdir build

# Assemble all `*.s` files in `src` directory to a `.o` file in `build`
# directory.
find src -name '*.s' | while read assembly_file; do
  object_file=build/${assembly_file#src/}.o
  "${TOOLCHAIN_PREFIX}as" -g -o "${object_file}" "${assembly_file}"
done

# Link binaries that were previously assembled. Options passed to the linker
# are:
#   -M: display kernel map
#   -o: elf file to generate
"${TOOLCHAIN_PREFIX}ld" -M -o build/spectrum4.elf build/*.o

# Log some useful information about the generated elf file.
"${TOOLCHAIN_PREFIX}readelf" -a build/spectrum4.elf

# Log disassembly of kernel elf file. This is like above, but additionally
# contains symbol names, etc.
"${TOOLCHAIN_PREFIX}objdump" -d build/spectrum4.elf
"${TOOLCHAIN_PREFIX}objdump" -s -j .data build/spectrum4.elf

echo
echo "Build successful."
