#!/bin/bash

set +e

CURRENT_HOSTNAME=`cat /etc/hostname | tr -d " \t\n\r"`
if [ -f /usr/lib/raspberrypi-sys-mods/imager_custom ]; then
   /usr/lib/raspberrypi-sys-mods/imager_custom set_hostname rpi400
else
   echo rpi400 >/etc/hostname
   sed -i "s/127.0.1.1.*$CURRENT_HOSTNAME/127.0.1.1\trpi400/g" /etc/hosts
fi
FIRSTUSER=`getent passwd 1000 | cut -d: -f1`
FIRSTUSERHOME=`getent passwd 1000 | cut -d: -f6`
if [ -f /usr/lib/raspberrypi-sys-mods/imager_custom ]; then
   /usr/lib/raspberrypi-sys-mods/imager_custom enable_ssh -k 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDnV2fGMnRyLBM0qmCw3Q/hIZ7kCNxX4SNLnj66hBssptQIGqtuFesCzlwbNY0nVn/uZVRX9p5dYxuMQVuHF9gp1hHHae90EULwGUxCMjU3UvoeOmUN4lebecpZVaihzqqqdb7oEXqNKxqU4FWwWx/+W0BLOFIyM1ILjkx13pmJrw== pmoore@Peters-MacBook-Pro.local'
else
   install -o "$FIRSTUSER" -m 700 -d "$FIRSTUSERHOME/.ssh"
   install -o "$FIRSTUSER" -m 600 <(printf "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDnV2fGMnRyLBM0qmCw3Q/hIZ7kCNxX4SNLnj66hBssptQIGqtuFesCzlwbNY0nVn/uZVRX9p5dYxuMQVuHF9gp1hHHae90EULwGUxCMjU3UvoeOmUN4lebecpZVaihzqqqdb7oEXqNKxqU4FWwWx/+W0BLOFIyM1ILjkx13pmJrw== pmoore@Peters-MacBook-Pro.local") "$FIRSTUSERHOME/.ssh/authorized_keys"
   echo 'PasswordAuthentication no' >>/etc/ssh/sshd_config
   systemctl enable ssh
fi
if [ -f /usr/lib/userconf-pi/userconf ]; then
   /usr/lib/userconf-pi/userconf 'pmoore' '$5$clguKafwPQ$vELkq/5m4J8J9ZqGQ0An.7IQEl1n8L9kXz.u0QkwiD3'
else
   echo "$FIRSTUSER:"'$5$clguKafwPQ$vELkq/5m4J8J9ZqGQ0An.7IQEl1n8L9kXz.u0QkwiD3' | chpasswd -e
   if [ "$FIRSTUSER" != "pmoore" ]; then
      usermod -l "pmoore" "$FIRSTUSER"
      usermod -m -d "/home/pmoore" "pmoore"
      groupmod -n "pmoore" "$FIRSTUSER"
      if grep -q "^autologin-user=" /etc/lightdm/lightdm.conf ; then
         sed /etc/lightdm/lightdm.conf -i -e "s/^autologin-user=.*/autologin-user=pmoore/"
      fi
      if [ -f /etc/systemd/system/getty@tty1.service.d/autologin.conf ]; then
         sed /etc/systemd/system/getty@tty1.service.d/autologin.conf -i -e "s/$FIRSTUSER/pmoore/"
      fi
      if [ -f /etc/sudoers.d/010_pi-nopasswd ]; then
         sed -i "s/^$FIRSTUSER /pmoore /" /etc/sudoers.d/010_pi-nopasswd
      fi
   fi
fi
if [ -f /usr/lib/raspberrypi-sys-mods/imager_custom ]; then
   /usr/lib/raspberrypi-sys-mods/imager_custom set_keymap 'us'
   /usr/lib/raspberrypi-sys-mods/imager_custom set_timezone 'Europe/Berlin'
else
   rm -f /etc/localtime
   echo "Europe/Berlin" >/etc/timezone
   dpkg-reconfigure -f noninteractive tzdata
cat >/etc/default/keyboard <<'KBEOF'
XKBMODEL="pc105"
XKBLAYOUT="us"
XKBVARIANT=""
XKBOPTIONS=""

KBEOF
   dpkg-reconfigure -f noninteractive keyboard-configuration
fi
rm -f /boot/firstrun.sh
sed -i 's| systemd.run.*||g' /boot/cmdline.txt
exit 0
