#!/bin/bash

apt-get purge git git-man -y -f
apt-get purge wireless* memtest86+ laptop-detect -y -f
apt-get purge build-essential linux-headers* software-properties-common make -y -f
apt-get purge libx11* gcc cpp gcc-5 cpp-5 -y -f
apt-get purge usbutils lxc lxcfs lxd-client open-vm-tools python2.7 python2.7-doc -y -f
apt-get autoremove -y -f
apt-get clean

# whiteout
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# clear history
cat /dev/null > /home/vagrant/.bash_history
cat /dev/null > /root/.bash_history
history -c
