
# Arch Install Script

A simple bash script to automate the installation of Arch Linux.

## Installation

#### Installation
```bash
git clone https://github.com/samay15jan/arch-install
cd arch-install
./arch-install.sh
```


## Configurations

This script asks for somoe basic details like internet setup, hostname, username, user password and root password. By default it create a 500MB partition for efi and utilizes rest of drive for arch linux. 

After the installation is finished you need to  restart and login. If you prefer to have a graphical interface with all my configurations and customizations then run
```bash
sudo mv arch_install3.sh ~/
./arch_install3.sh
```

## Note 

This script will wipe everything you have on your pc. So, am not responsible for any sort data loss while installation. 

I recommend checking the script before installation :)
