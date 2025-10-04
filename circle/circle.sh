#!/bin/bash

set -eu
set -o pipefail

git clone git@github.com:petemoore/circle.git
cd circle
git checkout log-all-calls
./configure -r 4 -p aarch64-none-elf- --keymap US --qemu -d XHCI_DEBUG=1 -d XHCI_DEBUG2=1 -d DEBUG=1 -d USB_GADGET_DEBUG=1 -f
echo 'SDCARD = /private/tftpboot' > Config2.mk
./makeall clean
cd boot
sudo rm -rf /private/tftpboot/*
sudo make install64
cd ..
./makeall
cd sample/08-usbkeyboard
make clean
make
sudo make install
echo 'loglevel=4 logdev=ttyS1' | sudo tee /private/tftpboot/cmdline.txt
/Users/pmoore/bin/tftp_control.sh start
echo Done
