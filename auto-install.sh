#!/bin/bash

#Checking internet connection
clear
echo ""
echo "Checking Internet Connection..."
rfkill unblock all
if ping -c 1 google.com > /dev/null; then
  echo "Successfully Connected"
else
  iwctl device list
  read -p "Enter the WiFi Adaptor: " selected_adaptor
  iwctl station $selected_adaptor scan
  iwctl station $selected_adaptor get-networks
  read -p "Enter the WIFI network: " selected_ssid
  read -p "Enter Passwork for $selected_ssid: " wifi_password
  iwctl --passphrase=$wifi_password station $selected_adaptor connect $selected_ssid
  sleep 5
  if ping -c 1 google.com > /dev/null; then
    echo "Connected to $selected_ssid successfully!"
  else
    echo "Connecting to $selected_ssid failed!"
    echo "Please manually configure your wifi connection."
    exit 1
  fi
fi

# Cloning the github repository
git clone https://github.com/samay15jan/heimos
cd heimos
clear
echo ""
./arch-install.sh

