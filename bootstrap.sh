#!/bin/bash
#
# Description: this script automates the installation of my personal computer
# Compatibility: it works for both macOS and Linux

#=============
# Global Variables
#=============

# Dotfiles location
dfloc="$HOME/.dotfiles"
dfrepo="https://github.com/GSquad934/dotfiles.git"

# Custom scripts location
scriptsloc="$HOME/.local/bin"
resourcesloc="$HOME/.local/share"

# Git repositories location
gitrepoloc="$HOME/.sources/repos"

# Wallpapers
wallpapers="https://github.com/GSquad934/wallpapers.git"
wallpapersloc="$HOME/.local/share/wallpapers"

# Software lists
homebrew="https://raw.githubusercontent.com/Homebrew/install/master/install.sh"
aurhelper="https://aur.archlinux.org/yay.git"
applist="https://raw.githubusercontent.com/GSquad934/bootstrap/master/apps.csv"

# Font lists
mononoki_regular="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Mononoki/Regular/complete/mononoki-Regular%20Nerd%20Font%20Complete.ttf"
mononoki_bold="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Mononoki/Bold/complete/mononoki%20Bold%20Nerd%20Font%20Complete.ttf"
mononoki_italic="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Mononoki/Italic/complete/mononoki%20Italic%20Nerd%20Font%20Complete.ttf"
jetbrainsmono_regular="https://github.com/JetBrains/JetBrainsMono/blob/master/fonts/ttf/JetBrainsMono-Regular.ttf"
jetbrainsmono_bold="https://github.com/JetBrains/JetBrainsMono/blob/master/fonts/ttf/JetBrainsMono-Bold.ttf"
jetbrainsmono_italic="https://github.com/JetBrains/JetBrainsMono/blob/master/fonts/ttf/JetBrainsMono-Italic.ttf"
powerline_fonts="https://github.com/powerline/fonts"

# TMUX Plugins
tpm="https://github.com/tmux-plugins/tpm"

# Custom WM/DE location
dwmrepo="https://github.com/GSquad934/dwm.git"
dwmloc="/opt/dwm"
dmenurepo="https://github.com/GSquad934/dmenu.git"
dmenuloc="/opt/dmenu"
strepo="https://github.com/GSquad934/st.git"
stloc="/opt/st"

# Logging
date="$(date +%Y-%m-%d-%H%M%S)"
logfile="$HOME/bootstrap_log_$date.txt"

#=============
# Global Functions
#=============
logc(){ tee -a "$logfile" ;}
lognoc(){ tee -a "$logfile" > /dev/null 2>&1 ;}

