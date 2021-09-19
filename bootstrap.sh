#!/usr/bin/env bash
#=========================================================================
# Author: Gaetan (gaetan@ictpourtous.com) - Twitter: @GaetanICT
# Creation: Sun Mar 2020 19:49:21
# Last modified: Sun 19 Sep 2021 11:24:56
# Version: 1.0
#
# Description: this script automates the setup of my personal computers
#=========================================================================

#=======================
# Variables
#=======================
# Dotfiles location
dfloc="$HOME/.dotfiles"
dfrepo="https://github.com/GSquad934/dotfiles.git"

# Custom scripts location
scriptsloc="$HOME/.local/bin"
resourcesloc="$HOME/.local/share"

# Git repositories location
gitrepoloc="$HOME/.sources/repos"

# Software sources location
# sourcesloc="$HOME/.sources"

# Wallpapers
wallpapers="https://github.com/GSquad934/wallpapers.git"
wallpapersloc="$HOME/.local/share/wallpapers"

# Software lists
homebrew="https://raw.githubusercontent.com/Homebrew/install/master/install.sh"
aurhelper="https://aur.archlinux.org/yay.git"
applist="https://raw.githubusercontent.com/GSquad934/bootstrap/master/apps.csv"

# Font lists
symbols_nerd="https://github.com/ryanoasis/nerd-fonts/blob/master/src/glyphs/Symbols-2048-em%20Nerd%20Font%20Complete.ttf?raw=true"
mononoki_regular="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Mononoki/Regular/complete/mononoki-Regular%20Nerd%20Font%20Complete.ttf"
mononoki_bold="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Mononoki/Bold/complete/mononoki%20Bold%20Nerd%20Font%20Complete.ttf"
mononoki_italic="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Mononoki/Italic/complete/mononoki%20Italic%20Nerd%20Font%20Complete.ttf"
powerline_fonts="https://github.com/powerline/fonts"

# TMUX Plugins
tpm="https://github.com/tmux-plugins/tpm"

# Clipmenu location
clipmenurepo="https://github.com/cdown/clipmenu"

# Custom WM/DE location
dwmrepo="https://github.com/GSquad934/dwm.git"
dwmloc="/opt/dwm"
dmenurepo="https://github.com/GSquad934/dmenu.git"
dmenuloc="/opt/dmenu"
sentrepo="https://github.com/GSquad934/sent.git"
sentloc="/opt/sent"
strepo="https://github.com/GSquad934/st.git"
stloc="/opt/st"
slockrepo="https://github.com/GSquad934/slock.git"
slockloc="/opt/slock"
surfrepo="https://github.com/GSquad934/surf.git"
surfloc="/opt/surf"
adwaitaqtrepo="https://github.com/FedoraQt/adwaita-qt.git"

# Logging
date="$(date +%Y-%m-%d-%H%M%S)"
logfile="$HOME/bootstrap_log_$date.txt"

#=======================
# Functions
#=======================

# Log to/out of the console
logc(){ tee -a "$logfile" ;}
lognoc(){ tee -a "$logfile" > /dev/null 2>&1 ;}

