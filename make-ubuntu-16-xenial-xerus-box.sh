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

# update / fix locale
echo 'LC_ALL="en_US.utf8"' >> /etc/environment

# get vagrant key
mkdir -p /home/vagrant/.ssh
wget --no-check-certificate https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub -O /home/vagrant/.ssh/authorized_keys
chmod 0700 /home/vagrant/.ssh
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant /home/vagrant/.ssh

# add some faster repositories
echo 'deb http://eu-central-1.clouds.archive.ubuntu.com/ubuntu/ xenial main restricted universe multiverse' >> /etc/apt/sources.list
echo 'deb http://eu-central-1.clouds.archive.ubuntu.com/ubuntu/ xenial-updates main restricted universe multiverse' >> /etc/apt/sources.list
echo 'deb http://eu-central-1.clouds.archive.ubuntu.com/ubuntu/ xenial-security main restricted universe multiverse' >> /etc/apt/sources.list

# update repositories
apt-get update

# install ssh server
apt-get install openssh-server -y

# config ssh server 
sed /etc/ssh/sshd_config -i \
    -e 's/\#AuthorizedKeysFile/AuthorizedKeysFile/g' \
    -e 's/PubKeyAuthentication no/PubKeyAuthentication yes/g' \
    -e 's/\#PubKeyAuthentication/PubKeyAuthentication/g' \
    -e 's/PermitEmptyPasswords yes/PermitEmptyPasswords no/g' \
    -e 's/\#PermitEmptyPasswords/PermitEmptyPasswords/g' 

echo "UseDNS no" >> /etc/ssh/sshd_config

# restart ssh
service ssh restart

# install build essentials
apt-get install -y build-essential linux-headers-generic linux-headers-`uname -r`

# install/build vbox guest additions
cd /tmp
VBOX_VERSION=5.0.14
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop,ro VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
/mnt/VBoxLinuxAdditions.run --nox11

# cleanup
umount /mnt
rm VBoxGuestAdditions_$VBOX_VERSION.iso 
apt-get purge git git-man -y -f
apt-get purge wireless* memtest86+ laptop-detect -y -f
apt-get purge build-essential linux-headers* software-properties-common make -y -f
apt-get purge libx11* gcc cpp gcc-5 cpp-5 -y -f
apt-get purge usbutils lxc lxcfs lxd-client open-vm-tools python2.7 python2.7-doc -y -f
apt-get autoremove -y -f

# ensure some utils
apt-get install rsync iptables lsb-release vim -y -f

# update bootloader (grub)
sed -i /etc/default/grub \
  -e "s/GRUB_TIMEOUT=[0-9]\+/GRUB_TIMEOUT=1/g" \
  -e "s/GRUB_CMDLINE_LINUX_DEFAULT=\"\"/GRUB_CMDLINE_LINUX_DEFAULT=\"net.ifnames=0 quiet\"/g"
update-grub

# update network interfaces
sed /etc/network/interfaces -i -e 's/\enp0s3/eth0/g'
echo "auto eth1" >> /etc/network/interfaces
echo "iface eth1 inet manual" >> /etc/network/interfaces
echo "auto eth2" >> /etc/network/interfaces
echo "iface eth2 inet manual" >> /etc/network/interfaces
echo "auto eth3" >> /etc/network/interfaces
echo "iface eth3 inet manual" >> /etc/network/interfaces

# whiteout
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

# clear history
cat /dev/null > /home/vagrant/.bash_history
cat /dev/null > /root/.bash_history
history -c
