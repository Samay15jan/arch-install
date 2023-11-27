#!/bin/bash

# Display a welcome message
echo "
                    _ _ _ ____ _    ____ ____ _  _ ____    ___ ____    ____ ____ ____ _  _    _ _  _ ____ ___ ____ _    _
                    | | | |___ |    |    |  | |\/| |___     |  |  |    |__| |__/ |    |__|    | |\ | [__   |  |__| |    |
                    |_|_| |___ |___ |___ |__| |  | |___     |  |__|    |  | |  \ |___ |  |    | | \| ___]  |  |  | |___ |___

"

#Checking internet connection 
rfkill unblock all
if ping -c 1 google.com > /dev/null; then
  echo ""
else
  iwctl device list
  stations=$(iwctl device list | grep station | cut -d ' ' -f 2)
  counter=1
  wifi_list=""

  for station in $stations; do
    ssid=$(iwctl station $station get-network | grep SSID | cut -d ':' -f 2 | cut -d '"' -f 2)
    if [ -z "$ssid" ]; then
      continue
    fi

    wifi_list="$wifi_list$counter. $ssid\n"
    counter=$((counter + 1))
  done

  read -p "Select the WiFi network: " selected_number
  if [[ ! $selected_number =~ ^[0-9]+$ ]]; then
    echo "Invalid selection. Please enter a valid number."
    exit 1
  fi

  if [[ $selected_number -lt 1 || $selected_number -gt $counter ]]; then
    echo "Invalid selection. Please enter a number between 1 and $counter."
    exit 1
  fi

  selected_ssid=$(echo "$wifi_list" | sed -n "$selected_number p")
  selected_ssid=${selected_ssid#*/}

  echo "Connecting to WiFi network: $selected_ssid"
  iwctl station $stations | grep station | cut -d ' ' -f 2 | xargs -I station iwctl station $station connect $selected_ssid security=wpa2-psk key=$wifi_password
  sleep 5
  if ping -c 1 google.com > /dev/null; then
    echo ""
  else
    echo "Connecting to $selected_ssid failed!"
    echo "Please manually configure your wifi connection."
    exit 1
    fi
fi


# Collecting user information
echo "Please enter the hostname for your system:"
read -p "Hostname: " hostname
if [ -z "$hostname" ]; then
    echo "Error: Hostname cannot be empty."
    exit 1
fi

echo "Enter a username for the system:"
read -p "Username: " username
if [ -z "$username" ]; then
    echo "Error: Username cannot be empty."
    exit 1
fi

echo "Set a password for the user '$username':"
read -p "Password: " user_password
if [ -z "$user_password" ]; then
    echo "Error: Password cannot be empty."
    exit 1
fi

echo "Set the root password for the system:"
read -p "Root password: " root_password
if [ -z "$root_password" ]; then
    echo "Error: Root password cannot be empty."
    exit 1
fi


# Display available drives
echo "----------------------------------"
echo "Available drives:"
echo "----------------------------------"
echo ""
echo "NAME  SIZE  TYPE"
echo ""
lsblk -o NAME,SIZE,TYPE | grep disk
echo ""
echo "----------------------------------"


# Prompt for drive selection
echo "Please select the drive where you want to install Arch (e.g., sda, sdb):"
read -p "Drive: " drive

if [ -z "$drive" ]; then
    echo "Error: Drive selection cannot be empty."
    exit 1
fi


# Inform user about formatting
echo "WARNING: Formatting the selected drive ($drive) will erase all existing data on it."
echo "Do you want to continue? (y/n):"
read -p "Confirmation: " confirmation

if [ "$confirmation" != "y" ]; then
    echo "Exiting..."
    exit 1
fi
efi="${drive}1"
root="${drive}2"


# Step 1
pacman-key --init
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
pacstrap /mnt base linux linux-firmware efibootmgr grub networkmanager sed sudo
genfstab -U /mnt >> /mnt/etc/fstab
echo "echo $hostname > /etc/hostname" >> /mnt/temp.sh
echo "useradd -m -G wheel -s /bin/bash $username" >> /mnt/temp.sh
echo "echo \"$username ALL=(ALL:ALL) ALL\" >> /etc/sudoers" >> /mnt/temp.sh
echo "echo $username:$user_password | chpasswd" >> /mnt/temp.sh
echo "echo root:$root_password | chpasswd" >> /mnt/temp.sh
echo "grub-install /dev/$drive" >> /mnt/temp.sh
echo "USER=$username" >> /mnt/temp.sh
chmod u+x /mnt/temp.sh 
sed '1,/^# Step 2$/d' `basename $0` > /mnt/arch_install2.sh
chmod +x /mnt/arch_install2.sh
arch-chroot /mnt ./arch_install2.sh
echo "Minimal Arch Linux Installed Successfully!"
echo "System will now reboot in 5 seconds"
sleep 5
reboot


# Step 2
#!/bin/bash
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
sed -i "/en_IN.UTF-8/s/^#//g" /etc/locale.gen
locale-gen
echo "LANG=en_IN.UTF-8" >> /etc/locale.conf
echo "KEYMAP=us" > /etc/locale.conf
./temp.sh
rm -r /temp.sh
sed -i 's/quiet/pci=noaer/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
systemctl enable NetworkManager.service
sed '1,/^# Step 3$/d' arch_install2.sh > /home/$USER/arch_install3.sh
chmod +x /home/$USER/arch_install3.sh
rm /arch_install2.sh
exit


# Step 3
#!/bin/bash
sudo pacman -S --noconfirm ttf-dejavu pango i3 dmenu ffmpeg jq curl wget\
        alacritty pavucontrol go xorg openssh imagemagick wmctrl scrot unzip \
        light git nautilus qutebrowser base-devel python python-pip mtpfs \
        arandr feh bluez bluez-utils gmtp pamixer acpi xorg-xinit gvfs-mtp\
        mpv neofetch qbittorrent code sxiv vim npm polybar ttf-font-awesome \
        pulseaudio sysstat android-file-transfer
sudo pacman -R --noconfirm i3lock 
sudo pacman -S --noconfirm python-pywal
echo "exec i3 " >> $HOME/.xinitrc
sudo systemctl enable bluetooth.service
sudo chmod +s /usr/bin/light
pulseaudio --start
cd $HOME 
git clone https://github.com/samay15jan/dotfiles
sudo rm -r $HOME/dotfiles/.git
cp -r $HOME/dotfiles/.* $HOME/dotfiles/Wallpaper $HOME/dotfiles/keybinding ~/
sudo cp $HOME/dotfiles/bin/* /usr/local/bin
sudo chmod u+x /usr/local/bin/*
sudo chmod u+x $HOME/.config/i3/scripts/*
git clone https://aur.archlinux.org/yay-git
sudo chown -R $USER:$USER $HOME 
cd $HOME/yay-git
makepkg -si
yay -S --noconfirm pfetch i3lock-fancy jmtpfs python-pywalfox
sudo pywalfox install
sudo rm -r $HOME/dotfiles $HOME/yay-git
startx
