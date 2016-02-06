#!/bin/bash

# sudo su
# visudo
# > type "vagrant ALL=(ALL) NOPASSWD:ALL" at the end


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

# update repositories
apt-get update

# install vim
apt-get install vim -y

# get vagrant key
mkdir -p /home/vagrant/.ssh
wget --no-check-certificate https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub -O /home/vagrant/.ssh/authorized_keys
chmod 0700 /home/vagrant/.ssh
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

# install ssh server
apt-get install openssh-server -y

# config ssh server 
sed /etc/ssh/sshd_config -i \
    -e 's/\#AuthorizedKeysFile/AuthorizedKeysFile/g' \
    -e 's/\PubKeyAuthentication no/PubKeyAuthentication yes/g' \
    -e 's/\#PubKeyAuthentication/PubKeyAuthentication/g' \
    -e 's/\PermitEmptyPasswords yes/PermitEmptyPasswords no/g' \
    -e 's/\#PermitEmptyPasswords/PermitEmptyPasswords/g' 

echo "UseDNS no" >> /etc/sshd_config

# restart ssh
service ssh restart

# install build essentials
apt-get install -y build-essential linux-headers-generic linux-headers-`uname -r`

# install/build vbox guest additions
cd /tmp
VBOX_VERSION=5.0.14
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop,ro VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
/mnt/VBoxLinuxAdditions.run -nox11

# cleanup
umount /mnt
rm VBoxGuestAdditions_$VBOX_VERSION.iso 
apt-get purge git git-man -y -f
apt-get purge build-essential linux-headers* software-properties-common libx11* gcc cpp gcc-5 cpp-5 -y -f
apt-get purge wireless* memtest86+ laptop-detect -y -f
apt-get autoremove

# ensure rsync
apt-get install rsync

# update bootloader (grub)
sed -i /etc/default/grub \
  -e "s/GRUB_TIMEOUT=[0-9]\+/GRUB_TIMEOUT=1/g" \
  -e "s/GRUB_CMDLINE_LINUX_DEFAULT=\"\"/GRUB_CMDLINE_LINUX_DEFAULT=\"quiet\"/g"
update-grub

# whiteout
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# clear history
cat /dev/null > /home/vagrant/.bash_history
cat /dev/null > /root/.bash_history
history -c