if type brew > /dev/null 2>&1; then
	greppkg(){ pkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[M][^,]*" | sed '/^W/d' | sed 's/^.*,//g' > "$pkg" ;}
	grepguipkg(){ guipkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[C][^,]*" | sed '/^W/d' | sed 's/^.*,//g' > "$guipkg" ;}
	grepworkpkg(){ workpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[M][^,]*" | sed 's/^.*,//g' > "$workpkg" ;}
	grepworkguipkg(){ workguipkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[C][^,]*" | sed 's/^.*,//g' > "$workguipkg" ;}
	installpkg(){ brew update 2>&1 | lognoc && while IFS= read -r line; do brew install "$line" 2>&1 | lognoc; done < "$pkg" ;}
	installguipkg(){ brew update 2>&1 | lognoc && while IFS= read -r line; do brew install --cask "$line" 2>&1 | lognoc; done < "$guipkg" ;}
	installworkpkg(){ brew update 2>&1 | lognoc && while IFS= read -r line; do brew install "$line" 2>&1 | lognoc; done < "$workpkg" ;}
	installworkguipkg(){ brew update 2>&1 | lognoc && while IFS= read -r line; do brew install --cask "$line" 2>&1 | lognoc; done < "$workguipkg" ;}
	installzsh() {
		brew install zsh 2>&1 | lognoc
		chmod g-w "$(brew --prefix)/share" 2>&1 | lognoc
		chmod g-w "$(brew --prefix)/share/zsh" 2>&1 | lognoc
		chmod g-w "$(brew --prefix)/share/zsh/sites-functions" 2>&1 | lognoc
		git clone --depth 1 https://github.com/zplug/zplug "$HOME"/.config/zsh/zplug 2>&1 | lognoc
		if [[ ! -d "$dfloc" ]]; then
			git clone --depth 1 "$dfrepo" "$dfloc" 2>&1 | lognoc
			ln -sf "$dfloc"/config/starship/starship.toml "$HOME"/.config/starship.toml 2>&1 | lognoc
		else
			ln -sf "$dfloc"/config/starship/starship.toml "$HOME"/.config/starship.toml 2>&1 | lognoc
		fi
	}
elif type apt-get > /dev/null 2>&1; then
	greppkg(){ pkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[D][^,]*" | sed '/^W/d' | sed 's/^.*,//g' > "$pkg" ;}
	grepworkpkg(){ workpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[D][^,]*" | sed 's/^.*,//g' > "$workpkg" ;}
	installpkg(){ sudo apt-get update 2>&1 | lognoc && while IFS= read -r line; do sudo apt-get install -y "$line" 2>&1 | lognoc; done < "$pkg" ;}
	installworkpkg(){ sudo apt-get update 2>&1 | lognoc && while IFS= read -r line; do sudo apt-get install -y "$line" 2>&1 | lognoc; done < "$workpkg" ;}
	installsudo(){ apt-get update 2>&1 | lognoc && apt-get install -y sudo 2>&1 | lognoc ;}
	installzsh(){
		sudo apt-get update 2>&1 | lognoc && sudo apt-get install -y zsh 2>&1 | lognoc
		git clone --depth 1 https://github.com/zplug/zplug "$HOME"/.config/zsh/zplug 2>&1 | lognoc
		if [[ ! -d "$dfloc" ]]; then
			git clone --depth 1 "$dfrepo" "$dfloc" 2>&1 | lognoc
			ln -sf "$dfloc"/config/starship/starship.toml "$HOME"/.config/starship.toml 2>&1 | lognoc
		else
			ln -sf "$dfloc"/config/starship/starship.toml "$HOME"/.config/starship.toml 2>&1 | lognoc
		fi
	}
elif type yum > /dev/null 2>&1; then
	greppkg(){ pkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[R][^,]*" | sed '/^W/d' | sed 's/^.*,//g' > "$pkg" ;}
	grepworkpkg(){ workpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[R][^,]*" | sed 's/^.*,//g' > "$workpkg" ;}
	installpkg(){ sudo yum update -y 2>&1 | lognoc && while IFS= read -r line; do sudo yum install -y "$line" 2>&1 | lognoc; done < "$pkg" ;}
	installworkpkg(){ sudo yum update -y 2>&1 | lognoc && while IFS= read -r line; do sudo yum install -y "$line" 2>&1 | lognoc; done < "$workpkg" ;}
	installsudo(){ yum update -y 2>&1 | lognoc && yum install -y sudo 2>&1 | lognoc ;}
	installzsh(){
		sudo yum update -y 2>&1 | lognoc && sudo yum install -y zsh 2>&1 | lognoc
		git clone --depth 1 https://github.com/zplug/zplug "$HOME"/.config/zsh/zplug 2>&1 | lognoc
		if [[ ! -d "$dfloc" ]]; then
			git clone --depth 1 "$dfrepo" "$dfloc" 2>&1 | lognoc
			ln -sf "$dfloc"/config/starship/starship.toml "$HOME"/.config/starship.toml 2>&1 | lognoc
		else
			ln -sf "$dfloc"/config/starship/starship.toml "$HOME"/.config/starship.toml 2>&1 | lognoc
		fi
	}
elif type pacman yay > /dev/null 2>&1; then
	greppkg(){ pkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[A][^,]*" | sed '/^W/d' | sed 's/^.*,//g' > "$pkg" ;}
	grepworkpkg(){ workpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[A][^,]*" | sed 's/^.*,//g' > "$workpkg" ;}
	installpkg(){ sudo pacman -Syu --noconfirm 2>&1 | lognoc && while IFS= read -r line; do sudo pacman --noconfirm --needed -S "$line" 2>&1 | lognoc; done < "$pkg" ;}
	installworkpkg(){ sudo pacman -Syu --noconfirm 2>&1 | lognoc && while IFS= read -r line; do sudo pacman --noconfirm --needed -S "$line" 2>&1 | lognoc; done < "$workpkg" ;}
	installsudo(){ pacman -Syu --noconfirm 2>&1 | lognoc && pacman --noconfirm --needed -S sudo 2>&1 | lognoc ;}
	installzsh(){
		sudo pacman -Syu --noconfirm 2>&1 | lognoc && sudo pacman --needed --noconfirm -S zsh 2>&1 | lognoc
		git clone --depth 1 https://github.com/zplug/zplug "$HOME"/.config/zsh/zplug 2>&1 | lognoc
		if [[ ! -d "$dfloc" ]]; then
			git clone --depth 1 "$dfrepo" "$dfloc" 2>&1 | lognoc
			ln -sf "$dfloc"/config/starship/starship.toml "$HOME"/.config/starship.toml 2>&1 | lognoc
		else
			ln -sf "$dfloc"/config/starship/starship.toml "$HOME"/.config/starship.toml 2>&1 | lognoc
		fi
	}
	grepaurpkg(){ aurpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[Y][^,]*" | sed '/^W/d' | sed 's/^.*,//g' > "$aurpkg" ;}
	grepworkaurpkg(){ workaurpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[Y][^,]*" | sed 's/^.*,//g' > "$workaurpkg" ;}
	installaurpkg(){ while IFS= read -r line; do yay --cleanafter --nodiffmenu --noprovides --removemake --noconfirm --needed -S "$line" 2>&1 | lognoc; done < "$aurpkg" ;}
	installworkaurpkg(){ while IFS= read -r line; do yay --cleanafter --nodiffmenu --noprovides --removemake --noconfirm --needed -S "$line" 2>&1 | lognoc; done < "$workaurpkg" ;}
elif type pacman > /dev/null 2>&1; then
	greppkg(){ pkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[A][^,]*" | sed '/^W/d' | sed 's/^.*,//g' > "$pkg" ;}
	grepworkpkg(){ workpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[A][^,]*" | sed 's/^.*,//g' > "$workpkg" ;}
	installpkg(){ sudo pacman -Syu --noconfirm 2>&1 | lognoc && while IFS= read -r line; do sudo pacman --noconfirm --needed -S "$line" 2>&1 | lognoc; done < "$pkg" ;}
	installworkpkg(){ sudo pacman -Syu --noconfirm 2>&1 | lognoc && while IFS= read -r line; do sudo pacman --noconfirm --needed -S "$line" 2>&1 | lognoc; done < "$workpkg" ;}
	installsudo(){ pacman -Syu --noconfirm 2>&1 | lognoc && pacman --noconfirm --needed -S sudo 2>&1 | lognoc ;}
	installzsh(){
		sudo pacman -Syu --noconfirm 2>&1 | lognoc && sudo pacman --needed --noconfirm -S zsh 2>&1 | lognoc
		git clone --depth 1 https://github.com/zplug/zplug "$HOME"/.config/zsh/zplug 2>&1 | lognoc
		if [[ ! -d "$dfloc" ]]; then
			git clone --depth 1 "$dfrepo" "$dfloc" 2>&1 | lognoc
			ln -sf "$dfloc"/config/starship/starship.toml "$HOME"/.config/starship.toml 2>&1 | lognoc
		else
			ln -sf "$dfloc"/config/starship/starship.toml "$HOME"/.config/starship.toml 2>&1 | lognoc
		fi
	}
fi

grepstoreapp(){ if type mas > /dev/null 2>&1; then storeapp=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[S][^,]*" | sed '/^W/d' | sed 's/^.*,//g' | awk '{print $1}' > "$storeapp"; fi ;}
grepworkstoreapp(){ if type mas > /dev/null 2>&1; then workstoreapp=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[S][^,]*" | sed 's/^.*,//g' | awk '{print $1}' > "$workstoreapp"; fi ;}
installstoreapp(){ if type mas > /dev/null 2>&1; then < "$storeapp" xargs mas install 2>&1 | lognoc; fi ;}
installworkstoreapp(){ if type mas > /dev/null 2>&1; then < "$workstoreapp" xargs mas install 2>&1 | lognoc; fi ;}

grepgitrepo(){ if type git > /dev/null 2>&1; then repo=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[G][^,]*" | sed '/^W/d' | sed 's/^.*,//g' | awk '{print $1}' > "$repo"; fi ;}
grepworkgitrepo(){ if type git > /dev/null 2>&1; then	workrepo=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[G][^,]*" | sed 's/^.*,//g' | awk '{print $1}' > "$workrepo" ; fi ;}
installgitrepo(){ if [[ ! -d "$gitrepoloc" ]]; then mkdir -pv "$gitrepoloc" > /dev/null 2>&1; fi && if type git > /dev/null 2>&1; then < "$repo" xargs -n1 -I url git -C "$gitrepoloc" clone url 2>&1 | lognoc; fi ;}
installworkgitrepo(){ if [[ ! -d "$gitrepoloc" ]]; then mkdir -pv "$gitrepoloc" > /dev/null 2>&1; fi && if type git > /dev/null 2>&1; then < "$workrepo" xargs -n1 -I url git -C "$gitrepoloc" clone url 2>&1 | lognoc; fi ;}

installperldeps(){
	perlx=$(find "$gitrepoloc" -maxdepth 3 -perm -111 -type f -name '*.pl')
	# Nikto
	if [[ "$perlx" =~ nikto.pl ]]; then
		if ! perl -MNet::SSLeay -e 1 > /dev/null 2>&1; then
			if type apt-get > /dev/null 2>&1; then
				sudo apt-get update 2>&1 | lognoc && sudo apt-get install -y libnet-ssleay-perl 2>&1 | lognoc
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

if type pacman > /dev/null 2>&1; then
	setupcustomrepos(){
		# Pritunl
		if ! grep '^\[pritunl\]' /etc/pacman.conf > /dev/null 2>&1; then
			sudo tee -a /etc/pacman.conf <<-'EOF'
			[pritunl]
			Server = https://repo.pritunl.com/stable/pacman
			EOF
		sudo pacman-key --keyserver hkp://keyserver.ubuntu.com -r 7568D9BB55FF9E5287D586017AE645C0CF8E292A > /dev/null 2>&1 | lognoc
		sudo pacman-key --lsign-key 7568D9BB55FF9E5287D586017AE645C0CF8E292A > /dev/null 2>&1 | lognoc
		fi
	}
fi

if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]] && [[ "$OSTYPE" == 'linux-gnu' ]]; then
	grepsrvpkg(){ srvpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[I][^,]*" | sed 's/^.*,//g' > "$srvpkg" ;}
	if type apt-get > /dev/null 2>&1; then
		if [[ "$EUID" = 0 ]]; then
			installsrvpkg(){ apt-get update 2>&1 | lognoc && while IFS= read -r line; do apt-get install -y "$line" 2>&1 | lognoc; done < "$srvpkg" ;}
		elif ! type sudo > /dev/null 2>&1; then
			echo -e "Make sure to run this script as sudo to install useful tools!" 2>&1 | logc
			exit 1
		else
			installsrvpkg(){ sudo apt-get update 2>&1 | lognoc && while IFS= read -r line; do sudo apt-get install -y "$line" 2>&1 | lognoc; done < "$srvpkg" ;}
		fi
	elif type yum > /dev/null 2>&1; then
		if [[ "$EUID" = 0 ]]; then
			installsrvpkg(){ yum update -y 2>&1 | lognoc && while IFS= read -r line; do yum install -y "$line" 2>&1 | lognoc; done < "$srvpkg" ;}
		elif ! type sudo > /dev/null 2>&1; then
			echo -e "Make sure to run this script as sudo to install useful tools!" 2>&1 | logc
			exit 1
		else
			installsrvpkg(){ sudo yum update -y 2>&1 | lognoc && while IFS= read -r line; do sudo yum install -y "$line" 2>&1 | lognoc; done < "$srvpkg" ;}
		fi
	elif type pacman > /dev/null 2>&1; then
		if [[ "$EUID" = 0 ]]; then
			installsrvpkg(){ pacman -Syu --noconfirm 2>&1 | lognoc && while IFS= read -r line; do pacman --noconfirm --needed -S "$line" 2>&1 | lognoc; done < "$srvpkg" ;}
		elif ! type sudo > /dev/null 2>&1; then
			echo -e "Make sure to run this script as sudo to install useful tools!" 2>&1 | logc
			exit 1
		else
			installsrvpkg(){ sudo pacman --noconfirm -Syu 2>&1 | lognoc && while IFS= read -r line; do sudo pacman --noconfirm --needed -S "$line" 2>&1 | lognoc; done < "$srvpkg" ;}
		fi
	fi
fi

if [[ ! -h /etc/arch-release ]]; then
	grepxpkg(){ archxpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[X][^,]*" | sed '/^W/d' | sed 's/^.*,//g' > "$archxpkg" ;}
	installxpkg(){ sudo pacman -Syu --noconfirm 2>&1 | lognoc && while IFS= read -r line; do sudo pacman --noconfirm --needed -S "$line" 2>&1 | lognoc; done < "$archxpkg" ;}
	# TEMP until the library is fixed
	installlibxftbgra(){ sudo pacman -Syu --noconfirm 2>&1 | lognoc && yes | yay --cleanafter --nodiffmenu --noprovides --removemake --needed -S libxft-bgra 2>&1 | lognoc ;}
	installvideodriver(){
		case "$(lspci -v | grep -A1 -e VGA -e 3D)" in
			*NVIDIA*) sudo pacman -S --needed --noconfirm xf86-video-nouveau 2>&1 | lognoc ;;
			*AMD*) sudo pacman -S --needed --noconfirm xf86-video-amdgpu 2>&1 | lognoc ;;
			*Intel*) sudo pacman -S --needed --noconfirm xf86-video-intel 2>&1 | lognoc ;;
			*) sudo pacman -S --needed --noconfirm xf86-video-fbdev 2>&1 | lognoc ;;
		esac
	}
	installxinitrc(){
		if [[ -f "$HOME"/.xinitrc ]]; then
			if [[ ! -d "$dfloc" ]]; then git clone --depth 1 "$dfrepo" "$dfloc" 2>&1 | lognoc ; else git -C "$dfloc" pull 2>&1 | lognoc ; fi
    		mv "$HOME"/.xinitrc "$HOME"/.xinitrc.orig > /dev/null 2>&1
    		ln -sf "$dfloc"/config/X11/xinitrc "$HOME"/.xinitrc 2>&1 | lognoc
    		mkdir -pv "$HOME"/.config/X11 2>&1 | lognoc && ln -sf "$dfloc"/config/X11/xprofile "$HOME"/.config/X11/xprofile 2>&1 | lognoc
    	else
			if [[ ! -d "$dfloc" ]]; then git clone --depth 1 "$dfrepo" "$dfloc" 2>&1 | lognoc ; else git -C "$dfloc" pull 2>&1 | lognoc ; fi
    		ln -sf "$dfloc"/config/X11/xinitrc "$HOME"/.xinitrc 2>&1 | lognoc
    		mkdir -pv "$HOME"/.config/X11 2>&1 | lognoc && ln -sf "$dfloc"/config/X11/xprofile "$HOME"/.config/X11/xprofile 2>&1 | lognoc
		fi
	}
	installdwm(){
		if [[ -d "$dwmloc" ]]; then sudo rm -Rf "$dwmloc" 2>&1 /dev/null; fi
		sudo git clone --depth 1 "$dwmrepo" "$dwmloc" 2>&1 | lognoc
		sudo make -C "$dwmloc" clean install 2>&1 | lognoc
	}
	installdmenu(){
		if [[ -d "$dmenuloc" ]]; then sudo rm -Rf "$dmenuloc" 2>&1 /dev/null; fi
		sudo git clone --depth 1 "$dmenurepo" "$dmenuloc" 2>&1 | lognoc
		sudo make -C "$dmenuloc" clean install 2>&1 | lognoc
	}
	installst(){
		if [[ -d "$stloc" ]]; then sudo rm -Rf "$stloc" 2>&1 /dev/null; fi
		sudo git clone --depth 1 "$strepo" "$stloc" 2>&1 | lognoc
		sudo make -C "$stloc" clean install 2>&1 | lognoc
	}
	installleftwm(){
		yes "" | yay --cleanafter --nodiffmenu --noprovides --removemake --needed -S leftwm polybar 2>&1 | lognoc
		if [[ ! -d "$dfloc" ]]; then
			git clone --depth 1 "$dfrepo" "$dfloc" 2>&1 | lognoc
		else
			ln -sf "$dfloc"/config/leftwm "$HOME"/.config/ 2>&1 | lognoc
		fi
	}
fi

#=============
# BEGINNING
#=============
echo -e
echo -e "============================= BOOTSTRAP PROCESS BEGINNING =============================" 2>&1 | logc
echo -e "" 2>&1 | logc
echo -e " The file \"$logfile\" will be created to log all ongoing operations" 2>&1 | logc
echo -e " If the script gives an error because of user rights, please follow the instructions" 2>&1 | logc
echo -e "" 2>&1 | logc
echo -e "=======================================================================================" 2>&1 | logc
echo -e 2>&1 | logc
echo -e 2>&1 | logc

#=============
# Linux - Install 'sudo' (Requirement)
#=============
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
				if ! grep '^\%wheel ALL=(ALL) ALL' /etc/sudoers > /dev/null 2>&1 && ! grep '^\%sudo ALL=(ALL) ALL' /etc/sudoers > /dev/null 2>&1; then
					if grep '^\@includedir /etc/sudoers.d' /etc/sudoers > /dev/null 2>&1; then
						if [[ ! -d /etc/sudoers.d ]]; then mkdir -pv /etc/sudoers.d 2>&1 | lognoc; fi
						touch /etc/sudoers.d/99-wheel && echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/99-wheel
					else
						sed -i 's/^#\ \%wheel ALL=(ALL) ALL/\%wheel ALL=(ALL) ALL/' /etc/sudoers
					fi
					break
				fi
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

#=============
# macOS - Install XCode Command Line Tools (Requirement)
#=============

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

#=============
# macOS - Install Homebrew (Requirement)
#=============
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

#=============
# Arch Linux - Install AUR Helper (Requirement)
#=============
if [[ "$OSTYPE" == "linux-gnu" ]] && [[ -f /etc/arch-release ]] && ! type yay > /dev/null 2>&1; then
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

#==============
# Workstation - Configure Custom Repositories
#==============
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

#=============
# Workstation - Install Common Packages
#=============
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
				greppkg && installpkg
				if [[ -f /etc/arch-release ]] && type yay > /dev/null 2>&1; then
					grepaurpkg && installaurpkg
					grepgitrepo && installgitrepo
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

#=============
# Workstation - Install Work Packages
#=============
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
				if [[ -f /etc/arch-release ]] && type yay > /dev/null 2>&1; then
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

#============
# Workstation - Install Fonts
#============
if [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] && type git > /dev/null 2>&1; then
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
					wget -c --content-disposition -P "$HOME"/fonts/ "$mononoki_regular" 2>&1 | lognoc
					wget -c --content-disposition -P "$HOME"/fonts/ "$mononoki_bold" 2>&1 | lognoc
					wget -c --content-disposition -P "$HOME"/fonts/ "$mononoki_italic" 2>&1 | lognoc
					wget -c --content-disposition -P "$HOME"/fonts/ "$jetbrainsmono_regular" 2>&1 | lognoc
					wget -c --content-disposition -P "$HOME"/fonts/ "$jetbrainsmono_bold" 2>&1 | lognoc
					wget -c --content-disposition -P "$HOME"/fonts/ "$jetbrainsmono_italic" 2>&1 | lognoc
				elif type curl > /dev/null 2>&1; then
					cd "$HOME"/fonts || exit
					curl -fSLO "$mononoki_regular" 2>&1 | lognoc
					curl -fSLO "$mononoki_bold" 2>&1 | lognoc
					curl -fSLO "$mononoki_italic" 2>&1 | lognoc
					curl -fSLO "$jetbrainsmono_regular" 2>&1 | lognoc
					curl -fSLO "$jetbrainsmono_bold" 2>&1 | lognoc
					curl -fSLO "$jetbrainsmono_italic" 2>&1 | lognoc
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

#============
# Install TMUX Plugin Manager
#============
if [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] && type tmux > /dev/null 2>&1; then
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

#============
# Workstation - Install ZSH
#============
if [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] && [[ "$SHELL" != *"zsh" ]]; then
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

#=============
# Install server packages
#=============
if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]] && [[ "$OSTYPE" == 'linux-gnu' ]]; then
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

#============
# Wallpapers
#============
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

#============
# macOS Workstation - Configuration
#============
if [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] && [[ "$OSTYPE" == "darwin"* ]]; then
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

#============
# Linux Workstation - Configuration
#============
if [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] && [[ "$OSTYPE" == "linux-gnu" ]]; then
	while read -p "Do you want to configure preferences? (Y/n) " -n 1 -r; do
		echo -e 2>&1 | logc
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then

			# Ask for the administrator password upfront
			echo -e "Starting configuration process..." 2>&1 | logc
			sudo -v

			# Add current user to necessary groups
			sudo usermod -a -G wheel,video,audio,group,network,sys,lp "$(whoami)" 2>&1 | lognoc

			# Enable Master channel sound output
			if type amixer > /dev/null 2>&1; then amixer sset Master unmute 2>&1 | lognoc; fi

			# Build the 'locate' database
			if type updatedb > /dev/null 2>&1; then	sudo updatedb 2>&1 | lognoc; fi

			# Enable services at boot
			if type docker > /dev/null 2>&1; then sudo systemctl enable docker 2>&1 | lognoc; fi
			if type containerd > /dev/null 2>&1; then sudo systemctl enable containerd 2>&1 | lognoc; fi
			if type teamviewer > /dev/null 2>&1; then sudo systemctl enable teamviewerd 2>&1 | lognoc; fi
			if type nmtui > /dev/null 2>&1; then sudo systemctl enable NetworkManager 2>&1 | lognoc; fi
			if type ntpd > /dev/null 2>&1; then sudo systemctl enable ntpd 2>&1 | lognoc; fi
			if type logrotate > /dev/null 2>&1; then sudo systemctl enable logrotate 2>&1 | lognoc; fi
			if type avahi-daemon > /dev/null 2>&1; then sudo systemctl enable avahi-daemon 2>&1 | lognoc; fi
			if type cups > /dev/null 2>&1; then sudo systemctl enable cups 2>&1 | lognoc; fi
			if type bluetooth > /dev/null 2>&1; then sudo systemctl enable bluetooth 2>&1 | lognoc; fi
			if type crond > /dev/null 2>&1; then sudo systemctl enable cronie 2>&1 | lognoc; fi
			if type pritunl-client > /dev/null 2>&1; then sudo systemctl enable pritunl-client 2>&1 | lognoc; fi
			if type syslog-ng > /dev/null 2>&1; then sudo systemctl enable syslog-ng@default.service 2>&1 | lognoc; fi

			# Add current to 'wireshark' group if need be
			if type wireshark > /dev/null 2>&1; then sudo usermod -a -G wireshark "$(whoami)" 2>&1 | lognoc; fi

			echo -e "Preferences configured" 2>&1 | logc
			echo -e 2>&1 | logc
			break
		elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
			echo -e
			break
		fi
	done
fi

#============
# Arch Linux - GUI Requirements
#============
if [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] && [[ ! -h /etc/arch-release ]] && [[ "$TERM" == "linux" ]]; then
	while read -p "Do you want to install the necessary software for a GUI environment? (Y/n) " -n 1 -r; do
		echo -e 2>&1 | logc
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then
			cd "$HOME" && curl -fsSLO "$applist" 2>&1 | lognoc
			echo -e "Installing necessary software for a GUI environment..." 2>&1 | logc
			grepxpkg && installxpkg && installvideodriver
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

#============
# Arch Linux - DE/WM Installation
#============
if [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] && [[ "$OSTYPE" == 'linux-gnu' ]] && [[ ! -h /etc/arch-release ]] && type Xorg > /dev/null 2>&1; then
while read -p "Do you want to install a custom graphical environment now? (Y/n) " -n 1 -r; do
	echo -e 2>&1 | logc
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		while read -p "Choose a custom environment from the following options: [1] DWM | [2] LeftWM | [9] Cancel (Ex.: type 1 for DWM): " -n 1 -r; do
			echo -e 2>&1 | logc
			if [[ "$REPLY" == 1 ]]; then
				echo -e "Installing DWM..." 2>&1 | logc
				installxinitrc
				installdwm && installdmenu && installst
				installlibxftbgra
				sed -i '/export SESSION="*"/c export SESSION="dwm"' "$HOME"/.xinitrc 2>&1 | lognoc
				echo -e "DWM installed" 2>&1 | logc
				echo -e 2>&1 | logc
				break
			elif [[ "$REPLY" == 2 ]]; then
				echo -e "Installing LeftWM..." 2>&1 | logc
				installxinitrc
				installleftwm && installdmenu && installst
				installlibxftbgra
				sed -i '/export SESSION="*"/c export SESSION="leftwm"' "$HOME"/.xinitrc 2>&1 | lognoc
				echo -e "LeftWM installed" 2>&1 | logc
				break
			elif [[ "$REPLY" == 9 ]]; then
				echo -e 2>&1 | logc
				break
			fi
		done
		break
		# Replace DMenu by Rofi
		if type rofi > /dev/null 2>&1; then
			rofi=$(which rofi)
			ln -sf "$rofi" "$scriptsloc"/dmenu 2>&1 | lognoc
		fi
	elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
		echo -e 2>&1 | logc
		break
	fi
done
fi

#==============
# Git Repositories
#==============
if [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] && [[ -d "$gitrepoloc" ]]; then
	echo -e "Symlinking binaries from Git repositories..." 2>&1 | logc
	if [[ ! -d "$gitrepoloc/bin" ]]; then mkdir -pv "$gitrepoloc/bin" 2>&1 | lognoc ; fi
	find "$gitrepoloc" -maxdepth 3 -perm -111 -type f -exec ln -sf '{}' "$gitrepoloc/bin" ';' 2>&1 | lognoc
	rm -Rf "$gitrepoloc/bin/test" 2>&1 | lognoc
	echo -e "Git repos' binaries symlinked" 2>&1 | logc
	echo -e 2>&1 | logc
fi

#==============
# Perl Dependencies
#==============
if [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] && [[ -d "$gitrepoloc" ]] && type perl > /dev/null 2>&1; then
	echo -e "Installing Perl dependencies..." 2>&1 | logc
	installperldeps
	echo -e "Perl dependencies installed" 2>&1 | logc
	echo -e 2>&1 | logc
fi

#==============
# Python Dependencies
#==============
if [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] && [[ -d "$gitrepoloc" ]] && type python > /dev/null 2>&1; then
	echo -e "Installing Python dependencies..." 2>&1 | logc
	installpythondeps
	echo -e "Python dependencies installed" 2>&1 | logc
	echo -e 2>&1 | logc
fi

#==============
# Dotfiles
#==============
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
				mv "$HOME"/.gitconfig "$HOME"/.old-dotfiles/gitconfig > /dev/null 2>&1
				if [[ -f "$HOME"/.msmtprc ]]; then mv "$HOME"/.msmtprc "$HOME"/.old-dotfiles/msmtprc > /dev/null 2>&1; else mv "$HOME"/.config/msmtp "$HOME"/.old-dotfiles/msmtp > /dev/null 2>&1; fi
				if [[ -f "$HOME"/.tmux.conf ]]; then mv "$HOME"/.tmux.conf "$HOME"/.old-dotfiles/tmux.conf > /dev/null 2>&1; else mv "$HOME"/.config/tmux/tmux.conf "$HOME"/.old-dotfiles/tmux.conf > /dev/null 2>&1; fi
				if [[ -f "$HOME"/.screenrc ]]; then mv "$HOME"/.screenrc "$HOME"/.old-dotfiles/screenrc > /dev/null 2>&1; else mv "$HOME"/.config/screen/screenrc "$HOME"/.old-dotfiles/screenrc > /dev/null 2>&1; fi
				mv "$HOME"/.vim "$HOME"/.old-dotfiles/vim > /dev/null 2>&1
				mv "$HOME"/.vimrc "$HOME"/.old-dotfiles/vimrc > /dev/null 2>&1
				if [[ -f "$HOME"/.p10k.zsh ]]; then mv "$HOME"/.p10k.zsh "$HOME"/.old-dotfiles/p10k.zsh > /dev/null 2>&1; else mv "$HOME"/.config/zsh/.p10k.zsh "$HOME"/.old-dotfiles/p10k.zsh > /dev/null 2>&1; fi
				if [[ -f "$HOME"/starship.toml ]]; then mv "$HOME"/starship.toml "$HOME"/.old-dotfiles/starship.toml > /dev/null 2>&1; else mv "$HOME"/.config/starship.toml "$HOME"/.old-dotfiles/starship.toml > /dev/null 2>&1; fi
				if [[ -f "$HOME"/.zshrc ]]; then mv "$HOME"/.zshrc "$HOME"/.old-dotfiles/zshrc > /dev/null 2>&1; else mv "$HOME"/.config/zsh/.zshrc "$HOME"/.old-dotfiles/zshrc > /dev/null 2>&1; fi
				mv "$HOME"/.zprofile "$HOME"/.old-dotfiles/zprofile > /dev/null 2>&1
				mv "$HOME"/.zshenv "$HOME"/.old-dotfiles/zshenv > /dev/null 2>&1
				mv "$HOME"/.config/nvim/init.vim "$HOME"/.old-dotfiles/init.vim > /dev/null 2>&1
				mv "$HOME"/.config/nvim "$HOME"/.old-dotfiles/nvim > /dev/null 2>&1
				mv "$HOME"/.config/wget "$HOME"/.old-dotfiles/wget > /dev/null 2>&1
				mv "$HOME"/.config/alacritty "$HOME"/.old-dotfiles/alacritty > /dev/null 2>&1
				mv "$HOME"/.config/kitty "$HOME"/.old-dotfiles/kitty > /dev/null 2>&1
				mv "$HOME"/.config/termite "$HOME"/.old-dotfiles/termite > /dev/null 2>&1
				mv "$HOME"/.w3m "$HOME"/.old-dotfiles/w3m > /dev/null 2>&1
				mv "$HOME"/.config/surfraw/conf "$HOME"/.old-dotfiles/surfraw > /dev/null 2>&1
				mv "$HOME"/.config/newsboat/config "$HOME"/.old-dotfiles/newsboat-config > /dev/null 2>&1
				mv "$HOME"/.config/newsboat/urls "$HOME"/.old-dotfiles/newsboat-urls > /dev/null 2>&1
				mv "$HOME"/.config/redshift.conf "$HOME"/.old-dotfiles/redshift.conf > /dev/null 2>&1
				mv "$HOME"/.config/PulseEffects/output/MySettings.json "$HOME"/.old-dotfiles/PulseEffects-Output_MySettings.json > /dev/null 2>&1
				mv "$HOME"/.config/dunst/dunstrc "$HOME"/.old-dotfiles/dunstrc > /dev/null 2>&1
				mv "$HOME"/.config/rofi/config.rasi "$HOME"/.old-dotfiles/rofi-config.rasi > /dev/null 2>&1
				mv "$HOME"/.config/sxhkd/sxhkdrc "$HOME"/.old-dotfiles/sxhkdrc > /dev/null 2>&1
				if [[ -d "$HOME"/.moc ]]; then mv "$HOME"/.moc "$HOME"/.old-dotfiles/moc > /dev/null 2>&1; else mv "$HOME"/.config/moc "$HOME"/.old-dotfiles/moc > /dev/null 2>&1; fi
				break
			elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
				rm -Rf "$HOME"/.bash_profile
				rm -Rf "$HOME"/.bashrc
				rm -Rf "$HOME"/.gitconfig
				if [[ -f "$HOME"/.msmtprc ]]; then rm -Rf "$HOME"/.msmtprc; else rm -Rf "$HOME"/.config/msmtp; fi
				if [[ -f "$HOME"/.p10k.zsh ]]; then rm -Rf "$HOME"/.p10k.zsh; else rm -Rf "$HOME"/.config/zsh/.p10k.zsh; fi
				if [[ -f "$HOME"/starship.toml ]]; then rm -Rf "$HOME"/starship.toml; else rm -Rf "$HOME"/.config/starship.toml; fi
				if [[ -f "$HOME"/.tmux.conf ]]; then rm -Rf "$HOME"/.tmux.conf; else rm -Rf "$HOME"/.config/tmux/tmux.conf; fi
				if [[ -f "$HOME"/screenrc ]]; then rm -Rf "$HOME"/screenrc; else rm -Rf "$HOME"/.config/screen/screenrc; fi
				rm -Rf "$HOME"/.vim
				rm -Rf "$HOME"/.vimrc
				if [[ -f "$HOME"/.zshrc ]]; then rm -Rf "$HOME"/.zshrc; else rm -Rf "$HOME"/.config/zsh/.zshrc; fi
				rm -Rf "$HOME"/.zprofile
				rm -Rf "$HOME"/.zshenv
				rm -Rf "$HOME"/.config/nvim/init.vim
				rm -Rf "$HOME"/.config/nvim
				rm -Rf "$HOME"/.config/wget
				rm -Rf "$HOME"/.config/alacritty
				rm -Rf "$HOME"/.config/kitty
				rm -Rf "$HOME"/.config/termite
				rm -Rf "$HOME"/.w3m
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
				if [[ -d "$HOME"/.moc ]]; then rm -Rf "$HOME"/.moc; else rm -Rf "$HOME"/.config/moc; fi
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
		if [[ ! -d "$scriptsloc/statusbar" ]]; then mkdir -pv "$scriptsloc/statusbar" 2>&1 | lognoc ; fi
		ln -sf "$dfloc"/local/bin/statusbar/* "$scriptsloc/statusbar/" 2>&1 | lognoc
		if [[ ! -d "$HOME"/.config ]]; then mkdir -pv "$HOME"/.config 2>&1 | lognoc ; fi
		if type bash > /dev/null 2>&1; then
			ln -sf "$dfloc"/shellconfig/bashrc "$HOME"/.bashrc 2>&1 | lognoc
			touch "$HOME"/.bash_profile && echo -e "source $HOME/.bashrc" > "$HOME"/.bash_profile
		fi
		if type zsh > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/zsh ]]; then
				mkdir -pv "$HOME"/.config/zsh 2>&1 | lognoc
			fi
			ln -sf "$dfloc"/shellconfig/zshrc "$HOME"/.config/zsh/.zshrc 2>&1 | lognoc
			ln -sf "$dfloc"/shellconfig/zshenv "$HOME"/.zshenv 2>&1 | lognoc
		fi
		## Starship is symlinked as it needs to be present BEFORE the installation of starship
		ln -sf "$dfloc"/config/starship/starship.toml "$HOME"/.config/starship.toml 2>&1 | lognoc
		if type git > /dev/null 2>&1; then
			ln -sf "$dfloc"/gitconfig "$HOME"/.gitconfig 2>&1 | lognoc
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
				mkdir -pv "$HOME"/.config/alacritty 2>&1 | lognoc && ln -sf "$dfloc"/config/alacritty/alacritty-macos.yml "$HOME"/.config/alacritty/alacritty.yml 2>&1 | lognoc
			elif [[ "$OSTYPE" == "linux-gnu" ]]; then
				mkdir -pv "$HOME"/.config/alacritty 2>&1 | lognoc && ln -sf "$dfloc"/config/alacritty/alacritty-linux.yml "$HOME"/.config/alacritty/alacritty.yml 2>&1 | lognoc
			fi
		fi
		if type kitty > /dev/null 2>&1 || [[ -d /Applications/Kitty.app ]]; then
			if [[ ! -d "$HOME"/.config/kitty ]]; then
				mkdir -pv "$HOME"/.config/kitty 2>&1 | lognoc
			fi
			if [[ "$OSTYPE" == "darwin"* ]]; then
				mkdir -pv "$HOME"/.config/kitty 2>&1 | lognoc && ln -sf "$dfloc"/config/kitty/kitty.conf "$HOME"/.config/kitty/kitty.conf 2>&1 | lognoc
			elif [[ "$OSTYPE" == "linux-gnu" ]]; then
				mkdir -pv "$HOME"/.config/kitty 2>&1 | lognoc && ln -sf "$dfloc"/config/kitty/kitty.conf "$HOME"/.config/kitty/kitty.conf 2>&1 | lognoc
			fi
		fi
		if type termite > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/termite ]]; then
				mkdir -pv "$HOME"/.config/termite 2>&1 | lognoc
			fi
			ln -sf "$dfloc"/config/termite/config "$HOME"/.config/termite/config 2>&1 | lognoc
		fi
		if [[ -d /Applications/iTerm.app ]]; then
			ln -sf "$dfloc"/iterm2 "$HOME"/.iterm5 > /dev/null 2>&1
		fi
		if type w3m > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.w3m ]]; then
				mkdir -pv "$HOME"/.w3m 2>&1 | lognoc
			fi
			ln -sf "$dfloc"/w3m/config "$HOME"/.w3m/config 2>&1 | lognoc
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
			if type tsp > /dev/null 2>&1; then
				ln -sf "$dfloc"/config/newsboat/config-tsp "$HOME"/.config/newsboat/config 2>&1 | lognoc
				ln -sf "$dfloc"/config/newsboat/urls "$HOME"/.config/newsboat/urls 2>&1 | lognoc
			else
				ln -sf "$dfloc"/config/newsboat/config-ts "$HOME"/.config/newsboat/config 2>&1 | lognoc
				ln -sf "$dfloc"/config/newsboat/urls "$HOME"/.config/newsboat/urls 2>&1 | lognoc
			fi
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
		if type mocp > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/moc ]]; then
				mkdir -pv "$HOME"/.config/moc 2>&1 | lognoc
			fi
			ln -sf "$dfloc"/config/moc/config "$HOME"/.config/moc/ 2>&1 | lognoc
			ln -sf "$dfloc"/config/moc/themes "$HOME"/.config/moc/ 2>&1 | lognoc
		fi
		if type dunst > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/dunst ]]; then
				mkdir -pv "$HOME"/.config/dunst 2>&1 | lognoc
			fi
			ln -sf "$dfloc"/config/dunst/dunstrc "$HOME"/.config/dunst/ 2>&1 | lognoc
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
			ln -sf "$dfloc"/config/sxhkd/sxhkdrc "$HOME"/.config/sxhkd/ 2>&1 | lognoc
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
		if [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] && [[ "$OSTYPE" == "linux-gnu" ]] && [[ -z "$XDG_CURRENT_DESKTOP" ]] && [[ -d /usr/share/themes/Adwaita-dark ]] && [[ -d /usr/share/icons/Papirus-Dark ]]; then
			echo -e "No desktop environment has been detected on the system." 2>&1 | logc
			while read -p "Do you want to install the GTK dotfiles? (Y/n) " -n 1 -r; do
				echo -e 2>&1 | logc
				if [[ "$REPLY" =~ ^[Yy]$ ]]; then
					if [[ ! -d "$HOME"/.config/gtk-3.0 ]]; then
						mkdir -pv "$HOME"/.config/gtk-3.0 2>&1 | lognoc
					elif [[ -f "$HOME"/.config/gtk-3.0/settings.ini ]]; then
						rm -Rf "$HOME"/.config/gtk-3.0/settings.ini
					fi
					ln -sf "$dfloc"/config/gtk-3.0/settings.ini "$HOME"/.config/gtk-3.0/ 2>&1 | lognoc
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

					echo -e "GTK dotfiles installed" 2>&1 | logc
					echo -e 2>&1 | logc
					break
				elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
					echo -e
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

#==============
# macOS Workstation - Amethyst Configuration
#==============
if [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] && [[ "$OSTYPE" == "darwin"* ]] && [[ -d /Applications/Amethyst.app ]]; then
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

#==============
# DONE
#==============
echo -e 2>&1 | logc
echo -e 2>&1 | logc
echo -e "======= ALL DONE =======" 2>&1 | logc
echo -e 2>&1 | logc
echo -e "Please reboot the computer for all the settings to be applied (not applicable for servers)." 2>&1 | logc
echo -e "A log file called \"$logfile\" contains the details of all operations. Check it for errors." 2>&1 | logc