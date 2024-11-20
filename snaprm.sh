#!/bin/bash
printf "\nYou're using: "
cat /etc/os-release
printf "\n- - - - - - - - - - -\n\n"

printf "Note: This script will purge snapd ENTIRELY from your system.\n"
printf "If you do not want this, kill the script with CTRL+C NOW.\n\n"
x=9
until [[ $x -eq 0 ]];do
	printf "Continuing in: $x     \r"
	sleep 1
	let x-=1
done
printf "\rNote: If this script exits after purging snapd but before installing Firefox, run it again.\n\n"
printf "Unmounting all Snap loops.\n"
for lb in $(lsblk | grep snap | awk '{print $7}'); do
	sudo umount $lb
done
printf "Purging snapd.\n"
sudo $pm purge snapd
printf "Blocking snapd installation.\n"
echo '
Package: snapd
Pin: release a=*
Pin-Priority: -10
' | sudo tee /etc/apt/preferences.d/no-snap >/dev/null
printf "Downloading Mozilla repo signing key.\n"
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc >/dev/null
printf "Adding Mozilla repo.\n"
echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list >/dev/null
printf "Prioritising deb repo over Snap.\n"
echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla >/dev/null

printf "Installing Firefox.\n"
sudo $pm update
sudo $pm install firefox

printf "Enabling unattended updrages for Firefox.\n"
echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:${distro_codename}";' | sudo tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox

printf "\nFirefox is now the apt version & all snaps are removed.\n"
printf "\nNow installing Gnome softwares , extension manager and tweaks\n"
sudo apt install gnome-software gnome-shell-extension-manager gnome-tweaks
