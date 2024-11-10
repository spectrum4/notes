#!/usr/bin/env bash

# Note: this is an approximation to the steps that were actually taken when
# kernel8-rpi4.c21f2efdad86c1062f255fbf891135a2a356713e.lst was originally
# created, which I seem to have not captured at the time. These steps seem to
# produce some small differences, also when run against that commit. I haven't
# investigated why, or whether they are significant.

set -eu
set -o pipefail
# export SHELLOPTS

cd "$(dirname "${0}")"

rm -rf circle
rm -f kernel8-rpi4.*.lst.original kernel8-rpi4.*.elf kernel8-rpi4.*.img
git clone git@github.com:rsta2/circle.git
cd circle

# git checkout c21f2efdad86c1062f255fbf891135a2a356713e
# git checkout develop
# git checkout master
git checkout Step48

git remote add pete git@github.com:petemoore/circle.git
git fetch pete fix-cflashy-macos
GIT_COMMIT_SHA="$(git rev-parse HEAD)"
git cherry-pick 2f27212d92c27efc3493f97fe770e7ec9b380cae # fix configure script
git cherry-pick 06f741ca0e709422e87a956e5b274af345f6ba2a # fix cflashy

./configure -r 4 -p aarch64-none-elf- --keymap US --qemu -d XHCI_DEBUG=1 -d XHCI_DEBUG2=1 -d DEBUG=1 -d USB_GADGET_DEBUG=1 -f

./makeall
cd sample/08-usbkeyboard/
make
aarch64-none-elf-objdump -Cd kernel8-rpi4.elf > ../../../kernel8-rpi4.${GIT_COMMIT_SHA}.lst.original
mv kernel8-rpi4.elf ../../../kernel8-rpi4.${GIT_COMMIT_SHA}.elf
mv kernel8-rpi4.img ../../../kernel8-rpi4.${GIT_COMMIT_SHA}.img
cd ../../..
rm -rf circle
vim -d kernel8-rpi4.${GIT_COMMIT_SHA}.lst.original kernel8-rpi4.c21f2efdad86c1062f255fbf891135a2a356713e.lst.commented
qemu-system-aarch64 -full-screen -M raspi4b -kernel kernel8-rpi4.${GIT_COMMIT_SHA}.img -serial null -serial stdio
