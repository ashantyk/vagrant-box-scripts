#!/bin/bash

# preverabily run this script on a clean install of ubuntu 24 server (minimized) 
# with username, hostname and password set to 'vagrant'
# and ssh installed with 'allow password login' (when asked during OS install)

# REQUEST SUDO FROM USER
if (($EUID != 0)); then
  if [[ -t 1 ]]; then
    sudo "$0" "$@"
  else
    exec 1>output_file
    gksu "$0 $@"
  fi
  exit
fi

# make vagrant user not require password (will work only after restart)
echo "vagrant ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vagrant

# get vagrant key
wget --no-check-certificate https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub -O /home/vagrant/.ssh/authorized_keys

# update repositories
apt-get update

# install build essentials
apt install build-essential -y

# install/build vbox guest additions
cd /tmp
VBOX_VERSION=7.1.6
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop,ro VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
/mnt/VBoxLinuxAdditions.run --nox11
umount /mnt
rm VBoxGuestAdditions_$VBOX_VERSION.iso

# update bootloader (grub)
sed -i /etc/default/grub \
  -e "s/GRUB_CMDLINE_LINUX_DEFAULT=\"\"/GRUB_CMDLINE_LINUX_DEFAULT=\"net.ifnames=0 quiet\"/g"
update-grub

# cleanup
apt purge build-essential gcc make perl
apt autoremove
apt clean
