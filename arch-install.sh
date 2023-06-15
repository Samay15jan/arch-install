#!/bin/bash
read -p "Please enter hostname: " hostname
read -p "Please enter username: " username
read -p "Please enter user password: " user_password
read -p "Please enter root password: " root_password
lsblk | grep disk
read -p "Please enter device id where you want to install Arch(eg-sda,sdb): " drive
efi="${drive}1"
root="${drive}2"
# Step 1
loadkeys us
pacman --noconfirm -Sy archlinux-keyring
timedatectl set-ntp true
wipefs -a /dev/$efi
wipefs -a /dev/$root
wipefs -a /dev/$drive
sfdisk --force /dev/$drive << EOF
,500m
;
EOF
mkfs.fat -F 32 /dev/$efi
mkfs.ext4 /dev/$root
mount /dev/$root /mnt
mkdir -p /mnt/boot/efi
mount /dev/$efi /mnt/boot/efi
pacstrap /mnt base linux linux-firmware efibootmgr grub networkmanager sed nano sudo
genfstab -U /mnt >> /mnt/etc/fstab
echo "echo $hostname > /etc/hostname" >> /mnt/temp.sh
echo "useradd -m -G wheel -s /bin/bash $username" >> /mnt/temp.sh
echo "echo \"$username ALL=(ALL:ALL) ALL\" >> /etc/sudoers" >> /mnt/temp.sh
echo "echo $username:$user_password | chpasswd" >> /mnt/temp.sh
echo "echo root:$root_password | chpasswd" >> /mnt/temp.sh
chmod u+x /mnt/temp.sh 
sed '1,/^# Step 2$/d' `basename $0` > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh
exit

# Step 2
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
sed -i "/en_IN.UTF-8/s/^#//g" /etc/locale.gen
locale-gen
echo "LANG=en_IN.UTF-8" >> /etc/locale.conf
echo "KEYMAP=us" > /etc/locale.conf
./temp.sh
rm -r /temp.sh
grub-install /dev/sda
sed -i 's/quiet/pci=noaer/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable NetworkManager.service
sed '1,/^# Step 3$/d' arch_install2.sh > /home/arch_install3.sh
chmod +x /home/arch_install3.sh
rm /arch_install2.sh
exit

# Step 3
sudo pacman -S --noconfirm ttf-dejavu pango i3 dmenu ffmpeg jq curl \
        alacritty pavucontrol go xorg openssh imagemagick unzip \
        light git nautilus firefox base-devel python python-pip \
        arandr feh bluez bluez-utils gmtp pamixer acpi xorg-xinit \
        mpv neofetch qbittorrent code sxiv nano kdeconnect lynx \
        pulseaudio sysstat android-file-transfer mtpfs gvfs-mtp ttf-font-awesome
sudo pacman -R i3lock
sudo pip3 install pywal
cd /home/$USER
git clone https://aur.archlinux.org/yay-git.git
sudo chown -R $USER:$USER /home/$USER
cd /home/$USER/yay-git
makepkg -si
yay -S --noconfirm pfetch jmtpfs picom-jonaburg-git i3lock-color python-pywalfox
echo "exec i3 " >> /home/$USER/.xinitrc
sudo systemctl enable bluetooth.service
sudo chmod +s /usr/bin/light
git clone https://github.com/samay15jan/dotfiles
git clone https://github.com/samay15jan/wallpaper
sudo chown -R $USER:$USER /home/$USER
sudo chmod -R 777 /home/$USER/dotfiles/bin/
sudo mv /home/$USER/dotfiles/bin /usr/local
sudo chown -R $USER:$USER /usr/local/bin/
sudo chmod -R 777 /home/$USER/dotfiles/config/i3/scripts/
sudo chmod 777 /home/$USER/dotfiles/screenlayout/layout.sh
sudo rm -r /home/$USER/dotfiles/.git/
sudo mv /home/$USER/dotfiles/* /home/$USER/
sudo mv /home/$USER/wallpaper Wallpaper
sudo mv /home/$USER/bashrc .bashrc
sudo mv /home/$USER/bash_profile .bash_profile
sudo rm -r .config
sudo mv /home/$USER/config .config
sudo mv /home/$USER/screenlayout .screenlayout
mkdir /home/$USER/.cache /home/$USER/.cache/wal/
sudo pywalfox install
sudo rm -r /home/$USER/yay-git /home/$USER/arch-install /home/$USER/dotfiles 
sudo chown -R $USER:$USER /home/$USER
wall
echo "Install pywallfox extension manually on firefox"
