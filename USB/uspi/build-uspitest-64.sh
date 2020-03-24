#!/bin/bash -xve

NEW_DIR=$(mktemp -d)
cd "${NEW_DIR}"
curl -sL 'https://releases.linaro.org/components/toolchain/binaries/latest-7/aarch64-elf/gcc-linaro-7.3.1-2018.05-x86_64_aarch64-elf.tar.xz' | tar xvfJ -
export PATH="$(pwd)/gcc-arm-8.2-2018.11-x86_64-aarch64-elf/bin:${PATH}"

git clone git@github.com:rsta2/circle64.git
cd circle64
./makeall clean
./makeall
cd boot
make
cd ../..

git clone git@github.com:rsta2/uspi.git
cd uspi
{
  echo 'AARCH64 = 1'
  echo 'RASPPI = 3'
  echo 'PREFIX = aarch64-elf-'
  echo "USPIHOME = $(pwd)"
} > Config.mk
cd lib
# No `make clean`, so skip it
# make clean
make
cd ../..

curl -sL 'https://github.com/rsta2/uspi/files/2510850/uspitest64.zip' > uspitest64.zip
unzip uspitest64.zip
cd uspitest
sed -i "s%CIRCLEHOME = .*%CIRCLEHOME = ${NEW_DIR}/circle64%" Makefile
sed -i "s%USPIHOME   = .*%USPIHOME   = ${NEW_DIR}/uspi%" Makefile
make
aarch64-elf-objdump -d kernel8.elf > uspitest.s
cd ..
mkdir sdcard
mv uspitest/{kernel8.img,uspitest.s} sdcard
mv circle64/boot/* sdcard
md5sum sdcard/*

echo "Files in ${NEW_DIR}/sdcard"
