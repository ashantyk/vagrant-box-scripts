# Vagrant Box Build Scripts

This repository contains a collection of scripts to build Vagrant boxes from scratch (Ubuntu ISOs).


## Requirements
- Vagrant 2.2+
- VirtualBox 6+


## Building a Vagrant Box
1. Spin up a Virtual Machine
2. Run one of the `make-*.sh` scripts depending on your selected virtual machine OS.
3. Run `vagrant package --base <virtual-box-vm-name> --output <box-name>.box` to create the Vagrant box file. 

You can publish this box to Vagrant Cloud or use it locally.