# Determine init system in Linux
if [[ "$OSTYPE" == "linux-gnu" ]]; then
	if type systemctl >> /dev/null 2>&1; then
		initSystem="systemd"
		enableSvc() { sudo systemctl enable "$1" ;}
		startSvc() { sudo systemctl start "$1" ;}
	elif type rc-update >> /dev/null 2>&1; then
		initSystem="openrc"
		grepopenrcpkg(){ openrcpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[O][^,]*" | sed '/^W/d' | sed 's/^.*,//g' > "$openrcpkg" ;}
		grepworkopenrcpkg(){ openrcworkpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[O][^,]*" | sed 's/^.*,//g' > "$openrcworkpkg" ;}
		enableSvc() { sudo rc-update add "$1" ;}
		startSvc() { sudo rc-service "$1" start ;}
	elif type sv >> /dev/null 2>&1; then
		initSystem="runit"
		greprunitpkg(){ runitpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[Q][^,]*" | sed '/^W/d' | sed 's/^.*,//g' > "$runitpkg" ;}
		grepworkrunitpkg(){ runitworkpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[Q][^,]*" | sed 's/^.*,//g' > "$runitworkpkg" ;}
		enableSvc() { sudo ln -s /etc/sv/"$1" /var/service/ ;}
		startSvc() { sudo sv start "$1" ;}
	elif type s6-rc-bundle-update >> /dev/null 2>&1; then
		initSystem="s6"
		greps6pkg(){ s6pkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[6][^,]*" | sed '/^W/d' | sed 's/^.*,//g' > "$s6pkg" ;}
		grepworks6pkg(){ s6workpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[6][^,]*" | sed 's/^.*,//g' > "$s6workpkg" ;}
		enableSvc() { sudo s6-rc-bundle-update -c /etc/s6/rc/compiled add default "$1" ;}
		startSvc() { sudo s6-rc -u change "$1" ;}
	elif type 66-enable >> /dev/null 2>&1; then
		initSystem="suite66"
		greps6pkg(){ suite66pkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[7][^,]*" | sed '/^W/d' | sed 's/^.*,//g' > "$suite66pkg" ;}
		grepworks6pkg(){ suite66workpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[7][^,]*" | sed 's/^.*,//g' > "$suite66workpkg" ;}
		enableSvc() { sudo 66-enable -t default "$1" ;}
		startSvc() { sudo 66-start -t default "$1" ;}
	fi
fi

# List packages to install
grepaurpkg(){ aurpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[Y][^,]*" | sed '/^W/d' | sed 's/^.*,//g' > "$aurpkg" ;}
grepguipkg(){ guipkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[C][^,]*" | sed '/^W/d' | sed 's/^.*,//g' > "$guipkg" ;}
grepworkaurpkg(){ workaurpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[Y][^,]*" | sed 's/^.*,//g' > "$workaurpkg" ;}
grepworkguipkg(){ workguipkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[C][^,]*" | sed 's/^.*,//g' > "$workguipkg" ;}
grepstoreapp(){ if type mas > /dev/null 2>&1; then storeapp=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[S][^,]*" | sed '/^W/d' | sed 's/^.*,//g' | awk '{print $1}' > "$storeapp"; fi ;}
grepworkstoreapp(){ if type mas > /dev/null 2>&1; then workstoreapp=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[S][^,]*" | sed 's/^.*,//g' | awk '{print $1}' > "$workstoreapp"; fi ;}
grepgitrepo(){ if type git > /dev/null 2>&1; then repo=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[G][^,]*" | sed '/^W/d' | sed 's/^.*,//g' | awk '{print $1}' > "$repo"; fi ;}
grepworkgitrepo(){ if type git > /dev/null 2>&1; then	workrepo=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[G][^,]*" | sed 's/^.*,//g' | awk '{print $1}' > "$workrepo" ; fi ;}
grepsrvpkg(){ srvpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[I][^,]*" | sed 's/^.*,//g' > "$srvpkg" ;}
grepxpkg(){ archxpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[X][^,]*" | sed '/^W/d' | sed 's/^.*,//g' > "$archxpkg" ;}
grepvoidxpkg(){ voidxpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "V1[^,]*" | sed '/^W/d' | sed 's/^.*,//g' > "$voidxpkg" ;}

# Package managers
if type brew > /dev/null 2>&1; then
	greppkg(){ pkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[M][^,]*" | sed '/^W/d' | sed 's/^.*,//g' > "$pkg" ;}
	grepworkpkg(){ workpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[M][^,]*" | sed 's/^.*,//g' > "$workpkg" ;}
	update() { brew update 2>&1 | lognoc ;}
	install() { brew install "$@" 2>&1 | lognoc ;}
	installgui() { brew install --cask "$@" 2>&1 | lognoc ;}
	installvirtualbox(){ brew update 2>&1 | lognoc && brew install --cask virtualbox virtualbox-extension-pack 2>&1 | lognoc ;}
elif type apt-get > /dev/null 2>&1; then
	greppkg(){ pkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[D][^,]*" | sed '/^W/d' | sed 's/^.*,//g' > "$pkg" ;}
	grepworkpkg(){ workpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[D][^,]*" | sed 's/^.*,//g' > "$workpkg" ;}
	update() { sudo apt-get update 2>&1 | lognoc ;}
	install() { sudo apt-get install -y "$@" 2>&1 | lognoc ;}
	installvirtualbox(){
		update 2>&1 | lognoc && install virtualbox linux-headers 2>&1 | lognoc
		version=$(VBoxManage -v | sed 's/r[0-9a-b]*//') && wget "https://download.virtualbox.org/virtualbox/${version}/Oracle_VM_VirtualBox_Extension_Pack-${version}.vbox-extpack"
		yes | VBoxManage extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-"${version}".vbox-extpack && rm -f Oracle_VM_VirtualBox_Extension_Pack-"${version}".vbox-extpack
	}
	installkvm(){
		update 2>&1 | lognoc && install ebtables iptables qemu-kvm dmidecode libvirt-clients libvirt-daemon-system bridge-utils virtinst libvirt-daemon virt-manager 2>&1 | lognoc
		if [[ "$initSystem" == "openrc" ]]; then install libvirt-openrc 2>&1 | lognoc; fi
		if [[ "$initSystem" == "runit" ]]; then install libvirt-runit 2>&1 | lognoc; fi
		if [[ "$initSystem" == "s6" ]]; then install libvirt-s6 2>&1 | lognoc; fi
		if [[ "$initSystem" == "suite66" ]]; then install libvirt-suite66 2>&1 | lognoc; fi
		enableSvc libvirtd 2>&1 | lognoc && startSvc libvirtd 2>&1 | lognoc
		sudo usermod -a -G libvirt "$(whoami)" 2>&1 | lognoc && sudo usermod -a -G libvirt-qemu "$(whoami)" 2>&1 | lognoc
	}
elif type yum > /dev/null 2>&1; then
	greppkg(){ pkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[R][^,]*" | sed '/^W/d' | sed 's/^.*,//g' > "$pkg" ;}
	grepworkpkg(){ workpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[R][^,]*" | sed 's/^.*,//g' > "$workpkg" ;}
	update() { sudo yum update -y 2>&1 | lognoc ;}
	install() { sudo yum install -y "$@" 2>&1 | lognoc ;}
	installvirtualbox(){
		update 2>&1 | lognoc && install VirtualBox linux-headers 2>&1 | lognoc
		version=$(VBoxManage -v | sed 's/r[0-9a-b]*//') && wget "https://download.virtualbox.org/virtualbox/${version}/Oracle_VM_VirtualBox_Extension_Pack-${version}.vbox-extpack"
		yes | VBoxManage extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-"${version}".vbox-extpack && rm -f Oracle_VM_VirtualBox_Extension_Pack-"${version}".vbox-extpack
	}
	installkvm(){
		update 2>&1 | lognoc && install dmidecode qemu-kvm libvirt libvirt-python libguestfs-tools virt-install ebtables iptables 2>&1 | lognoc
		if [[ "$initSystem" == "openrc" ]]; then install libvirt-openrc 2>&1 | lognoc; fi
		if [[ "$initSystem" == "runit" ]]; then install libvirt-runit 2>&1 | lognoc; fi
		if [[ "$initSystem" == "s6" ]]; then install libvirt-s6 2>&1 | lognoc; fi
		if [[ "$initSystem" == "suite66" ]]; then install libvirt-suite66 2>&1 | lognoc; fi
		enableSvc libvirtd 2>&1 | lognoc && startSvc libvirtd 2>&1 | lognoc
	}
elif type pacman yay > /dev/null 2>&1; then
	greppkg(){ pkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[A][^,]*" | sed '/^W/d' | sed 's/^.*,//g' > "$pkg" ;}
	grepworkpkg(){ workpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[A][^,]*" | sed 's/^.*,//g' > "$workpkg" ;}
	update() { sudo pacman -Syu --noconfirm 2>&1 | lognoc ;}
	install() { sudo pacman -S "$@" --needed --noconfirm --ask 4 2>&1 | lognoc ;}
	installaur() { yes | yay --cleanafter --nodiffmenu --noprovides --removemake --noconfirm --needed -S "$@" 2>&1 | lognoc ;}
	installaurconfirm() { yes | yay --cleanafter --nodiffmenu --noprovides --removemake --needed -S "$@" 2>&1 | lognoc ;}
	installvirtualbox(){
		update 2>&1 | lognoc && install virtualbox linux-headers 2>&1 | lognoc
		installaur virtualbox-ext-oracle 2>&1 | lognoc
	}
	installkvm(){
		update 2>&1 | lognoc && install qemu dmidecode virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat iptables-nft libguestfs 2>&1 | lognoc
		sudo sed -i 's/^#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/' /etc/libvirt/libvirtd.conf 2>&1 | lognoc
		sudo sed -i 's/^#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/' /etc/libvirt/libvirtd.conf 2>&1 | lognoc
		sudo usermod -a -G libvirt "$(whoami)" 2>&1 | lognoc
		if [[ "$initSystem" == "openrc" ]]; then install libvirt-openrc 2>&1 | lognoc; fi
		if [[ "$initSystem" == "runit" ]]; then install libvirt-runit 2>&1 | lognoc; fi
		if [[ "$initSystem" == "s6" ]]; then install libvirt-s6 2>&1 | lognoc; fi
		if [[ "$initSystem" == "suite66" ]]; then install libvirt-suite66 2>&1 | lognoc; fi
		enableSvc libvirtd 2>&1 | lognoc && startSvc libvirtd 2>&1 | lognoc
	}
	setupcustomrepos(){
		if [[ -f /etc/artix-release ]]; then
			# Arch Linux repos for Artix
			sudo pacman -S --needed --noconfirm artix-archlinux-support 2>&1 | lognoc
			sudo pacman-key --populate archlinux 2>&1 | lognoc
			if ! grep '^Include = \/etc\/pacman\.d\/mirrorlist-arch' /etc/pacman.conf > /dev/null 2>&1; then
				sudo tee -a /etc/pacman.conf <<-'EOF' >/dev/null
				# ARCHLINUX REPOS
				[extra]
				Include = /etc/pacman.d/mirrorlist-arch

				[community]
				Include = /etc/pacman.d/mirrorlist-arch

				#[multilib]
				#Include = /etc/pacman.d/mirrorlist-arch
				EOF
			fi
		fi
		# Pritunl
		if ! grep '^\[pritunl\]' /etc/pacman.conf > /dev/null 2>&1; then
			sudo tee -a /etc/pacman.conf <<-'EOF' >/dev/null
			[pritunl]
			Server = https://repo.pritunl.com/stable/pacman
			EOF
		sudo pacman-key --keyserver hkp://keyserver.ubuntu.com -r 7568D9BB55FF9E5287D586017AE645C0CF8E292A > /dev/null 2>&1 | lognoc
		sudo pacman-key --lsign-key 7568D9BB55FF9E5287D586017AE645C0CF8E292A > /dev/null 2>&1 | lognoc
		fi
		# Spotify (see https://aur.archlinux.org/packages/spotify/ if key import failed)
		curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | gpg --import - > /dev/null 2>&1 | lognoc
	}
elif type pacman > /dev/null 2>&1; then
	greppkg(){ pkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[A][^,]*" | sed '/^W/d' | sed 's/^.*,//g' > "$pkg" ;}
	grepworkpkg(){ workpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[A][^,]*" | sed 's/^.*,//g' > "$workpkg" ;}
	update() { sudo pacman -Syu --noconfirm 2>&1 | lognoc ;}
	install() { sudo pacman -S "$@" --needed --noconfirm --ask 4 2>&1 | lognoc ;}
	installvirtualbox(){
		update 2>&1 | lognoc && install virtualbox linux-headers 2>&1 | lognoc
		version=$(VBoxManage -v | sed 's/r[0-9a-b]*//') && wget "https://download.virtualbox.org/virtualbox/${version}/Oracle_VM_VirtualBox_Extension_Pack-${version}.vbox-extpack"
		yes | VBoxManage extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-"${version}".vbox-extpack && rm -f Oracle_VM_VirtualBox_Extension_Pack-"${version}".vbox-extpack
	}
	installkvm(){
		update 2>&1 | lognoc && install qemu dmidecode virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat iptables-nft libguestfs 2>&1 | lognoc
		sudo sed -i 's/^#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/' /etc/libvirt/libvirtd.conf 2>&1 | lognoc
		sudo sed -i 's/^#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/' /etc/libvirt/libvirtd.conf 2>&1 | lognoc
		sudo usermod -a -G libvirt "$(whoami)" 2>&1 | lognoc
		if [[ "$initSystem" == "openrc" ]]; then install libvirt-openrc 2>&1 | lognoc; fi
		if [[ "$initSystem" == "runit" ]]; then install libvirt-runit 2>&1 | lognoc; fi
		if [[ "$initSystem" == "s6" ]]; then install libvirt-s6 2>&1 | lognoc; fi
		if [[ "$initSystem" == "suite66" ]]; then install libvirt-suite66 2>&1 | lognoc; fi
		enableSvc libvirtd 2>&1 | lognoc && startSvc libvirtd 2>&1 | lognoc
	}
	setupcustomrepos(){
		if [[ -f /etc/artix-release ]]; then
			# Arch Linux repos for Artix
			sudo pacman -S --needed --noconfirm artix-archlinux-support 2>&1 | lognoc
			sudo pacman-key --populate archlinux 2>&1 | lognoc
			if ! grep '^Include = \/etc\/pacman\.d\/mirrorlist-arch' /etc/pacman.conf > /dev/null 2>&1; then
				sudo tee -a /etc/pacman.conf <<-'EOF' >/dev/null
				# ARCHLINUX REPOS
				[extra]
				Include = /etc/pacman.d/mirrorlist-arch

				[community]
				Include = /etc/pacman.d/mirrorlist-arch

				#[multilib]
				#Include = /etc/pacman.d/mirrorlist-arch
				EOF
			fi
		fi
		# Pritunl
		if ! grep '^\[pritunl\]' /etc/pacman.conf > /dev/null 2>&1; then
			sudo tee -a /etc/pacman.conf <<-'EOF' >/dev/null
			[pritunl]
			Server = https://repo.pritunl.com/stable/pacman
			EOF
		sudo pacman-key --keyserver hkp://keyserver.ubuntu.com -r 7568D9BB55FF9E5287D586017AE645C0CF8E292A > /dev/null 2>&1 | lognoc
		sudo pacman-key --lsign-key 7568D9BB55FF9E5287D586017AE645C0CF8E292A > /dev/null 2>&1 | lognoc
		fi
		# Spotify (see https://aur.archlinux.org/packages/spotify/ if key import failed)
		curl -sS https://download.spotify.com/debian/pubkey_0D811D58.gpg | gpg --import - > /dev/null 2>&1 | lognoc
	}
elif type xbps-install > /dev/null 2>&1; then
	greppkg(){ pkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[V][^,]*" | sed '/^W/d' | sed 's/^.*,//g' > "$pkg" ;}
	grepworkpkg(){ workpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[V][^,]*" | sed 's/^.*,//g' > "$workpkg" ;}
	update() { sudo xbps-install -Syu 2>&1 | lognoc ;}
	install() { sudo xbps-install -Sy "$@" 2>&1 | lognoc ;}
	installvirtualbox(){
		update 2>&1 | lognoc && install virtualbox-ose linux-headers 2>&1 | lognoc
		version=$(VBoxManage -v | sed 's/r[0-9a-b]*//') && wget "https://download.virtualbox.org/virtualbox/${version}/Oracle_VM_VirtualBox_Extension_Pack-${version}.vbox-extpack"
		yes | VBoxManage extpack install --replace Oracle_VM_VirtualBox_Extension_Pack-"${version}".vbox-extpack && rm -f Oracle_VM_VirtualBox_Extension_Pack-"${version}".vbox-extpack
	}
	installkvm(){
		update 2>&1 | lognoc && install qemu dmidecode virt-manager virt-viewer dnsmasq vde2 bridge-utils openbsd-netcat iptables-nft libguestfs 2>&1 | lognoc
		sudo sed -i 's/^#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/' /etc/libvirt/libvirtd.conf 2>&1 | lognoc
		sudo sed -i 's/^#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/' /etc/libvirt/libvirtd.conf 2>&1 | lognoc
		sudo usermod -a -G libvirt "$(whoami)" 2>&1 | lognoc
		if [[ "$initSystem" == "openrc" ]]; then install libvirt-openrc 2>&1 | lognoc; fi
		if [[ "$initSystem" == "runit" ]]; then install libvirt-runit 2>&1 | lognoc; fi
		if [[ "$initSystem" == "s6" ]]; then install libvirt-s6 2>&1 | lognoc; fi
		if [[ "$initSystem" == "suite66" ]]; then install libvirt-suite66 2>&1 | lognoc; fi
		enableSvc libvirtd 2>&1 | lognoc && startSvc libvirtd 2>&1 | lognoc
	}
fi

# Install packages
installsrvpkg(){ update 2>&1 | lognoc && while IFS= read -r line; do install "$line" 2>&1 | lognoc; done < "$srvpkg" ;}
installstoreapp(){ if type mas > /dev/null 2>&1; then < "$storeapp" xargs mas install 2>&1 | lognoc; fi ;}
installworkstoreapp(){ if type mas > /dev/null 2>&1; then < "$workstoreapp" xargs mas install 2>&1 | lognoc; fi ;}
installsudo(){ update 2>&1 | lognoc && install sudo 2>&1 | lognoc ;}
installpkg(){ update && while IFS= read -r line; do install "$line" 2>&1 | lognoc; done < "$pkg" ;}
installguipkg(){ update 2>&1 | lognoc && while IFS= read -r line; do installgui "$line" 2>&1 | lognoc; done < "$guipkg" ;}
installworkpkg(){ update 2>&1 | lognoc && while IFS= read -r line; do install "$line" 2>&1 | lognoc; done < "$workpkg" ;}
installworkguipkg(){ update 2>&1 | lognoc && while IFS= read -r line; do install "$line" 2>&1 | lognoc; done < "$workguipkg" ;}
installaurpkg(){ while IFS= read -r line; do installaur "$line" 2>&1 | lognoc; done < "$aurpkg" ;}
installworkaurpkg(){ while IFS= read -r line; do installaur "$line" 2>&1 | lognoc; done < "$workaurpkg" ;}
installxpkg(){ update 2>&1 | lognoc && while IFS= read -r line; do install "$line" 2>&1 | lognoc; done < "$archxpkg" ;}
installvoidxpkg(){ update 2>&1 | lognoc && enableSvc dbus 2>&1 | lognoc && while IFS= read -r line; do install "$line" 2>&1 | lognoc; done < "$voidxpkg" ;}
installlibxftbgra(){ update 2>&1 | lognoc && yes | installaurconfirm libxft-bgra 2>&1 | lognoc ;}
installjetbrainsmono(){ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/install_manual.sh)" ;}
installgitrepo(){ if [[ ! -d "$gitrepoloc" ]]; then mkdir -pv "$gitrepoloc" > /dev/null 2>&1; fi && if type git > /dev/null 2>&1; then < "$repo" xargs -n1 -I url git -C "$gitrepoloc" clone --depth 1 url 2>&1 | lognoc; fi ;}
installworkgitrepo(){ if [[ ! -d "$gitrepoloc" ]]; then mkdir -pv "$gitrepoloc" > /dev/null 2>&1; fi && if type git > /dev/null 2>&1; then < "$workrepo" xargs -n1 -I url git -C "$gitrepoloc" clone --depth 1 url 2>&1 | lognoc; fi ;}
if [[ "$initSystem" == "openrc" ]]; then
	installopenrcpkg(){ update 2>&1 | lognoc && while IFS= read -r line; do install "$line" 2>&1 | lognoc; done < "$openrcpkg" ;}
	installopenrcworkpkg(){ update 2>&1 | lognoc && while IFS= read -r line; do install "$line" 2>&1 | lognoc; done < "$openrcworkpkg" ;}
elif [[ "$initSystem" == "runit" ]]; then
	installrunitpkg(){ update 2>&1 | lognoc && while IFS= read -r line; do install "$line" 2>&1 | lognoc; done < "$runitpkg" ;}
	installrunitworkpkg(){ update 2>&1 | lognoc && while IFS= read -r line; do install "$line" 2>&1 | lognoc; done < "$runitworkpkg" ;}
elif [[ "$initSystem" == "s6" ]]; then
	installrunitpkg(){ update 2>&1 | lognoc && while IFS= read -r line; do install "$line" 2>&1 | lognoc; done < "$s6pkg" ;}
	installrunitworkpkg(){ update 2>&1 | lognoc && while IFS= read -r line; do install "$line" 2>&1 | lognoc; done < "$s6workpkg" ;}
elif [[ "$initSystem" == "suite66" ]]; then
	installrunitpkg(){ update 2>&1 | lognoc && while IFS= read -r line; do install "$line" 2>&1 | lognoc; done < "$suite66pkg" ;}
	installrunitworkpkg(){ update 2>&1 | lognoc && while IFS= read -r line; do install "$line" 2>&1 | lognoc; done < "$suite66workpkg" ;}
fi
installzsh() {
	install zsh 2>&1 | lognoc
	if [[ "$OSTYPE" == "darwin"* ]]; then
		chmod g-w "$(brew --prefix)/share" 2>&1 | lognoc
		chmod g-w "$(brew --prefix)/share/zsh" 2>&1 | lognoc
		chmod g-w "$(brew --prefix)/share/zsh/sites-functions" 2>&1 | lognoc
	else
		update 2>&1 | lognoc && install zsh 2>&1 | lognoc
	fi
	git clone --depth 1 https://github.com/zplug/zplug "$HOME"/.config/zsh/zplug 2>&1 | lognoc
}
installvideodriver(){
	case "$(lspci -v | grep -A1 -e VGA -e 3D)" in
		*NVIDIA*) install xf86-video-nouveau 2>&1 | lognoc ;;
		*AMD*) install xf86-video-amdgpu 2>&1 | lognoc ;;
		*Intel*) install xf86-video-intel 2>&1 | lognoc ;;
		*) install xf86-video-fbdev 2>&1 | lognoc ;;
	esac
}
installperldeps(){
	perlx=$(find "$gitrepoloc" -maxdepth 3 -perm -111 -type f -name '*.pl')
	# Nikto
	if [[ "$perlx" =~ nikto.pl ]]; then
		if ! perl -MNet::SSLeay -e 1 > /dev/null 2>&1; then
			if type apt-get > /dev/null 2>&1; then
				update 2>&1 | lognoc && install libnet-ssleay-perl 2>&1 | lognoc
			elif type cpanm > /dev/null 2>&1; then
				# sudo cpanm --force Net::SSLeay 2>&1 | lognoc
				sudo cpanm Net::SSLeay 2>&1 | lognoc
			fi
		fi
	fi
}
installpythondeps(){
	pythonx=$(find "$gitrepoloc" -maxdepth 3 -perm -111 -type f -name '*.py')
	# VxAPI
	if type pip > /dev/null 2>&1 && [[ "$pythonx" =~ vxapi.py ]]; then
		pip install requests colorama 2>&1 | lognoc
	fi
}
setupkeyring(){
	if ! grep '^auth[ \t]*optional[ \t]*pam_gnome_keyring.so$' /etc/pam.d/login > /dev/null 2>&1; then
		sudo awk -i inplace 'FNR==NR{ if (/auth/) p=NR; next} 1; FNR==p{ print "auth       optional     pam_gnome_keyring.so" }' /etc/pam.d/login /etc/pam.d/login 2>&1 | lognoc
	fi
	if ! grep '^session[ \t]*optional[ \t]*pam_gnome_keyring.so auto_start$' /etc/pam.d/login > /dev/null 2>&1; then
		sudo awk -i inplace 'FNR==NR{ if (/session/) p=NR; next} 1; FNR==p{ print "session    optional     pam_gnome_keyring.so auto_start" }' /etc/pam.d/login /etc/pam.d/login 2>&1 | lognoc
	fi
}
installxinitrc(){
	if [[ -f "$HOME"/.xinitrc ]]; then
		if [[ ! -d "$dfloc" ]]; then git clone --depth 1 "$dfrepo" "$dfloc" 2>&1 | lognoc ; else git -C "$dfloc" pull 2>&1 | lognoc ; fi
    	mv "$HOME"/.xinitrc "$HOME"/.xinitrc.orig > /dev/null 2>&1
    	ln -sf "$dfloc"/config/X11/xinitrc "$HOME"/.xinitrc 2>&1 | lognoc
    else
		if [[ ! -d "$dfloc" ]]; then git clone --depth 1 "$dfrepo" "$dfloc" 2>&1 | lognoc ; else git -C "$dfloc" pull 2>&1 | lognoc ; fi
    	ln -sf "$dfloc"/config/X11/xinitrc "$HOME"/.xinitrc 2>&1 | lognoc
	fi
}
installgreeter(){
	install lightdm lightdm-gtk-greeter 2>&1 | lognoc
	if [[ "$initSystem" == "openrc" ]]; then install lightdm-openrc 2>&1 | lognoc; fi
	if [[ "$initSystem" == "runit" ]]; then install lightdm-runit 2>&1 | lognoc; fi
	if [[ "$initSystem" == "s6" ]]; then install lightdm-s6 2>&1 | lognoc; fi
	if [[ "$initSystem" == "suite66" ]]; then install lightdm-suite66 2>&1 | lognoc; fi
	if [[ -f "$HOME"/.xprofile ]]; then
		if [[ ! -d "$dfloc" ]]; then git clone --depth 1 "$dfrepo" "$dfloc" 2>&1 | lognoc ; else git -C "$dfloc" pull 2>&1 | lognoc ; fi
    	mv "$HOME"/.xprofile "$HOME"/.xprofile.orig > /dev/null 2>&1
    	ln -sf "$dfloc"/config/X11/xprofile "$HOME"/.xprofile 2>&1 | lognoc
    else
		if [[ ! -d "$dfloc" ]]; then git clone --depth 1 "$dfrepo" "$dfloc" 2>&1 | lognoc ; else git -C "$dfloc" pull 2>&1 | lognoc ; fi
    	ln -sf "$dfloc"/config/X11/xprofile "$HOME"/.xprofile 2>&1 | lognoc
	fi
	sudo cp -f "$dfloc"/config/X11/lightdm/* /etc/lightdm/ 2>&1 | lognoc
	if [[ -f "$HOME"/.xprofile ]]; then enableSvc lightdm 2>&1 | lognoc ; fi
}
installdwm(){
	if [[ -d "$dwmloc" ]]; then sudo rm -Rf "$dwmloc" > /dev/null 2>&1 ; fi
	sudo git clone --depth 1 "$dwmrepo" "$dwmloc" > /dev/null 2>&1
	sudo make -C "$dwmloc" clean install > /dev/null 2>&1
	if [[ ! -d /usr/share/xsessions ]]; then sudo mkdir -pv /usr/share/xsessions > /dev/null 2>&1 ; fi
	if [[ -d /usr/share/xbps.d ]]; then
		sudo cp -rf "$dwmloc"/statusbar-txt/* /usr/local/sbin/ > /dev/null 2>&1
	else
		sudo cp -rf "$dwmloc"/statusbar/* /usr/local/sbin/ > /dev/null 2>&1
	fi
	sudo cp -f "$dwmloc"/dwm.desktop /usr/share/xsessions/ > /dev/null 2>&1
}
installdmenu(){
	if [[ -d "$dmenuloc" ]]; then sudo rm -Rf "$dmenuloc" > /dev/null 2>&1 ; fi
	sudo git clone --depth 1 "$dmenurepo" "$dmenuloc" > /dev/null 2>&1
	sudo make -C "$dmenuloc" clean install > /dev/null 2>&1
}
installsent(){
	if [[ -d "$sentloc" ]]; then sudo rm -Rf "$sentloc" > /dev/null 2>&1; fi
	sudo git clone --depth 1 "$sentrepo" "$sentloc" > /dev/null 2>&1
	sudo make -C "$sentloc" clean install > /dev/null 2>&1
}
installst(){
	if [[ -d "$stloc" ]]; then sudo rm -Rf "$stloc" > /dev/null 2>&1; fi
	sudo git clone --depth 1 "$strepo" "$stloc" > /dev/null 2>&1
	sudo make -C "$stloc" clean install > /dev/null 2>&1
	sudo cp -f "$stloc"/st-* /usr/local/sbin/ > /dev/null 2>&1
	sudo cp -f "$stloc"/st.desktop /usr/share/applications/ > /dev/null 2>&1
}
installslock(){
	if [[ -d "$slockloc" ]]; then sudo rm -Rf "$slockloc" > /dev/null 2>&1; fi
	sudo git clone --depth 1 "$slockrepo" "$slockloc" > /dev/null 2>&1
	sudo make -C "$slockloc" clean install > /dev/null 2>&1
}
installsurf(){
	if [[ -d "$surfloc" ]]; then sudo rm -Rf "$surfloc" > /dev/null 2>&1; fi
	sudo git clone --depth 1 "$surfrepo" "$surfloc" > /dev/null 2>&1
	if [[ ! -d "$HOME"/.config/surf/styles ]]; then mkdir -pv "$HOME"/.config/surf/styles > /dev/null 2>&1; fi
	cp "$surfloc"/script.js "$HOME"/.config/surf/ > /dev/null 2>&1
	cp -R "$surfloc"/styles/*.css "$HOME"/.config/surf/styles/ > /dev/null 2>&1
	sudo make -C "$surfloc" clean install > /dev/null 2>&1
}
installbspwm(){
	if [[ -d /usr/share/xbps.d ]]; then install bspwm sxhkd polybar 2>&1 | lognoc ; fi
	install bspwm sxhkd 2>&1 | lognoc
	if ! pacman -Q polybar >/dev/null 2>&1; then yes "" | installaur polybar 2>&1 | lognoc ; fi
	if [[ ! -d "$dfloc" ]]; then git clone --depth 1 "$dfrepo" "$dfloc" > /dev/null 2>&1 ; fi
	if [[ ! -d "$HOME"/.config/bspwm ]]; then mkdir -pv "$HOME"/.config/bspwm > /dev/null 2>&1 ; fi
	if [[ ! -d "$HOME"/.config/sxhkd ]]; then mkdir -pv "$HOME"/.config/sxhkd > /dev/null 2>&1 ; fi
	ln -sf "$dfloc"/config/bspwm/* "$HOME"/.config/bspwm/ > /dev/null 2>&1
	ln -sf "$dfloc"/config/sxhkd/* "$HOME"/.config/sxhkd/ > /dev/null 2>&1
}
installi3(){
	if [[ -d /usr/share/xbps.d ]]; then install i3-gaps polybar 2>&1 | lognoc ; fi
	install i3-gaps 2>&1 | lognoc
	if ! pacman -Q polybar >/dev/null 2>&1; then yes "" | installaur polybar 2>&1 | lognoc ; fi
	if [[ ! -d "$dfloc" ]]; then git clone --depth 1 "$dfrepo" "$dfloc" > /dev/null 2>&1 ; fi
	if [[ ! -d "$HOME"/.config/i3 ]]; then mkdir -pv "$HOME"/.config/i3 > /dev/null 2>&1 ; fi
	ln -sf "$dfloc"/config/i3/* "$HOME"/.config/i3/ > /dev/null 2>&1
}
installopenbox(){
	install openbox menumaker tint2 2>&1 | lognoc
	yes "" | installaur arc-dark-osx-openbox-theme-git 2>&1 | lognoc
	if [[ ! -d "$dfloc" ]]; then git clone --depth 1 "$dfrepo" "$dfloc" > /dev/null 2>&1 ; fi
	if [[ ! -d "$HOME"/.config/tint2 ]]; then mkdir -pv "$HOME"/.config/tint2 > /dev/null 2>&1 ; fi
	ln -sf "$dfloc"/config/tint2/tint2rc "$HOME"/.config/tint2/ > /dev/null 2>&1
	ln -sf "$dfloc"/config/openbox "$HOME"/.config/ > /dev/null 2>&1
}
installxfce(){
	install xfce4 2>&1 | lognoc
	yes "" | installaur pamac-aur 2>&1 | lognoc
	if [[ ! -d "$dfloc" ]]; then git clone --depth 1 "$dfrepo" "$dfloc" > /dev/null 2>&1 ; fi
	ln -sf "$dfloc"/config/xfce4 "$HOME"/.config/ 2>&1 | lognoc
	while read -p "Do you want to install the XFCE goodies/applications? (Y/n) " -n 1 -r; do
		echo -e 2>&1 | logc
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then
			echo -e "Installing XFCE goodies..." 2>&1 | logc
			if [[ -d /usr/share/xbps.d ]]; then install xfce4-plugins 2>&1 | lognoc ; fi
			install xfce4-goodies 2>&1 | lognoc
			echo -e "XFCE goodies installed" 2>&1 | logc
			break
		elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
			echo -e 2>&1 | logc
			break
		fi
		break
	done
}
installgnome(){
	install gnome gnome-tweaks 2>&1 | lognoc
	yes "" | installaur pamac-aur 2>&1 | lognoc
	if [[ "$initSystem" == "openrc" ]]; then install gdm-openrc 2>&1 | lognoc; fi
	if [[ "$initSystem" == "runit" ]]; then install gdm-runit 2>&1 | lognoc; fi
	if [[ "$initSystem" == "s6" ]]; then install gdm-s6 2>&1 | lognoc; fi
	if [[ "$initSystem" == "suite66" ]]; then install gdm-suite66 2>&1 | lognoc; fi
	enableSvc gdm -f 2>&1 | lognoc
	while read -p "Do you want to install extra applications for GNOME (email client, Web browser, etc...)? (Y/n) " -n 1 -r; do
		echo -e 2>&1 | logc
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then
			echo -e "Installing GNOME extra applications..." 2>&1 | logc
			if [[ -d /usr/share/xbps.d ]]; then install gnome-apps 2>&1 | lognoc ; fi
			install gnome-extra 2>&1 | lognoc
			echo -e "GNOME extra applications installed" 2>&1 | logc
			break
		elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
			break
		fi
		break
	done
}
installkdeplasma(){
	if [[ -d /usr/share/xbps.d ]]; then install kde5 2>&1 | lognoc ; fi
	install plasma sddm sddm-kcm 2>&1 | lognoc
	yes "" | installaur pamac-aur 2>&1 | lognoc
	if [[ "$initSystem" == "openrc" ]]; then install sddm-openrc 2>&1 | lognoc; fi
	if [[ "$initSystem" == "runit" ]]; then install sddm-runit 2>&1 | lognoc; fi
	if [[ "$initSystem" == "s6" ]]; then install sddm-s6 2>&1 | lognoc; fi
	if [[ "$initSystem" == "suite66" ]]; then install sddm-suite66 2>&1 | lognoc; fi
	installdmenu && installst && installsurf
	enableSvc sddm -f 2>&1 | lognoc
	while read -p "Do you want to install the KDE applications? (Y/n) " -n 1 -r; do
		echo -e 2>&1 | logc
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then
			echo -e "Installing KDE applications..." 2>&1 | logc
			if [[ -d /usr/share/xbps.d ]]; then install kde5-baseapps 2>&1 | lognoc ; fi
			install kde-applications 2>&1 | lognoc
			echo -e "KDE applications installed" 2>&1 | logc
			break
		elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
			break
		fi
		break
	done
}

setupmdns(){
	if ! grep 'mdns_' /etc/nsswitch.conf > /dev/null 2>&1; then
		sudo sed -i 's/resolve /resolve mdns_minimal /' /etc/nsswitch.conf
	fi
}

# Servers
if { [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]] ;} && [[ "$OSTYPE" == 'linux-gnu' ]]; then
	if [[ "$EUID" = 0 ]]; then
		installsrvpkg
	elif ! type sudo > /dev/null 2>&1; then
		echo -e "Make sure to run this script as sudo to install useful tools!" 2>&1 | logc
		exit 1
	else
		installsrvpkg
	fi
fi

#=======================
# BEGINNING
#=======================
echo -e
echo -e "============================= BOOTSTRAP PROCESS BEGINNING =============================" 2>&1 | logc
echo -e "" 2>&1 | logc
echo -e " The file \"$logfile\" will be created to log all ongoing operations" 2>&1 | logc
echo -e " If the script gives an error because of user rights, please follow the instructions" 2>&1 | logc
echo -e "" 2>&1 | logc
echo -e "=======================================================================================" 2>&1 | logc
echo -e 2>&1 | logc
echo -e 2>&1 | logc

#======================
# Linux - Install 'sudo' (Requirement)
#======================
if [[ "$OSTYPE" == "linux-gnu" ]] && ! type sudo > /dev/null 2>&1; then
	echo -e "The package 'sudo' is not installed on the system" 2>&1 | logc
	echo -e "Installing 'sudo'..." 2>&1 | logc
	if [[ "$EUID" != 0 ]]; then
		echo -e "Please run the script as root in order to install the requirements" 2>&1 | logc
		exit 1
	else
		if type apt-get > /dev/null 2>&1; then
			apt-get update 2>&1 | lognoc
			apt-get install -y sudo 2>&1 | lognoc
		elif type yum > /dev/null 2>&1; then
			yum update -y 2>&1 | lognoc
			yum install -y sudo 2>&1 | lognoc
		elif type pacman > /dev/null 2>&1; then
			pacman -Sy 2>&1 | lognoc
			pacman -S sudo --needed --noconfirm 2>&1 | lognoc
		elif type xbps-install > /dev/null 2>&1; then
			xbps-install -Syu 2>&1 | lognoc
			xbps-install -y sudo 2>&1 | lognoc
		fi
		if ! grep '^\%wheel ALL=(ALL) ALL' /etc/sudoers > /dev/null 2>&1 && ! grep '^\%sudo ALL=(ALL) ALL' /etc/sudoers; then
			if grep '^\@includedir /etc/sudoers.d' /etc/sudoers > /dev/null 2>&1; then
				if [[ ! -d /etc/sudoers.d ]]; then mkdir -pv /etc/sudoers.d 2>&1 | lognoc; fi
				touch /etc/sudoers.d/99-wheel && echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/99-wheel
			else
				sed -i 's/^#\ \%wheel ALL=(ALL) ALL/\%wheel ALL=(ALL) ALL/' /etc/sudoers
			fi
		fi
		echo -e "Package 'sudo' is now installed" 2>&1 | logc
		echo -e "The 'sudo' configuration can be modified with the command \"visudo\"" 2>&1 | logc
		echo -e 2>&1 | logc
	fi
fi
if [[ "$OSTYPE" == "linux-gnu" ]] && [[ "$EUID" == 0 ]]; then
	echo -e "You are currently logged in as 'root'" 2>&1 | logc
	while read -p "Do you want to create a user account (it will be given SUDO privilege)? (Y/n) " -n 1 -r; do
		echo -e 2>&1 | logc
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then
			while read -p "What will be your username? " -r user; do
				if ! grep '^\%wheel ALL=(ALL) ALL' /etc/sudoers > /dev/null 2>&1 && ! grep '^\%sudo ALL=(ALL) ALL' /etc/sudoers > /dev/null 2>&1; then
					if grep '^\@includedir /etc/sudoers.d' /etc/sudoers > /dev/null 2>&1; then
						if [[ ! -d /etc/sudoers.d ]]; then mkdir -pv /etc/sudoers.d 2>&1 | lognoc; fi
						touch /etc/sudoers.d/99-wheel && echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/99-wheel
					else
						sed -i 's/^#\ \%wheel ALL=(ALL) ALL/\%wheel ALL=(ALL) ALL/' /etc/sudoers
					fi
				fi
				if [[ "$user" =~ ^[a-zA-Z0-9-]{1,15}$ ]]; then
					useradd -m "$user" 2>&1 | lognoc
					usermod -a -G wheel "$user" 2>&1 | lognoc
					usermod -a -G sudo "$user" 2>&1 | lognoc
					echo -e "Enter the password for your new user: " 2>&1 | logc
					passwd "$user"
					echo -e 2>&1 | logc
				else
					echo -e "Invalid username! The name should only contain alphanumeric characters" 2>&1 | logc
					echo -e 2>&1 | logc
					continue
				fi
				break
			done
		elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
			echo -e 2>&1 | logc
			break
		fi
		break
	done
	echo -e "Please logout and login with your regular user. Then run this script again" 2>&1 | logc
	exit 0
fi

#======================
# macOS - Install XCode Command Line Tools (Requirement)
#======================
# Attempt headless installation
if [[ "$OSTYPE" == "darwin"* ]] && [[ ! -d /Library/Developer/CommandLineTools ]]; then
	TOUCH=$(which touch)
	echo -e "Searching online for the Command Line Tools" 2>&1 | logc

	# This temporary file prompts the 'softwareupdate' utility to list the Command Line Tools
	clt_placeholder="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
	sudo "$TOUCH" "$clt_placeholder" 2>&1 | logc

	clt_label_command="/usr/sbin/softwareupdate -l |
                  	  grep -B 1 -E 'Command Line Tools' |
                  	  awk -F'*' '/^ *\\*/ {print \$2}' |
                  	  sed -e 's/^ *Label: //' -e 's/^ *//' |
                  	  sort -V |
                  	  tail -n1"
	clt_label="$(printf "%s" "${1/"$'\n'"/}" "$(/bin/bash -c "$clt_label_command")")"

	if [[ -n "$clt_label" ]]; then
		echo -e "Installing $clt_label"
		sudo "/usr/sbin/softwareupdate" "-i" "$clt_label" 2>&1 | logc
		sudo "/bin/rm" "-f" "$clt_placeholder" 2>&1 | logc
		sudo "/usr/bin/xcode-select" "--switch" "/Library/Developer/CommandLineTools" 2>&1 | logc
	fi
fi

# Graphical installation if headless failed
if [[ "$OSTYPE" == "darwin"* ]] && [[ -n $(pgrep "Install Command Line Developer Tools") ]]; then
	echo -e "============== XCODE COMMAND LINE TOOLS ARE INSTALLING =============="
	echo -e ""
	echo -e " ATTENTION: XCode Command Line Tools installation is in progress"
	echo -e " Launch the bootstrap script again when the installation is finished"
	echo -e ""
	echo -e "====================================================================="
	exit 0
elif [[ "$OSTYPE" == "darwin"* ]] && [[ ! -d /Library/Developer/CommandLineTools ]]; then
	echo -e "============== XCODE COMMAND LINE TOOLS NOT INSTALLED =============="
	echo -e ""
	echo -e " ATTENTION: XCode Command Line Tools installation will begin"
	echo -e " Launch the bootstrap script again when the installation is finished"
	echo -e ""
	echo -e "====================================================================="
	xcode-select --install
	exit 1
fi

#======================
# macOS - Install Homebrew (Requirement)
#======================
if [[ "$OSTYPE" == "darwin"* ]] && ! type brew > /dev/null 2>&1; then
	if [[ "$EUID" = 0 ]]; then
		echo -e "Homebrew cannot be installed as root!" 2>&1 | logc
		exit 1
	else
		echo -e "Installing Homebrew..." 2>&1 | logc
		echo -e 2>&1 | logc
		/bin/bash -c "$(curl -fsSL "$homebrew")" 2>&1 | logc
		brew doctor 2>&1 | lognoc
		brew update 2>&1 | lognoc
		echo -e "Homebrew is now installed" 2>&1 | logc
		echo -e "Please run this script again to bootstrap your system" 2>&1 | logc
		exit 0
	fi
fi

#======================
# Arch Linux - Install AUR Helper (Requirement)
#======================
if [[ "$OSTYPE" == "linux-gnu" ]] && ! type yay > /dev/null 2>&1 && { [[ -f /etc/arch-release ]] || [[ -f /etc/artix-release ]] ;}; then
	while read -p "Do you want to install an AUR helper? (Y/n) " -n 1 -r; do
		echo -e 2>&1 | logc
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then
			if [[ "$EUID" = 0 ]]; then
				echo -e "This AUR helper cannot be installed as root!" 2>&1 | logc
				exit 1
			else
				if sudo -v > /dev/null 2>&1; then
					echo -e "Installing 'yay', an AUR helper..." 2>&1 | logc
					sudo pacman -Sy 2>&1 | lognoc
					sudo pacman -S git base-devel --needed --noconfirm 2>&1 | lognoc
					git clone --depth 1 "$aurhelper" "$HOME"/yay 2>&1 | lognoc
					cd "$HOME"/yay && makepkg -si 2>&1 | logc
					cd "$HOME" || exit
					rm -Rf "$HOME"/yay
					echo -e "AUR Helper successfully installed" 2>&1 | logc
					echo -e "Please run this script again to take AUR packages into account" 2>&1 | logc
					exit 0
				else
					echo -e "Your user is not a member of the sudoers group!" 2>&1 | logc
					echo -e "Please run this script with a user with sudo rights" 2>&1 | logc
					exit 1
				fi
			fi
			break
		elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
			echo -e
			break
		fi
	done
fi

#=======================
# Workstation - Configure Custom Repositories
#=======================
if [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]]; then
	while read -p "Do you want to configure 3rd party/custom repositories? (Y/n) " -n 1 -r; do
		echo -e 2>&1 | logc
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then
			echo -e "Configuring custom repositories..." 2>&1 | logc
			setupcustomrepos
			echo -e "Custom repositories configured" 2>&1 | logc
			echo -e 2>&1 | logc
			break
		elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
			echo -e
			break
		fi
	done
fi

#======================
# Workstation - Install Common Packages
#======================
if [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]]; then
	while read -p "Do you want to install common applications? (Y/n) " -n 1 -r; do
		echo -e 2>&1 | logc
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then
			echo -e "Installing common software..." 2>&1 | logc
			cd "$HOME" && curl -fsSLO "$applist" 2>&1 | lognoc
			if [[ "$OSTYPE" == "darwin"* ]]; then
				if [[ "$EUID" = 0 ]]; then
					echo -e "Common applications cannot be installed as root!" 2>&1 | logc
					echo -e "Please run this script as a normal user" 2>&1 | logc
					exit 1
				else
					greppkg && installpkg
					grepguipkg && installguipkg
					grepgitrepo && installgitrepo
				fi
				while read -p "Do you want to install App Store common applications? (Y/n) " -n 1 -r; do
					echo -e 2>&1 | logc
					if [[ "$REPLY" =~ ^[Yy]$ ]]; then
						echo -e "Installing App Store common applications..." 2>&1 | logc
						grepstoreapp && installstoreapp
						echo -e "App Store common applications installed" 2>&1 | logc
						break
					elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
						echo -e
						break
					fi
				done
			elif [[ "$OSTYPE" == "linux-gnu" ]]; then
				greppkg && installpkg && installsent
				grepgitrepo && installgitrepo
				if { [[ -f /etc/arch-release ]] || [[ -f /etc/artix-release ]] ;} && type yay > /dev/null 2>&1; then
					grepaurpkg && installaurpkg
				fi
			fi
			rm "$HOME"/apps.csv 2>&1 | lognoc
			echo -e "Common software installed" 2>&1 | logc
			echo -e 2>&1 | logc
			break
		elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
				echo -e
				break
		fi
	done
fi

#======================
# Workstation - Install Work Packages
#======================
if [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]]; then
	while read -p "Do you want to install work applications? (Y/n) " -n 1 -r; do
		echo -e 2>&1 | logc
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then
			echo -e "Installing work software..." 2>&1 | logc
			cd "$HOME" && curl -fsSLO "$applist" 2>&1 | lognoc
			if [[ "$OSTYPE" == "darwin"* ]]; then
				if [[ "$EUID" = 0 ]]; then
					echo -e "Work applications cannot be installed as root!" 2>&1 | logc
					echo -e "Please run this script as a normal user" 2>&1 | logc
					exit 1
				else
					grepworkpkg && installworkpkg
					grepworkguipkg && installworkguipkg
					grepworkgitrepo && installworkgitrepo
					if type mas > /dev/null 2>&1 || [[ -f /usr/local/bin/mas ]]; then
						while read -p "Do you want to install App Store work applications? (Y/n) " -n 1 -r; do
							echo -e 2>&1 | logc
							if [[ "$REPLY" =~ ^[Yy]$ ]]; then
								echo -e "Installing App Store work applications..." 2>&1 | logc
								grepworkstoreapp && installworkstoreapp
								echo -e "App Store work applications installed" 2>&1 | logc
								break
							elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
								echo -e
								break
							fi
						done
					fi
				fi
			elif [[ "$OSTYPE" == "linux-gnu" ]]; then
				grepworkpkg && installworkpkg
				if { [[ -f /etc/arch-release ]] || [[ -f /etc/artix-release ]] ;} && type yay > /dev/null 2>&1; then
					grepworkaurpkg && installworkaurpkg
					grepworkgitrepo && installworkgitrepo
				fi
			fi
			rm "$HOME"/apps.csv 2>&1 | lognoc
			echo -e "Work software installed" 2>&1 | logc
			echo -e 2>&1 | logc
			break
		elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
			echo -e
			break
		fi
	done
fi

#=====================
# Workstation - Install Fonts
#=====================
if { [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] ;} && type git > /dev/null 2>&1; then
	while read -p "Do you want to install custom fonts? (Y/n) " -n 1 -r; do
	echo -e 2>&1 | logc
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then
			echo -e "Installing custom fonts..." 2>&1 | logc
			if [[ "$EUID" = 0 ]]; then
				echo -e "Custom fonts cannot be installed as root!" 2>&1 | logc
				echo -e "Please run this script as a normal user" 2>&1 | logc
				exit 1
			else
				mkdir -pv "$HOME"/fonts 2>&1 | lognoc
				if type wget > /dev/null 2>&1; then
					wget -c --content-disposition -P "$HOME"/fonts/ "$symbols_nerd" 2>&1 | lognoc
					wget -c --content-disposition -P "$HOME"/fonts/ "$mononoki_regular" 2>&1 | lognoc
					wget -c --content-disposition -P "$HOME"/fonts/ "$mononoki_bold" 2>&1 | lognoc
					wget -c --content-disposition -P "$HOME"/fonts/ "$mononoki_italic" 2>&1 | lognoc
				elif type curl > /dev/null 2>&1; then
					cd "$HOME"/fonts || exit
					curl -fSLO "$symbols_nerd" 2>&1 | lognoc
					curl -fSLO "$mononoki_regular" 2>&1 | lognoc
					curl -fSLO "$mononoki_bold" 2>&1 | lognoc
					curl -fSLO "$mononoki_italic" 2>&1 | lognoc
					for i in *; do mv "$i" "$(echo "$i" | sed 's/%20/ /g')"; done
				fi
				if [[ "$OSTYPE" == "darwin"* ]]; then
					mv "$HOME"/fonts/*.ttf "$HOME"/Library/Fonts/ 2>&1 | lognoc
				elif [[ "$OSTYPE" == "linux-gnu" ]]; then
					if [[ ! -d /usr/share/fonts/TTF ]]; then
						sudo mkdir -pv /usr/share/fonts/TTF 2>&1 | lognoc
					fi
					if type fc-cache > /dev/null 2>&1; then
						sudo mv -n "$HOME"/fonts/*.ttf /usr/share/fonts/TTF/ && fc-cache -f -v 2>&1 | lognoc
					else
						echo -e "Please install a font configuration handler such as 'fontconfig'!" 2>&1 | logc
						exit 1
					fi
				fi
				echo -e 2>&1 | logc
				git clone --depth 1 "$powerline_fonts" "$HOME"/fonts_powerline 2>&1 | lognoc && "$HOME"/fonts_powerline/install.sh
				cd "$HOME" || exit
				rm -Rf "$HOME"/fonts* > /dev/null 2>&1
			fi
			echo -e "Custom fonts installed" 2>&1 | logc
			echo -e 2>&1 | logc
			break
		elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
			echo -e
			break
		fi
	done
fi

#=====================
# Install TMUX Plugin Manager
#=====================
if { [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] ;} && type tmux > /dev/null 2>&1; then
	if [[ -d "$HOME"/.config/tmux/plugins/tpm ]]; then
		while read -p "TMUX Plugin Manager (TPM) is already installed. Do you want to reinstall it? (Y/n) " -n 1 -r; do
			echo -e 2>&1 | logc
			if [[ "$REPLY" =~ ^[Yy]$ ]]; then
				echo -e "Reinstalling TMUX Plugin Manager..." 2>&1 | logc
				rm -Rf "$HOME"/.config/tmux/plugins/tpm
				git clone --depth 1 "$tpm" "$HOME"/.config/tmux/plugins/tpm 2>&1 | lognoc
				echo -e "TMUX Plugin Manager installed" 2>&1 | logc
				echo -e "In TMUX, press <PREFIX> + I to install plugins" 2>&1 | logc
				echo -e 2>&1 | logc
				break
			elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
				echo -e
				break
			fi
		done
	else
		while read -p "Do you want to handle TMUX plugins? (Y/n) " -n 1 -r; do
			echo -e 2>&1 | logc
			if [[ "$REPLY" =~ ^[Yy]$ ]]; then
				echo -e "Installing TMUX Plugin Manager..." 2>&1 | logc
				git clone --depth 1 "$tpm" "$HOME"/.config/tmux/plugins/tpm 2>&1 | lognoc
				echo -e "TMUX Plugin Manager installed" 2>&1 | logc
				echo -e "In TMUX, press <PREFIX> + I to install plugins" 2>&1 | logc
				echo -e 2>&1 | logc
				break
			elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
				echo -e
				break
			fi
		done
	fi
fi

#======================
# Install server packages
#======================
if { [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]] ;} && [[ "$OSTYPE" == 'linux-gnu' ]]; then
	while read -p "[SERVER SESSION DETECTED] Do you want to install useful tools? (Y/n) " -n 1 -r; do
		echo -e 2>&1 | logc
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then
			echo -e "Installing useful server tools..." 2>&1 | logc
			curl -fsSLO "$applist" 2>&1 | lognoc
			grepsrvpkg && installsrvpkg
			rm ./apps.csv 2>&1 | lognoc
			echo -e "Useful server tools installed" 2>&1 | logc
			echo -e 2>&1 | logc
			break
		elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
			echo -e
			break
		fi
	done
fi

#=====================
# Wallpapers
#=====================
if [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]]; then
	while read -p "Do you want to install a set of nice wallpapers? (Y/n) " -n 1 -r; do
		echo -e 2>&1 | logc
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then
			echo -e "Retrieving wallpapers..." 2>&1 | logc
			if [[ ! -d "$HOME/.local/share" ]]; then mkdir -pv "$HOME"/.local/share 2>&1 | lognoc; fi
			git clone --depth 1 "$wallpapers" "$wallpapersloc" 2>&1 | lognoc
			echo -e "Wallpapers installed" 2>&1 | logc
			echo -e "Wallpapers are stored in \"$wallpapersloc\"" 2>&1 | logc
			echo -e 2>&1 | logc
			break
		elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
			echo -e 2>&1 | logc
			break
		fi
	done
fi

#=====================
# macOS Workstation - Configuration
#=====================
if { [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] ;} && [[ "$OSTYPE" == "darwin"* ]]; then
	while read -p "Do you want to setup System Preferences? (Y/n) " -n 1 -r; do
		echo -e 2>&1 | logc
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then

			# Configure computer's name
			computername=$(scutil --get ComputerName)
			echo -e "Your current computer's name is \"$computername\"" 2>&1 | logc
			while read -p "Do you want to change the computer's name? (Y/n) " -n 1 -r; do
				if [[ "$REPLY" =~ ^[Yy]$ ]]; then
					while read -p "What name your computer should use? " -r name; do
						if [[ "$name" =~ ^[a-zA-Z0-9-]{1,15}$ ]]; then
							sudo scutil --set ComputerName "$name"
							sudo scutil --set LocalHostName "$name"
							sudo scutil --set HostName "$name"
							echo -e "Computer's name successfully changed" 2>&1 | logc
							echo -e 2>&1 | logc
							break
						else
							echo -e "Invalid computer name! The name should be between 1 and 15 characters and must not contain special characters except \"-\"" 2>&1 | logc
							echo -e 2>&1 | logc
							continue
						fi
					done
				break
				elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
					echo -e 2>&1 | logc
					break
				fi
			done

			# Close any open System Preferences panes, to prevent them from overriding
			# settings we’re about to change
			echo -e "Setting up system preferences..." 2>&1 | logc
			osascript -e 'tell application "System Preferences" to quit'

			# General
			defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark" # Enable Dark Mode
			defaults write NSGlobalDomain AppleHighlightColor -string "0.847059 0.847059 0.862745 Graphite" # Choose Graphite as the highlight color
			defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1 # Set the sidebar icon size to small
			# defaults write NSGlobalDomain _HIHideMenuBar -bool true # Auto-hide the menu bar

			# Disable screen saver
			defaults -currentHost write com.apple.screensaver idleTime -int 0

			# Disable creation of .DS_Store files
			defaults write com.apple.desktopservices DSDontWriteNetworkStores true

			# Dock
			defaults write com.apple.dock autohide -int 1 # Auto-hide the dock
			defaults write com.apple.dock largesize -int 55 # Dock size
			defaults write com.apple.dock magnification -int 1 # Enable magnification
			defaults write com.apple.dock mineffect -string "scale" # Set the window minimize effect to Scale
			defaults write com.apple.dock launchanim -int 0 # Disable launch animation
			defaults write com.apple.dock tilesize -int 38 # Set the icons size
			defaults write com.apple.dock show-recents -int 0 # Do not show recent apps
			defaults write com.apple.dock mru-spaces -int 0 # Do not rearrange workspaces

			# Mission Control
			defaults write com.apple.dock mru-spaces -int 0 # Do not rearrange workspaces automatically by recent use

			# Trackpad
			defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1 # Click when tapping on the trackpad
			defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -int 0 # Right-click in bottom-right corner of the trackpad
			defaults -currentHost write NSGlobalDomain com.apple.trackpad.scrollBehavior -int 2 # Do not invert scrolling

			# Firewall
			sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1 # Enable the firewall
			sudo defaults write /Library/Preferences/com.apple.alf stealthenabled -int 1 # Do not respond to ICMP

			# Disable UI sound effects
			defaults write NSGlobalDomain com.apple.sound.uiaudio.enabled -int 0

			# Keyboard
			defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false # Disable automatic capitalization
			defaults write NSGlobalDomain NSUserQuotesArray -array '"\""' '"\""' '"'\''"' '"'\''"' # Adjust smart quotes
			defaults write NSGlobalDomain KeyRepeat -int 1 # Enable fast key repeat
			defaults write NSGlobalDomain InitialKeyRepeat -int 10 # Very fast initial key repeat
			defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false # Disable automatic spelling correction
			defaults write -g ApplePressAndHoldEnabled -bool false # Enable key repeat

			# Configure the clock to be 24h and display the date
			defaults write com.apple.menuextra.clock DateFormat -string "EEE d MMM  HH:mm"

			# Finder
			defaults write NSGlobalDomain AppleShowAllExtensions -bool true # Show all file extensions
			defaults write com.apple.finder ShowPathbar -bool true # Show full path
			defaults write com.apple.finder ShowStatusBar -bool true # Show status bar
			defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv" # View as list
			defaults write com.apple.finder FXDefaultSearchScope -string "SCcf" # Search in current folder
			defaults write com.apple.finder ShowMountedServersOnDesktop -bool true # Show connected servers on the desktop
			defaults write com.apple.mail AttachAtEnd -int 1 # Fix attachments when sending emails read by Outlook clients

			# Allow running applications from anywhere
			sudo spctl --master-disable

			# Disable software quarantine that displays 'Are you sure you want to run...'
			if [[ $(ls -lhdO "$HOME"/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2 | awk '{print$5}') != schg ]]; then
				echo -e "" > "$HOME"/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2
				sudo chflags schg "$HOME"/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2 > /dev/null 2>&1
			fi

			# Accessibility
			# defaults write com.apple.universalaccess reduceMotion -int 1 # Reduce animations
			defaults write com.apple.universalaccess reduceMotion -int 0 # Enable animations
			# defaults write com.apple.universalaccess reduceTranssparency -int 1 # Disable transparency

			# Build the 'locate' database
			sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist 2>&1 | lognoc
			sudo /usr/libexec/locate.updatedb 2>&1 | lognoc

			echo -e "System preferences configured. Some settings require a reboot" 2>&1 | logc
			echo -e 2>&1 | logc
			echo -e "You may want to configure these settings in System Preferences:" 2>&1 | logc
			echo -e "- In the \"General\" section, change the number of recent items (for TextEdit)" 2>&1 | logc
			echo -e "- In the \"Security \& Privacy\" section, enable requiring a password immediately after lock and enable FileVault (if laptop)" 2>&1 | logc
			echo -e "- Configure Siri if you wish to use it" 2>&1 | logc
			echo -e "- In the \"Keyboard\" section, you may want to adjust keyboard shortcuts to your liking" 2>&1 | logc
			echo -e "- Certain Finder preferences cannot be set fully. You may wish to review these" 2>&1 | logc
			echo -e 2>&1 | logc
			break
		elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
			echo -e
			break
		fi
	done
fi

#=====================
# Linux Workstation - Configuration
#=====================
if { [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] ;} && [[ "$OSTYPE" == "linux-gnu" ]]; then
	while read -p "Do you want to configure preferences? (Y/n) " -n 1 -r; do
		echo -e 2>&1 | logc
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then

			# Ask for the administrator password upfront
			echo -e "Starting configuration process..." 2>&1 | logc
			sudo -v

			# Add current user to necessary groups
			sudo usermod -a -G wheel,video,audio,network,sys,lp "$(whoami)" 2>&1 | lognoc

			# Enable Master channel sound output
			if type amixer > /dev/null 2>&1; then amixer sset Master unmute 2>&1 | lognoc; fi

			# Build the 'locate' database
			if type updatedb > /dev/null 2>&1; then	sudo updatedb 2>&1 | lognoc; fi

			# Enable services at boot
			if type docker > /dev/null 2>&1; then enableSvc docker 2>&1 | lognoc; fi
			if type containerd > /dev/null 2>&1; then enableSvc containerd 2>&1 | lognoc; fi
			if type teamviewer > /dev/null 2>&1; then enableSvc teamviewerd 2>&1 | lognoc; fi
			if type nmtui > /dev/null 2>&1; then enableSvc NetworkManager 2>&1 | lognoc; fi
			if type ntpd > /dev/null 2>&1; then enableSvc ntpd 2>&1 | lognoc; fi
			if [[ "$initSystem" == "systemd" ]]; then enableSvc systemd-timesyncd 2>&1 | lognoc; fi
			if type avahi-daemon > /dev/null 2>&1; then
				enableSvc avahi-daemon 2>&1 | lognoc
				setupmdns
			fi
			if type cupsd > /dev/null 2>&1; then enableSvc cups 2>&1 | lognoc; fi
			if type crond > /dev/null 2>&1; then enableSvc cronie 2>&1 | lognoc; fi
			if type pritunl-client > /dev/null 2>&1; then enableSvc pritunl-client 2>&1 | lognoc; fi
			if type syslog-ng > /dev/null 2>&1; then enableSvc syslog-ng@default 2>&1 | lognoc; fi
			if [ -f /usr/bin/ufw ]; then sudo /usr/bin/ufw enable 2>&1 | lognoc; fi
			enableSvc bluetooth 2>&1 | lognoc

			# Add current to 'wireshark' group if need be
			if type wireshark > /dev/null 2>&1; then sudo usermod -a -G wireshark "$(whoami)" 2>&1 | lognoc; fi

			# Tweak pacman's configuration
			if [ -f /etc/pacman.conf ]; then
				# Enable colors
				sudo sed -i 's/^#Color/Color/' /etc/pacman.conf 2>&1 | lognoc
			fi

			# Change default shell to Dash
			if [[ ! $(ls -l /bin/sh | awk '{print $11}') =~ ^(dash|\/bin\/dash)$ ]]; then
				while read -p "Do you want to change the default shell to Dash? (Y/n) " -n 1 -r; do
				echo -e 2>&1 | logc
					if [[ "$REPLY" =~ ^[Yy]$ ]]; then
						if ! type dash >/dev/null 2>&1; then install dash; fi
						sudo ln -sfT dash /bin/sh
						echo -e "Default shell changed to Dash" 2>&1 | logc
						echo -e "The modification will take effect after a reboot" 2>&1 | logc
						break
					elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
						echo -e
						break
					fi
				done
			fi

			echo -e "Preferences configured" 2>&1 | logc
			echo -e 2>&1 | logc
			break
		elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
			echo -e
			break
		fi
	done
fi

#=====================
# Arch Linux - GUI Requirements
#=====================
if { [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] ;} && { [[ -f /etc/arch-release ]] || [[ -f /etc/artix-release ]] || [[ -d /usr/share/xbps.d ]] ;} && [[ "$TERM" == "linux" ]]; then
	while read -p "Do you want to install the necessary software for a GUI environment? (Y/n) " -n 1 -r; do
		echo -e 2>&1 | logc
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then
			cd "$HOME" && curl -fsSLO "$applist" 2>&1 | lognoc
			echo -e "Installing necessary software for a GUI environment..." 2>&1 | logc
			if [[ -d /usr/share/xbps.d ]]; then grepvoidxpkg && installvoidxpkg && installjetbrainsmono; fi
			grepxpkg && installxpkg
 	 	 	setupkeyring
			installvideodriver
			echo -e "Necessary software for a GUI environment installed" 2>&1 | logc
			echo -e 2>&1 | logc
			rm "$HOME"/apps.csv 2>&1 | lognoc
			break
		elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
			echo -e
			break
		fi
	done
fi

#=====================
# Arch Linux - DE/WM Installation
#=====================
if { [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] ;} && [[ "$OSTYPE" == 'linux-gnu' ]] && { [[ -f /etc/arch-release ]] || [[ -f /etc/artix-release ]] || [[ -d /usr/share/xbps.d ]] ;} && type Xorg > /dev/null 2>&1; then
while read -p "Do you want to install a custom graphical environment now? (Y/n) " -n 1 -r; do
	echo -e 2>&1 | logc
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		if [[ -n $(pgrep Xorg) ]]; then
			echo -e "A new GUI cannot be installed while Xorg is running!"
			echo -e "Please run this script from a TTY (Press CTRL+F1-9 keys) without Xorg running"
			exit 1
		fi
		echo -e "Choose a custom environment from the following options:"
		echo -e "[1] BSPWM"
		echo -e "[2] DWM"
		echo -e "[3] i3 (with gaps)"
		echo -e "[4] Openbox"
		echo -e "[5] XFCE"
		echo -e "You can also choose these environments, but they will be vanilla (no customisation):"
		echo -e "[6] GNOME"
		echo -e "[7] KDE/Plasma"
		echo -e "[9] Cancel"
		echo -e "WARNING: if you are running Void Linux, DWM will only display a text-only statusbar"
		echo -e "See https://gitlab.freedesktop.org/xorg/lib/libxft/-/merge_requests/1 for more details"
		echo -e
		while read -p "Choose (ex.: type 2 for DWM): " -n 1 -r; do
			echo -e 2>&1 | logc
			if [[ "$REPLY" == 1 ]]; then
				echo -e "Installing BSPWM..." 2>&1 | logc
				installxinitrc
				installbspwm && installdmenu && installst && installslock && installsurf
				installlibxftbgra
				sed -i '/export SESSION="*"/c export SESSION="bspwm"' "$HOME"/.xinitrc 2>&1 | lognoc
				echo -e "BSPWM installed" 2>&1 | logc
				echo -e "If you have multiple monitors, please read the documentation at https://github.com/GSquad934/dotfiles/tree/master/config/bspwm" 2>&1 | logc
				echo -e 2>&1 | logc
			elif [[ "$REPLY" == 2 ]]; then
				echo -e "Installing DWM..." 2>&1 | logc
				installxinitrc
				installdwm && installdmenu && installst && installslock && installsurf
				installlibxftbgra
				sed -i '/export SESSION="*"/c export SESSION="dwm"' "$HOME"/.xinitrc 2>&1 | lognoc
				echo -e "DWM installed" 2>&1 | logc
				echo -e 2>&1 | logc
			elif [[ "$REPLY" == 3 ]]; then
				echo -e "Installing i3..." 2>&1 | logc
				installxinitrc
				installi3 && installdmenu && installst && installslock && installsurf
				installlibxftbgra
				sed -i '/export SESSION="*"/c export SESSION="i3"' "$HOME"/.xinitrc 2>&1 | lognoc
				echo -e "i3 installed" 2>&1 | logc
				echo -e 2>&1 | logc
			elif [[ "$REPLY" == 4 ]]; then
				echo -e "Installing Openbox..." 2>&1 | logc
				installxinitrc
				installopenbox && installdmenu && installst && installslock && installsurf
				installlibxftbgra
				sed -i '/export SESSION="*"/c export SESSION="openbox"' "$HOME"/.xinitrc 2>&1 | lognoc
				echo -e "Openbox installed" 2>&1 | logc
				echo -e 2>&1 | logc
			elif [[ "$REPLY" == 5 ]]; then
				echo -e "Installing XFCE..." 2>&1 | logc
				installxinitrc
				installxfce && installdmenu && installst && installslock && installsurf
				sed -i '/export SESSION="*"/c export SESSION="xfce"' "$HOME"/.xinitrc 2>&1 | lognoc
				echo -e "XFCE installed" 2>&1 | logc
				echo -e 2>&1 | logc
			elif [[ "$REPLY" == 6 ]]; then
				echo -e "Installing GNOME..." 2>&1 | logc
				installgnome && installdmenu && installst && installsurf
				echo -e "GNOME installed" 2>&1 | logc
				echo -e 2>&1 | logc
			elif [[ "$REPLY" == 7 ]]; then
				echo -e "Installing KDE/Plasma..." 2>&1 | logc
				installkdeplasma && installdmenu && installst && installsurf
				echo -e "KDE/Plasma installed" 2>&1 | logc
				echo -e 2>&1 | logc
			elif [[ "$REPLY" == 9 ]]; then
				echo -e 2>&1 | logc
				break
			fi
			if [[ ! -f /usr/bin/gdm ]] > /dev/null 2>&1 && [[ ! -f /usr/bin/sddm ]] > /dev/null 2>&1; then
				echo -e "The default login method is made via Xinit (preferred method)"
				echo -e "However, it is possible to use a graphical login manager such as LightDM"
				while read -p "Do you want to use a graphical login manager? (Y/n): " -n 1 -r; do
					echo -e 2>&1 | logc
					if [[ "$REPLY" =~ ^[Yy]$ ]]; then
						echo -e "Installing LightDM..." 2>&1 | logc
						installgreeter
						echo -e "LightDM installed" 2>&1 | logc
						echo -e 2>&1 | logc
						break
					elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
						echo -e 2>&1 | logc
						break
					fi
				done
			fi
		break
		done
		# Replace DMenu by Rofi
		if type rofi > /dev/null 2>&1; then
			rofi=$(which rofi)
			ln -sf "$rofi" "$scriptsloc"/dmenu 2>&1 | lognoc
		fi
		# Install Clipmenu (clipboard manager)
		if ! type clipmenu > /dev/null 2>&1; then
			install xsel clipnotify 2>&1 | lognoc
			sudo git clone --depth 1 "$clipmenurepo" /opt/clipmenu 2>&1 | lognoc
			cd /opt/clipmenu && sudo make install 2>&1 | lognoc
			cd "$HOME" || exit
		fi
	elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
		echo -e 2>&1 | logc
		break
	fi
	break
done
fi

#=======================
# Arch Linux - Laptop
#=======================
# Chassis type can be determined by reading file '/sys/class/dmi/id/chassis_type'
# An integer represents a type of chassis. Here is the full list:
# 1 Other
# 2 Unknown
# 3 Desktop
# 4 Low Profile Desktop
# 5 Pizza Box
# 6 Mini Tower
# 7 Tower
# 8 Portable
# 9 Laptop
# 10 Notebook
# 11 Hand Held
# 12 Docking Station
# 13 All in One
# 14 Sub Notebook
# 15 Space-Saving
# 16 Lunch Box
# 17 Main System Chassis
# 18 Expansion Chassis
# 19 SubChassis
# 20 Bus Expansion Chassis
# 21 Peripheral Chassis
# 22 Storage Chassis
# 23 Rack Mount Chassis
# 24 Sealed-Case PC
if { [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] ;} && [[ "$OSTYPE" == 'linux-gnu' ]] && { [[ -f /etc/arch-release ]] || [[ -f /etc/artix-release ]] || [[ -d /usr/share/xbps.d ]] ;} && [[ $(cat /sys/class/dmi/id/chassis_type) =~ ^(8|9|10|14)$ ]]; then
	if type tlp > /dev/null 2>&1; then
		while read -p "[LAPTOP DETECTED] Do you want to install a power management software? (Y/n) " -n 1 -r; do
			echo -e 2>&1 | logc
			if [[ "$REPLY" =~ ^[Yy]$ ]]; then
				echo -e "Installing power management software..." 2>&1 | logc
				install tlp xfce4-power-manager powertop 2>&1 | lognoc
				enableSvc tlp 2>&1 | lognoc
				enableSvc upower 2>&1 | lognoc
				echo -e "Power management software installed" 2>&1 | logc
				echo -e 2>&1 | logc
				if [[ $(cat /sys/class/dmi/id/chassis_type) =~ ^(8|9|10|14)$ ]] && [[ $(cat /sys/class/dmi/id/chassis_version) =~ ^Mac ]]; then
					echo -e "[MACBOOK DETECTED] Configuring hardware..." 2>&1 | logc
					# Program to use the ambient light sensor
					yes | yay --cleanafter --nodiffmenu --noprovides --removemake --noconfirm --needed -S macbook-lighter 2>&1 | lognoc
					enableSvc macbook-lighter 2>&1 | lognoc
				 	# Install proper Broadcom WiFi drivers for BCM43
				 	if lspci | grep BCM43 > /dev/null ; then
				 		install linux-headers 2>&1 | lognoc
				 		install broadcom-wl-dkms 2>&1 | lognoc
				 	fi
					# Make function keys work properly (F1-12 by default)
				 	echo "options hid_apple fnmode=2" | sudo tee /etc/modprobe.d/hid_apple.conf >/dev/null
					echo -e "If WiFi is causing issues, please refer to online documentation" 2>&1 | logc
					echo -e "Macbook's hardware configured" 2>&1 | logc
					echo -e 2>&1 | logc
					break
				fi
				break
			elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
				echo -e
				break
			fi
			break
		done
	fi
fi

#=======================
# Git Repositories
#=======================
if { [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] ;} && [[ -d "$gitrepoloc" ]]; then
	echo -e "Symlinking binaries from Git repositories..." 2>&1 | logc
	if [[ ! -d "$gitrepoloc/bin" ]]; then mkdir -pv "$gitrepoloc/bin" 2>&1 | lognoc ; fi
	find "$gitrepoloc" -maxdepth 3 -perm -111 -type f -exec ln -sf '{}' "$gitrepoloc/bin" ';' 2>&1 | lognoc
	rm -Rf "$gitrepoloc/bin/test" 2>&1 | lognoc
	echo -e "Git repos' binaries symlinked" 2>&1 | logc
	echo -e 2>&1 | logc
fi

#=====================
# Virtual Machines
#=====================
if { [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] ;} && grep -E --color '(vmx|svm)' /proc/cpuinfo > /dev/null 2>&1; then
	echo -e "Your computer supports the creation of virtual machines"
	while read -p "Do you want to install the necessary software to create VMs? (Y/n) " -n 1 -r; do
		echo -e 2>&1 | logc
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then
			echo -e "Installing virtualization software..." 2>&1 | logc
			installvirtualbox
			installkvm
			echo -e "Virtualization software installed" 2>&1 | logc
			echo -e 2>&1 | logc
			break
		elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
			echo -e
			break
		fi
	done
fi

#=======================
# Perl Dependencies
#=======================
if { [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] ;} && [[ -d "$gitrepoloc" ]] && type perl > /dev/null 2>&1; then
	echo -e "Installing Perl dependencies..." 2>&1 | logc
	installperldeps
	echo -e "Perl dependencies installed" 2>&1 | logc
	echo -e 2>&1 | logc
fi

#=======================
# Python Dependencies
#=======================
if { [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] ;} && [[ -d "$gitrepoloc" ]] && type python > /dev/null 2>&1; then
	echo -e "Installing Python dependencies..." 2>&1 | logc
	installpythondeps
	echo -e "Python dependencies installed" 2>&1 | logc
	echo -e 2>&1 | logc
fi

#=====================
# Workstation - Shell & Prompt
#=====================
# Define ZSH as default prompt
if { [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] ;} && [[ "$SHELL" != *"zsh" ]]; then
	echo -e "Your current shell is \"$SHELL\""
	while read -p "Do you want to use ZSH as your default shell? (Y/n) " -n 1 -r; do
		echo -e 2>&1 | logc
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then
			installzsh
			if [[ "$EUID" = 0 ]]; then
				echo -e "The shell of the root user should not be changed! (NOT RECOMMENDED)"
				echo -e "Please run the script as root in order to install the requirements"
				exit 1
			else
				chsh -s /bin/zsh 2>&1 | logc
			fi
			echo -e "ZSH successfully installed" 2>&1 | logc
			echo -e 2>&1 | logc
			break
		elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
			echo -e
			break
		fi
	done
fi
# Install Starship prompt
if [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]]; then
	while read -p "Do you want to install the Starship prompt (nice features)? (Y/n) " -n 1 -r; do
		echo -e 2>&1 | logc
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then
			echo -e "Installing Starship prompt..." 2>&1 | logc
			curl -fsSL https://starship.rs/install.sh | bash -s -- -y > /dev/null
			if [[ ! -d "$dfloc" ]]; then
				git clone --depth 1 "$dfrepo" "$dfloc" 2>&1 | lognoc
				ln -sf "$dfloc"/config/starship/starship.toml "$HOME"/.config/starship.toml 2>&1 | lognoc
			else
				ln -sf "$dfloc"/config/starship/starship.toml "$HOME"/.config/starship.toml 2>&1 | lognoc
			fi
			if [[ -f "$HOME"/.bashrc ]] && ! grep 'eval \"[$][(]starship init' "$HOME"/.bashrc > /dev/null 2>&1; then
				sudo tee -a "$HOME"/.bashrc <<-'EOF' >/dev/null
				# Load Starship prompt
				eval "$(starship init bash)"
				EOF
			elif [[ -f "$HOME"/.zshrc ]] && ! grep 'eval \"[$][(]starship init' "$HOME"/.zshrc > /dev/null 2>&1; then
				sudo tee -a "$HOME"/.zshrc <<-'EOF' >/dev/null
				# Load Starship prompt
				eval "$(starship init zsh)"
				EOF
			elif [[ -f "$HOME"/.config/zsh/.zshrc ]] && ! grep 'eval \"[$][(]starship init' "$HOME"/.config/zsh/.zshrc > /dev/null 2>&1; then
				echo -e "Starship prompt installed" 2>&1 | logc
				echo -e 2>&1 | logc
				sudo tee -a "$HOME"/.config/zsh/.zshrc <<-'EOF' >/dev/null
				# Load Starship prompt
				eval "$(starship init zsh)"
				EOF
			fi
			echo -e "If Starship does not launch when you login, make sure to load it with your prompt" 2>&1 | logc
			echo -e "For more information, please visit https://starship.rs/guide/" 2>&1 | logc
			echo -e "Starship prompt installed" 2>&1 | logc
			echo -e 2>&1 | logc
			break
		elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
			echo -e
			break
		fi
		break
	done
fi

#=======================
# Dotfiles
#=======================
# Clone the GitHub repository with all wanted dotfiles
while read -p "Do you want to install the dotfiles? (Y/n) " -n 1 -r; do
	echo -e 2>&1 | logc
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		if ! type git > /dev/null 2>&1; then
			echo -e "Git is required to install the dotfiles. Please install it before executing this script!"
			exit 1
		fi
		if [[ ! -d "$dfloc" ]]; then
			echo -e "Retrieving dotfiles..." 2>&1 | logc
			git clone --depth 1 "$dfrepo" "$dfloc" 2>&1 | lognoc
			git -C "$dfloc" submodule foreach --recursive git checkout master 2>&1 | lognoc
		else
			git -C "$dfloc" pull 2>&1 | lognoc
		fi

		# Remove and backup all original dotfiles
		while read -p "Do you want to backup your current dotfiles? (Y/n) " -n 1 -r; do
			echo -e 2>&1 | logc
			if [[ "$REPLY" =~ ^[Yy]$ ]]; then
				bkpdf=1
				echo -e "Backup your current dotfiles to $HOME/.old-dotfiles..." 2>&1 | logc
				if [[ ! -d "$HOME"/.old-dotfiles ]]; then
					mkdir -pv "$HOME"/.old-dotfiles > /dev/null 2>&1
				else
					rm -Rf "$HOME"/.old-dotfiles > /dev/null 2>&1
					mkdir -pv "$HOME"/.old-dotfiles > /dev/null 2>&1
				fi
				mv "$HOME"/.bash_profile "$HOME"/.old-dotfiles/bash_profile > /dev/null 2>&1
				mv "$HOME"/.bashrc "$HOME"/.old-dotfiles/bashrc > /dev/null 2>&1
				if [[ -f "$HOME"/.inputrc ]]; then mv "$HOME"/.inputrc "$HOME"/.old-dotfiles/inputrc > /dev/null 2>&1; else mv "$HOME"/.config/inputrc "$HOME"/.old-dotfiles/inputrc > /dev/null 2>&1; fi
				if [[ -f "$HOME"/.gitconfig ]]; then mv "$HOME"/.gitconfig "$HOME"/.old-dotfiles/gitconfig > /dev/null 2>&1; else mv "$HOME"/.config/git/config "$HOME"/.old-dotfiles/gitconfig > /dev/null 2>&1; fi
				if [[ -f "$HOME"/.msmtprc ]]; then mv "$HOME"/.msmtprc "$HOME"/.old-dotfiles/msmtprc > /dev/null 2>&1; else mv "$HOME"/.config/msmtp "$HOME"/.old-dotfiles/msmtp > /dev/null 2>&1; fi
				if [[ -f "$HOME"/.tmux.conf ]]; then mv "$HOME"/.tmux.conf "$HOME"/.old-dotfiles/tmux.conf > /dev/null 2>&1; else mv "$HOME"/.config/tmux/tmux.conf "$HOME"/.old-dotfiles/tmux.conf > /dev/null 2>&1; fi
				if [[ -f "$HOME"/.screenrc ]]; then mv "$HOME"/.screenrc "$HOME"/.old-dotfiles/screenrc > /dev/null 2>&1; else mv "$HOME"/.config/screen/screenrc "$HOME"/.old-dotfiles/screenrc > /dev/null 2>&1; fi
				if [[ -f "$HOME"/.Xresources ]]; then mv "$HOME"/.Xresources "$HOME"/.old-dotfiles/Xresources > /dev/null 2>&1; else mv "$HOME"/.config/X11/Xresources "$HOME"/.old-dotfiles/Xresources > /dev/null 2>&1; fi
				mv "$HOME"/.vim "$HOME"/.old-dotfiles/vim > /dev/null 2>&1
				mv "$HOME"/.vimrc "$HOME"/.old-dotfiles/vimrc > /dev/null 2>&1
				if [[ -f "$HOME"/.p10k.zsh ]]; then mv "$HOME"/.p10k.zsh "$HOME"/.old-dotfiles/p10k.zsh > /dev/null 2>&1; else mv "$HOME"/.config/zsh/.p10k.zsh "$HOME"/.old-dotfiles/p10k.zsh > /dev/null 2>&1; fi
				if [[ -f "$HOME"/.zshrc ]]; then mv "$HOME"/.zshrc "$HOME"/.old-dotfiles/zshrc > /dev/null 2>&1; else mv "$HOME"/.config/zsh/.zshrc "$HOME"/.old-dotfiles/zshrc > /dev/null 2>&1; fi
				if [[ "$OSTYPE" == "linux-gnu" ]]; then mv "$HOME"/.config/mimeapps.list "$HOME"/.old-dotfiles/mimeapps.list > /dev/null 2>&1 ; fi
				if [[ "$OSTYPE" == "linux-gnu" ]]; then mv "$HOME"/.local/share/applications/mimeapps.list "$HOME"/.old-dotfiles/local_share_applications_mimeapps.list > /dev/null 2>&1 ; fi
				mv "$HOME"/.local/share/applications/sxiview.desktop "$HOME"/.old-dotfiles/sxiview.desktop > /dev/null 2>&1
				mv "$HOME"/.zprofile "$HOME"/.old-dotfiles/zprofile > /dev/null 2>&1
				mv "$HOME"/.zshenv "$HOME"/.old-dotfiles/zshenv > /dev/null 2>&1
				mv "$HOME"/.config/nvim/init.vim "$HOME"/.old-dotfiles/init.vim > /dev/null 2>&1
				mv "$HOME"/.config/nvim "$HOME"/.old-dotfiles/nvim > /dev/null 2>&1
				mv "$HOME"/.config/wget "$HOME"/.old-dotfiles/wget > /dev/null 2>&1
				mv "$HOME"/.config/alacritty "$HOME"/.old-dotfiles/alacritty > /dev/null 2>&1
				mv "$HOME"/.config/kitty "$HOME"/.old-dotfiles/kitty > /dev/null 2>&1
				mv "$HOME"/.config/surfraw/conf "$HOME"/.old-dotfiles/surfraw > /dev/null 2>&1
				mv "$HOME"/.config/newsboat/config "$HOME"/.old-dotfiles/newsboat-config > /dev/null 2>&1
				mv "$HOME"/.config/newsboat/urls "$HOME"/.old-dotfiles/newsboat-urls > /dev/null 2>&1
				mv "$HOME"/.config/redshift.conf "$HOME"/.old-dotfiles/redshift.conf > /dev/null 2>&1
				mv "$HOME"/.config/PulseEffects/output/MySettings.json "$HOME"/.old-dotfiles/PulseEffects-Output_MySettings.json > /dev/null 2>&1
				mv "$HOME"/.config/dunst/dunstrc "$HOME"/.old-dotfiles/dunstrc > /dev/null 2>&1
				mv "$HOME"/.config/rofi/config.rasi "$HOME"/.old-dotfiles/rofi-config.rasi > /dev/null 2>&1
				mv "$HOME"/.config/sxhkd/sxhkdrc "$HOME"/.old-dotfiles/sxhkdrc > /dev/null 2>&1
				mv "$HOME"/.config/sxhkd/sxhkdrc_bspwm "$HOME"/.old-dotfiles/sxhkdrc_bspwm > /dev/null 2>&1
				mv "$HOME"/.config/amfora/config.toml "$HOME"/.old-dotfiles/amfora.toml > /dev/null 2>&1
				mv "$HOME"/.config/qutebrowser/config.py "$HOME"/.old-dotfiles/qutebrowser.py > /dev/null 2>&1
				mv "$HOME"/.config/qutebrowser/dark.css "$HOME"/.old-dotfiles/qutedark.css > /dev/null 2>&1
				mv "$HOME"/.jwmrc "$HOME"/.old-dotfiles/jwmrc > /dev/null 2>&1
				mv "$HOME"/.links "$HOME"/.old-dotfiles/links > /dev/null 2>&1
				mv "$HOME"/.config/mpd/mpd.conf "$HOME"/.old-dotfiles/mpd.conf > /dev/null 2>&1
				mv "$HOME"/.config/ncmpcpp/config "$HOME"/.old-dotfiles/ncmpcpp/config > /dev/null 2>&1
				mv "$HOME"/.config/ncmpcpp/bindings "$HOME"/.old-dotfiles/ncmpcpp/bindings > /dev/null 2>&1
				mv "$HOME"/.config/zathura/zathurarc "$HOME"/.old-dotfiles/zathurarc > /dev/null 2>&1
				mv "$HOME"/.config/sxiv/exec/key-handler "$HOME"/.old-dotfiles/sxiv-key-handler > /dev/null 2>&1
				mv "$HOME"/.config/picom/picom.conf "$HOME"/.old-dotfiles/picom.conf > /dev/null 2>&1
				break
			elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
				rm -Rf "$HOME"/.bash_profile
				rm -Rf "$HOME"/.bashrc
				if [[ -f "$HOME"/.inputrc ]]; then rm -Rf "$HOME"/.inputrc; else rm -Rf "$HOME"/.config/inputrc; fi
				if [[ -f "$HOME"/.gitconfig ]]; then rm -Rf "$HOME"/.gitconfig; else rm -Rf "$HOME"/.config/git/config; fi
				if [[ -f "$HOME"/.msmtprc ]]; then rm -Rf "$HOME"/.msmtprc; else rm -Rf "$HOME"/.config/msmtp; fi
				if [[ -f "$HOME"/.p10k.zsh ]]; then rm -Rf "$HOME"/.p10k.zsh; else rm -Rf "$HOME"/.config/zsh/.p10k.zsh; fi
				if [[ -f "$HOME"/.tmux.conf ]]; then rm -Rf "$HOME"/.tmux.conf; else rm -Rf "$HOME"/.config/tmux/tmux.conf; fi
				if [[ -f "$HOME"/screenrc ]]; then rm -Rf "$HOME"/screenrc; else rm -Rf "$HOME"/.config/screen/screenrc; fi
				if [[ -f "$HOME"/.Xresources ]]; then rm -Rf "$HOME"/.Xresources; else rm -Rf "$HOME"/.config/X11/Xresources; fi
				if [[ "$OSTYPE" == "linux-gnu" ]]; then rm -Rf "$HOME"/.config/mimeapps.list ; fi
				if [[ "$OSTYPE" == "linux-gnu" ]]; then rm -Rf "$HOME"/.local/share/applications/mimeapps.list ; fi
				rm -Rf "$HOME"/.vim
				rm -Rf "$HOME"/.vimrc
				if [[ -f "$HOME"/.zshrc ]]; then rm -Rf "$HOME"/.zshrc; else rm -Rf "$HOME"/.config/zsh/.zshrc; fi
				rm -Rf "$HOME"/.local/share/applications/sxiview.desktop
				rm -Rf "$HOME"/.zprofile
				rm -Rf "$HOME"/.zprofile
				rm -Rf "$HOME"/.zshenv
				rm -Rf "$HOME"/.config/nvim/init.vim
				rm -Rf "$HOME"/.config/nvim
				rm -Rf "$HOME"/.config/wget
				rm -Rf "$HOME"/.config/alacritty
				rm -Rf "$HOME"/.config/kitty
				rm -Rf "$HOME"/.links
				rm -Rf "$HOME"/.config/surfraw/conf
				rm -Rf "$HOME"/.config/newsboat/config
				rm -Rf "$HOME"/.config/newsboat/urls
				rm -Rf "$HOME"/.config/weechat
				rm -Rf "$HOME"/.config/weechat/irc.conf
				rm -Rf "$HOME"/.config/weechat/perl
				rm -Rf "$HOME"/.config/weechat/python
				rm -Rf "$HOME"/.config/weechat/trigger.conf
				rm -Rf "$HOME"/.config/weechat/weechat.conf
				rm -Rf "$HOME"/.config/weechat/xfer.conf
				rm -Rf "$HOME"/.config/weechat/buflist.conf
				rm -Rf "$HOME"/.config/weechat/colorize_nicks.conf
				rm -Rf "$HOME"/.config/weechat/fset.conf
				rm -Rf "$HOME"/.config/weechat/iset.conf
				rm -Rf "$HOME"/.config/redshift/redshift.conf
				rm -Rf "$HOME"/.config/PulseEffects/output/MySettings.json
				rm -Rf "$HOME"/.config/dunst/dunstrc
				rm -Rf "$HOME"/.config/rofi/config.rasi
				rm -Rf "$HOME"/.config/sxhkd/sxhkdrc
				rm -Rf "$HOME"/.config/sxhkd/sxhkdrc_bspwm
				rm -Rf "$HOME"/.config/amfora/config.toml
				rm -Rf "$HOME"/.config/qutebrowser/config.py
				rm -Rf "$HOME"/.config/qutebrowser/dark.css
				rm -Rf "$HOME"/.jwmrc
				if [[ -d "$HOME"/.moc ]]; then rm -Rf "$HOME"/.moc; else rm -Rf "$HOME"/.config/moc; fi
				rm -Rf "$HOME"/.config/mpd/mpd.conf
				rm -Rf "$HOME"/.config/ncmpcpp/config
				rm -Rf "$HOME"/.config/ncmpcpp/bindings
				rm -Rf "$HOME"/.config/zathura/zathurarc
				rm -Rf "$HOME"/.config/sxiv/exec/key-handler
				rm -Rf "$HOME"/.config/picom/picom.conf
				break
			fi
		done
		if [[ -f "$HOME"/.config/weechat/sec.conf ]]; then
			echo -e "A Weechat private configuration has been detected (sec.conf)." 2>&1 | logc
			while read -p "Do you want to reset the private Weechat configuration (sec.conf)? (Y/n) " -n 1 -r; do
				echo -e 2>&1 | logc
				if [[ "$REPLY" =~ ^[Yy]$ ]]; then
					if [[ -n "$bkpdf" ]]; then
						mv "$HOME"/.config/weechat "$HOME"/.old-dotfiles/weechat > /dev/null 2>&1
					else
						rm -Rf "$HOME"/.config/weechat
					fi
				elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
					if [[ -n "$bkpdf" ]]; then
						mv "$HOME"/.config/weechat "$HOME"/.old-dotfiles/weechat > /dev/null 2>&1
						mkdir -pv "$HOME"/.config/weechat 2>&1 | lognoc
						mv "$HOME"/.old-dotfiles/weechat/sec.conf "$HOME"/.config/weechat/sec.conf
					else
						mv "$HOME"/.config/weechat/sec.conf "$HOME"/sec.conf
						rm -Rf "$HOME"/.config/weechat
						mkdir -pv "$HOME"/.config/weechat 2>&1 | lognoc
						mv "$HOME"/sec.conf "$HOME"/.config/weechat/sec.conf
					fi
					break
				fi
			done
		fi

		# Create symlinks in the home folder
		echo -e "Installing new dotfiles..." 2>&1 | logc
		if [[ ! -d "$scriptsloc" ]]; then mkdir -pv "$scriptsloc" 2>&1 | lognoc ; fi
		ln -sf "$dfloc"/local/bin/* "$scriptsloc"/ 2>&1 | lognoc
		if [[ ! -d "$resourcesloc" ]]; then mkdir -pv "$resourcesloc"/ 2>&1 | lognoc ; fi
		ln -sf "$dfloc"/local/share/* "$resourcesloc" 2>&1 | lognoc
		if [[ ! -d "$HOME"/.config ]]; then mkdir -pv "$HOME"/.config 2>&1 | lognoc ; fi
		if type bash > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config ]]; then mkdir -pv "$HOME"/.config > /dev/null 2>&1; fi
			ln -sf "$dfloc"/shellconfig/bashrc "$HOME"/.bashrc 2>&1 | lognoc
			ln -sf "$dfloc"/shellconfig/inputrc "$HOME"/.config/inputrc 2>&1 | lognoc
			touch "$HOME"/.bash_profile && echo -e "source $HOME/.bashrc" > "$HOME"/.bash_profile
		fi
		if type zsh > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/zsh ]]; then
				mkdir -pv "$HOME"/.config/zsh 2>&1 | lognoc
			fi
			ln -sf "$dfloc"/shellconfig/zshrc "$HOME"/.config/zsh/.zshrc 2>&1 | lognoc
			ln -sf "$dfloc"/shellconfig/zshenv "$HOME"/.zshenv 2>&1 | lognoc
		fi
		## XDG default applications also symlinked to 'local/share' for legacy reasons
		if [[ "$OSTYPE" == "linux-gnu" ]]; then
			ln -sf "$dfloc"/config/mimeapps.list "$HOME"/.config/mimeapps.list 2>&1 | lognoc
			if [[ -d "$HOME"/.local/share/applications ]]; then mkdir -pv "$HOME"/.local/share/applications 2>&1 | lognoc ; fi
			ln -sf "$dfloc"/config/mimeapps.list "$HOME"/.local/share/applications/mimeapps.list 2>&1 | lognoc
			ln -sf "$dfloc"/local/share/applications/sxiview.desktop "$HOME"/.local/share/applications/ 2>&1 | lognoc
		fi
		if type git > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/git ]]; then
				mkdir -pv "$HOME"/.config/git 2>&1 | lognoc
			fi
			ln -sf "$dfloc"/gitconfig "$HOME"/.config/git/config 3>&1 | lognoc
		fi
		if type xrdb > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/X11 ]]; then
				mkdir -pv "$HOME"/.config/X11 2>&1 | lognoc
			fi
			ln -sf "$dfloc"/config/X11/Xresources "$HOME"/.config/X11/ 3>&1 | lognoc
		fi
		if type weechat > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/weechat ]]; then
				mkdir -pv "$HOME"/.config/weechat 2>&1 | lognoc
			fi
			ln -sf "$dfloc"/config/weechat/irc.conf "$HOME"/.config/weechat/irc.conf 2>&1 | lognoc
			ln -sf "$dfloc"/config/weechat/perl "$HOME"/.config/weechat/perl 2>&1 | lognoc
			ln -sf "$dfloc"/config/weechat/python "$HOME"/.config/weechat/python 2>&1 | lognoc
			ln -sf "$dfloc"/config/weechat/trigger.conf "$HOME"/.config/weechat/trigger.conf 2>&1 | lognoc
			ln -sf "$dfloc"/config/weechat/weechat.conf "$HOME"/.config/weechat/weechat.conf 2>&1 | lognoc
			ln -sf "$dfloc"/config/weechat/xfer.conf "$HOME"/.config/weechat/xfer.conf 2>&1 | lognoc
			ln -sf "$dfloc"/config/weechat/buflist.conf "$HOME"/.config/weechat/buflist.conf 2>&1 | lognoc
			ln -sf "$dfloc"/config/weechat/colorize_nicks.conf "$HOME"/.config/weechat/colorize_nicks.conf 2>&1 | lognoc
			ln -sf "$dfloc"/config/weechat/fset.conf "$HOME"/.config/weechat/fset.conf 2>&1 | lognoc
			ln -sf "$dfloc"/config/weechat/iset.conf "$HOME"/.config/weechat/iset.conf 2>&1 | lognoc
		fi
		if type wget > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/wget ]]; then
				mkdir -pv "$HOME"/.config/wget 2>&1 | lognoc
			fi
			ln -sf "$dfloc"/config/wget/wgetrc "$HOME"/.config/wget/wgetrc 2>&1 | lognoc
		fi
		if type vim > /dev/null 2>&1; then
			ln -sf "$dfloc"/vim "$HOME"/.vim 2>&1 | lognoc
			ln -sf "$dfloc"/vim/vimrc "$HOME"/.vimrc 2>&1 | lognoc
		fi
		if type nvim > /dev/null 2>&1; then
			ln -sf "$HOME"/.vim "$HOME"/.config/nvim 2>&1 | lognoc
			ln -sf "$HOME"/.vim/vimrc "$HOME"/.config/nvim/init.vim 2>&1 | lognoc
		fi
		if type msmtp > /dev/null 2>&1; then
			ln -sf "$dfloc"/config/msmtp "$HOME"/.config/msmtp 2>&1 | lognoc
		fi
		if type alacritty > /dev/null 2>&1 || [[ -d /Applications/Alacritty.app ]]; then
			if [[ ! -d "$HOME"/.config/alacritty ]]; then
				mkdir -pv "$HOME"/.config/alacritty 2>&1 | lognoc
			fi
			if [[ "$OSTYPE" == "darwin"* ]]; then
				mkdir -pv "$HOME"/.config/alacritty 2>&1 | lognoc && lln -sf "$dfloc"/config/alacritty/alacritty-macos.yml "$HOME"/.config/alacritty/alacritty.yml 2>&1 | lognoc
				ln -sf "$dfloc"/config/alacritty/{custom,gruvbox,dracula,onedark,nord}_theme.yml "$HOME"/.config/alacritty/ 2>&1 | lognoc
			elif [[ "$OSTYPE" == "linux-gnu" ]]; then
				mkdir -pv "$HOME"/.config/alacritty 2>&1 | lognoc && ln -sf "$dfloc"/config/alacritty/alacritty-linux.yml "$HOME"/.config/alacritty/alacritty.yml 2>&1 | lognoc
				ln -sf "$dfloc"/config/alacritty/{custom,gruvbox,dracula,onedark,nord}_theme.yml "$HOME"/.config/alacritty/ 2>&1 | lognoc
			fi
		fi
		if type kitty > /dev/null 2>&1 || [[ -d /Applications/Kitty.app ]]; then
			if [[ ! -d "$HOME"/.config/kitty ]]; then
				mkdir -pv "$HOME"/.config/kitty 2>&1 | lognoc
			fi
			if [[ "$OSTYPE" == "darwin"* ]]; then
				mkdir -pv "$HOME"/.config/kitty 2>&1 | lognoc && ln -sf "$dfloc"/config/kitty/kitty.conf "$HOME"/.config/kitty/kitty.conf 2>&1 | lognoc
				ln -sf "$dfloc"/config/kitty/{custom,gruvbox,dracula,onedark,nord}_theme.conf "$HOME"/.config/kitty/ 2>&1 | lognoc
			elif [[ "$OSTYPE" == "linux-gnu" ]]; then
				mkdir -pv "$HOME"/.config/kitty 2>&1 | lognoc && ln -sf "$dfloc"/config/kitty/kitty.conf "$HOME"/.config/kitty/kitty.conf 2>&1 | lognoc
				ln -sf "$dfloc"/config/kitty/{custom,gruvbox,dracula,onedark,nord}_theme.conf "$HOME"/.config/kitty/ 2>&1 | lognoc
			fi
		fi
		if type links > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.links ]]; then
				mkdir -pv "$HOME"/.links 2>&1 | lognoc
			fi
			ln -sf "$dfloc"/links/links.cfg "$HOME"/.links/links.cfg 2>&1 | lognoc
			ln -sf "$dfloc"/links/html.cfg "$HOME"/.links/html.cfg 2>&1 | lognoc
		fi
		if type surfraw > /dev/null 2>&1 || type sr > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/surfraw ]]; then
				mkdir -pv "$HOME"/.config/surfraw 2>&1 | lognoc
			fi
			ln -sf "$dfloc"/config/surfraw/conf "$HOME"/.config/surfraw/conf 2>&1 | lognoc
		fi
		if type newsboat > /dev/null 2>&1 > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/newsboat ]]; then
				mkdir -pv "$HOME"/.config/newsboat 2>&1 | lognoc
			fi
			ln -sf "$dfloc"/config/newsboat/config "$HOME"/.config/newsboat/config 2>&1 | lognoc
			ln -sf "$dfloc"/config/newsboat/urls "$HOME"/.config/newsboat/urls 2>&1 | lognoc
		fi
		if type screen > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/screen ]]; then
				mkdir -pv "$HOME"/.config/screen 2>&1 | lognoc
			fi
			ln -sf "$dfloc"/config/screen/screenrc "$HOME"/.config/screen/screenrc 2>&1 | lognoc
		fi
		if type redshift > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/redshift ]]; then
				mkdir -pv "$HOME"/.config/redshift 2>&1 | lognoc
			fi
			ln -sf "$dfloc"/config/redshift/redshift.conf "$HOME"/.config/redshift/redshift.conf 2>&1 | lognoc
		fi
		if type pulseeffects > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/PulseEffects/output ]]; then
				mkdir -pv "$HOME"/.config/PulseEffects/output 2>&1 | lognoc
			fi
			ln -sf "$dfloc"/config/PulseEffects/output/MySettings.json "$HOME"/.config/PulseEffects/output/MySettings.json 2>&1 | lognoc
		fi
		if type mpd > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/mpd ]]; then
				mkdir -pv "$HOME"/.config/mpd 2>&1 | lognoc
			fi
			if [[ ! -d "$HOME"/.local/share/mpd ]]; then
				mkdir -pv "$HOME"/.local/share/mpd 2>&1 | lognoc
			fi
			ln -sf "$dfloc"/config/mpd/mpd.conf "$HOME"/.config/mpd/ 2>&1 | lognoc
		fi
		if type ncmpcpp > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/ncmpcpp ]]; then
				mkdir -pv "$HOME"/.config/ncmpcpp 2>&1 | lognoc
			fi
			ln -sf "$dfloc"/config/ncmpcpp/config "$HOME"/.config/ncmpcpp/ 2>&1 | lognoc
			ln -sf "$dfloc"/config/ncmpcpp/bindings "$HOME"/.config/ncmpcpp/ 2>&1 | lognoc
		fi
		if type dunst > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/dunst ]]; then
				mkdir -pv "$HOME"/.config/dunst 2>&1 | lognoc
			fi
			ln -sf "$dfloc"/config/dunst/dunstrc "$HOME"/.config/dunst/ 2>&1 | lognoc
		fi
		if type tuir > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/tuir ]]; then
				mkdir -pv "$HOME"/.config/tuir 2>&1 | lognoc
			fi
			ln -sf "$dfloc"/config/tuir/tuir.cfg "$HOME"/.config/tuir/ 2>&1 | lognoc
			ln -sf "$dfloc"/config/tuir/mailcap "$HOME"/.config/tuir/ 2>&1 | lognoc
		fi
		if type rofi > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/rofi ]]; then
				mkdir -pv "$HOME"/.config/rofi 2>&1 | lognoc
			fi
			ln -sf "$dfloc"/config/rofi/config.rasi "$HOME"/.config/rofi/ 2>&1 | lognoc
			# Replace DMenu by Rofi
			rofi=$(which rofi)
			ln -sf "$rofi" "$scriptsloc"/dmenu 2>&1 | lognoc
		fi
		if type sxhkd > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/sxhkd ]]; then
				mkdir -pv "$HOME"/.config/sxhkd 2>&1 | lognoc
			fi
			ln -sf "$dfloc"/config/sxhkd/* "$HOME"/.config/sxhkd/ 2>&1 | lognoc
		fi
		if type amfora > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/amfora ]]; then
				mkdir -pv "$HOME"/.config/amfora 2>&1 | lognoc
			fi
			ln -sf "$dfloc"/config/amfora/config.toml "$HOME"/.config/amfora/ 2>&1 | lognoc
		fi
		if type qutebrowser > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/qutebrowser ]]; then
				mkdir -pv "$HOME"/.config/qutebrowser 2>&1 | lognoc
			fi
			ln -sf "$dfloc"/config/qutebrowser/config.py "$HOME"/.config/qutebrowser/ 2>&1 | lognoc
			ln -sf "$dfloc"/config/qutebrowser/dark.css "$HOME"/.config/qutebrowser/ 2>&1 | lognoc
		fi
		if type jwm > /dev/null 2>&1; then
			ln -sf "$dfloc"/jwmrc "$HOME"/.jwmrc 2>&1 | lognoc
		fi
		if type zathura > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/zathura ]]; then
				mkdir -pv "$HOME"/.config/zathura 2>&1 | lognoc
			fi
			ln -sf "$dfloc"/config/zathura/zathurarc "$HOME"/.config/zathura/ 2>&1 | lognoc
		fi
		if type sxiv > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/sxiv/exec ]]; then
				mkdir -pv "$HOME"/.config/sxiv/exec 2>&1 | lognoc
			fi
			ln -sf "$dfloc"/config/sxiv/exec/key-handler "$HOME"/.config/sxiv/exec/ 2>&1 | lognoc
		fi
		if type picom > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/picom ]]; then
				mkdir -pv "$HOME"/.config/picom 2>&1 | lognoc
			fi
			ln -sf "$dfloc"/config/picom/picom.conf "$HOME"/.config/picom/picom.conf 2>&1 | lognoc
		fi

		# If this is a SSH connection, install the server config of TMUX
		# For TMUX <=2.9, another config file can be manually installed if TMUX is throwing errors
		if type tmux > /dev/null 2>&1; then
			if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
				# TMUX introduced XDG Base Directory compliance in v3.1
				if [[ $(tmux -V) =~ 2\.[0-9] ]]; then
					ln -sf "$dfloc"/config/tmux/tmux29-server.conf "$HOME"/.tmux.conf 2>&1 | lognoc
				elif [[ $(tmux -V) =~ 3\.[1-9] ]]; then
					if [[ ! -d "$HOME"/.config/tmux ]]; then
						mkdir -pv "$HOME"/.config/tmux 2>&1 | lognoc
					fi
					ln -sf "$dfloc"/config/tmux/tmux29-server.conf "$HOME"/.config/tmux/tmux.conf 2>&1 | lognoc
				fi
			else
				if [[ $(tmux -V) =~ 2\.[0-9] ]]; then
					ln -sf "$dfloc"/config/tmux/tmux-workstation.conf "$HOME"/.tmux.conf 2>&1 | lognoc
				elif [[ $(tmux -V) =~ 3\.[1-9] ]]; then
					if [[ ! -d "$HOME"/.config/tmux ]]; then
						mkdir -pv "$HOME"/.config/tmux 2>&1 | lognoc
					fi
					ln -sf "$dfloc"/config/tmux/tmux-workstation.conf "$HOME"/.config/tmux/tmux.conf 2>&1 | lognoc
				fi
			fi
		fi

		echo -e "New dotfiles installed" 2>&1 | logc
		echo -e 2>&1 | logc

		# Install GTK config files if no DE is detected
		if { [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] ;} && [[ "$OSTYPE" == "linux-gnu" ]] && [[ -z "$XDG_CURRENT_DESKTOP" ]] && [[ -d /usr/share/themes/Adwaita-dark ]] && [[ -d /usr/share/icons/Papirus-Dark ]]; then
			while read -p "Do you want to install the GTK/QT theme (dark)? (Y/n) " -n 1 -r; do
				echo -e 2>&1 | logc
				if [[ "$REPLY" =~ ^[Yy]$ ]]; then
					echo -e "Installing GTK/QT theme..." 2>&1 | logc
					# GTK 2/3/4
					if [[ ! -d "$HOME"/.config/gtk-2.0 ]]; then
						mkdir -pv "$HOME"/.config/gtk-2.0 2>&1 | lognoc
					elif [[ -f "$HOME"/.config/gtk-2.0/gtkrc ]]; then
						rm -Rf "$HOME"/.config/gtk-2.0/gtkrc
					fi
					if [[ ! -d "$HOME"/.config/gtk-3.0 ]]; then
						mkdir -pv "$HOME"/.config/gtk-3.0 2>&1 | lognoc
					elif [[ -f "$HOME"/.config/gtk-3.0/settings.ini ]]; then
						rm -Rf "$HOME"/.config/gtk-3.0/settings.ini
					fi
					if [[ ! -d "$HOME"/.config/gtk-4.0 ]]; then
						mkdir -pv "$HOME"/.config/gtk-4.0 2>&1 | lognoc
					elif [[ -f "$HOME"/.config/gtk-4.0/settings.ini ]]; then
						rm -Rf "$HOME"/.config/gtk-4.0/settings.ini
					fi
					if [[ ! -d "$HOME"/.icons ]]; then
						mkdir -pv "$HOME"/.icons/default 2>&1 | lognoc
					elif [[ -f "$HOME"/.icons/default/index.theme ]]; then
						rm -Rf "$HOME"/.icons/default/index.theme
					fi
					ln -sf "$dfloc"/config/gtk-2.0/gtkrc "$HOME"/.config/gtk-2.0/ 2>&1 | lognoc
					ln -sf "$dfloc"/config/gtk-3.0/settings.ini "$HOME"/.config/gtk-3.0/ 2>&1 | lognoc
					ln -sf "$dfloc"/config/gtk-3.0/settings.ini "$HOME"/.config/gtk-4.0/ 2>&1 | lognoc
					ln -sf "$dfloc"/icons/default/index.theme "$HOME"/.icons/default/ 2>&1 | lognoc
					if type pcmanfm > /dev/null 2>&1; then
						if [[ ! -d "$HOME"/.config/libfm ]]; then
							mkdir -pv "$HOME"/.config/libfm 2>&1 | lognoc
						elif [[ -f "$HOME"/.config/libfm/libfm.conf ]]; then
							rm -Rf "$HOME"/.config/libfm/libfm.conf
						fi
						if [[ ! -d "$HOME"/.config/pcmanfm/default ]]; then
							mkdir -pv "$HOME"/.config/pcmanfm/default 2>&1 | lognoc
						elif [[ -f "$HOME"/.config/pcmanfm/default/pcmanfm.conf ]]; then
							rm -Rf "$HOME"/.config/pcmanfm/default/pcmanfm.conf
						fi
						ln -sf "$dfloc"/config/libfm/libfm.conf "$HOME"/.config/libfm/libfm.conf 2>&1 | lognoc
						ln -sf "$dfloc"/config/pcmanfm/default/pcmanfm.conf "$HOME"/.config/pcmanfm/default/pcmanfm.conf 2>&1 | lognoc
					fi
					if type volumeicon > /dev/null 2>&1; then
						if [[ ! -d "$HOME"/.config/volumeicon ]]; then
							mkdir -pv "$HOME"/.config/volumeicon 2>&1 | lognoc
						elif [[ -f "$HOME"/.config/volumeicon/volumeicon ]]; then
							rm -Rf "$HOME"/.config/volumeicon/volumeicon
						fi
						ln -sf "$dfloc"/config/volumeicon/volumeicon "$HOME"/.config/volumeicon/volumeicon 2>&1 | lognoc
					fi
					# QT
					installaur qt5-x11extras 2>&1 | lognoc
					sudo git clone --depth 1 "$adwaitaqtrepo" /opt/adwaita-qt 2>&1 | lognoc
					cd /opt/adwaita-qt && sudo cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr 2>&1 | lognoc
					sudo make 2>&1 | lognoc && sudo make install 2>&1 | lognoc
					cd "$HOME" || exit
					echo -e "GTK/QT theme installed" 2>&1 | logc
					echo -e 2>&1 | logc
					break
				elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
					break
				fi
			done
		fi
		break
	elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
		echo -e
		break
	fi
done

#=======================
# macOS Workstation - Amethyst Configuration
#=======================
if { [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] ;} && [[ "$OSTYPE" == "darwin"* ]] && [[ -d /Applications/Amethyst.app ]]; then
	while read -p "Do you want to install Amethyst's configuration? (Y/n) " -n 1 -r; do
		echo -e 2>&1 | logc
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then
			echo -e "Setting up Amethyst..." 2>&1 | logc
			# Set windows to always stay in floating mode
			defaults write com.amethyst.Amethyst.plist floating '(
		        	{
    	    	id = "com.apple.systempreferences";
    	    	"window-titles" =         (
    	    	);
    		},
		        	{
    	    	id = "com.skitch.skitch";
    	    	"window-titles" =         (
    	    	);
    		},
		        	{
    	    	id = "com.microsoft.autoupdate2";
    	    	"window-titles" =         (
    	    	);
    		},
		        	{
    	    	id = "com.apple.Stickies";
    	    	"window-titles" =         (
    	    	);
    		},
		        	{
    	    	id = "com.parallels.desktop.console";
    	    	"window-titles" =         (
    	    	);
    		},
		        	{
    	    	id = "cx.c3.theunarchiver";
    	    	"window-titles" =         (
    	    	);
    		},
    	    	{
    	    	id = "com.tapbots.Tweetbot3Mac";
    	    	"window-titles" =         (
    	    	);
    		}
			)'
			defaults write com.amethyst.Amethyst.plist floating-is-blacklist 1

			# Follow window when moved to different workspace
			defaults write com.amethyst.Amethyst.plist follow-space-thrown-windows 1

			# Configure layouts
			defaults write com.amethyst.Amethyst.plist layouts '(
				tall, wide, floating, fullscreen
			)'

			# Restore layouts when application starts
			defaults write com.amethyst.Amethyst.plist restore-layouts-on-launch 1

			# Set window margins
			defaults write com.amethyst.Amethyst.plist window-margins 1
			defaults write com.amethyst.Amethyst.plist window-margin-size 2

			# Do not display layout names
			defaults write com.amethyst.Amethyst.plist enables-layout-hud 0
			defaults write com.amethyst.Amethyst.plist enables-layout-hud-on-space-change 0

			# Disable automatic update check as it is done by Homebrew
			defaults write com.amethyst.Amethyst.plist SUEnableAutomaticChecks 0

			# Delete the plist cache
			defaults read com.amethyst.Amethyst.plist > /dev/null 2>&1

			echo -e "Amethyst configured" 2>&1 | logc
			echo -e 2>&1 | logc
			break
		elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
			echo -e
			break
		fi
	done
fi

#=======================
# DONE
#=======================
echo -e 2>&1 | logc
echo -e 2>&1 | logc
echo -e "======= ALL DONE =======" 2>&1 | logc
echo -e 2>&1 | logc
echo -e "Please reboot the computer for all the settings to be applied (not applicable for servers)." 2>&1 | logc
echo -e "A log file called \"$logfile\" contains the details of all operations. Check it for errors." 2>&1 | logc