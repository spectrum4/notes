#!/bin/bash

# It looks like this script is for generating an SD card image of a spectrum4
# release. It looks like it was never finished because there is a docker run
# command that just runs bash, but the rest of the script runs under linux so
# probably needs to run inside that docker container. In any case, Raspberry Pi
# Imaging tool works with zip files, so probably not even needed.

cd ~/git/spectrum4
lint.sh
tup -k
rm -rf dist
cp -Lr src/spectrum4/dist .
docker run --privileged=true --rm -v $(pwd)/dist:/dist -w /dist -ti ubuntu /bin/bash
apt-get update -y
apt-get install -y dosfstools
for build in debug release; do
  dd if=/dev/zero of=spectrum4-0.0.1-${build}.img bs=1024 count=8192
  mkfs.vfat -n 'SPECTRUM 4' spectrum4-0.0.1-${build}.img
  mkdir /sp4-${build}
  mount -o loop spectrum4-0.0.1-${build}.img /sp4-${build}
  cp ${build}/* /sp4-${build}
  umount /sp4-${build}
  rm -r /sp4-${build}
done
