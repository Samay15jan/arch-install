
# Arch Install Script

A simple bash script to automate the installation of Arch Linux.

## Installation

#### Connect WIFI:
```bash
iwctl
station [wifi-adaptor-name] connect [wifi-name]
exit
```
#### Installation
```bash
git clone https://github.com/samay15jan/arch-install
cd arch-install
chmod u+x arch-install.sh
./arch-install.sh
```


## Configurations

This script only asks for hostname, username, user password and root password. By default it create a 500MB partition for efi and utilizes rest for root directory of linux. 

After the installation is finished you need to  restart and login. If you prefer to have a graphical interface with all my configurations and customizations then run
```bash
sudo mv arch_install3.sh ~/
./arch_install.sh
```

## Note 

This script will wipe everything you have on your pc. So, am not responsible for any sort data loss while installation. 

I recommend checking the script before installation.
