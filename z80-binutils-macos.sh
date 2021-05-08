#!/usr/bin/env bash
set -xveu

V=2.36.1   # Binutils Version
ARCH=z80 # Target architecture
TARGET=z80-unknown-elf

cd ~/tmp
rm -rf binutils*
wget -nc https://ftp.gnu.org/gnu/binutils/binutils-$V.tar.gz
wget -nc https://ftp.gnu.org/gnu/binutils/binutils-$V.tar.gz.sig

gpg --keyserver keys.gnupg.net --recv-keys 4AE55E93
gpg --verify binutils-$V.tar.gz.sig

tar xf binutils-$V.tar.gz

mkdir binutils-build
cd binutils-build

export AR=ar
export AS=as

../binutils-$V/configure \
    --prefix=/usr/local \
    --target=$TARGET \
    --disable-static \
    --disable-multilib \
    --disable-werror \
    --disable-nls

MAKE=gmake
hash gmake || MAKE=make

$MAKE -j clean all
sudo $MAKE install
