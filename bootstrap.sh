#!/bin/bash
#
# Description: this script automates the installation of my personal computer
# Compatibility: it works for both macOS and Linux

#=============
# Global Variables
#=============

# Dotfiles location
dfloc="$HOME/projects/dotfiles"
dfrepo="https://github.com/GSquad934/dotfiles.git"

# Custom scripts location
scriptsloc="$HOME/scripts"
scriptsrepo="https://github.com/GSquad934/scripts.git"

# Git repositories location
gitrepoloc="$HOME/sources/repos"

# Software sources location
# sourceloc="$HOME/sources"

# Logging
date="$(date +%Y-%m-%d-%H%M%S)"
logfile="$HOME/bootstrap_log_$date.txt"

# Software lists
homebrew="https://raw.githubusercontent.com/Homebrew/install/master/install.sh"
aurhelper="https://aur.archlinux.org/yay.git"
applist="https://raw.githubusercontent.com/GSquad934/bootstrap/master/apps.csv"

# Font lists
mononoki_regular="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Mononoki/Regular/complete/mononoki-Regular%20Nerd%20Font%20Complete.ttf"
mononoki_bold="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Mononoki/Bold/complete/mononoki%20Bold%20Nerd%20Font%20Complete.ttf"
mononoki_italic="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Mononoki/Italic/complete/mononoki%20Italic%20Nerd%20Font%20Complete.ttf"
jetbrainsmono_regular="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Regular/complete/JetBrains%20Mono%20Regular%20Nerd%20Font%20Complete.ttf"
jetbrainsmono_bold="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Bold/complete/JetBrains%20Mono%20Bold%20Nerd%20Font%20Complete.ttf"
jetbrainsmono_italic="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/JetBrainsMono/Italic/complete/JetBrains%20Mono%20Italic%20Nerd%20Font%20Complete.ttf"
sourcecodepro_regular="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/SourceCodePro/Regular/complete/Sauce%20Code%20Pro%20Nerd%20Font%20Complete.ttf"
sourcecodepro_bold="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/SourceCodePro/Bold/complete/Sauce%20Code%20Pro%20Bold%20Nerd%20Font%20Complete.ttf"
sourcecodepro_italic="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/SourceCodePro/Italic/complete/Sauce%20Code%20Pro%20Italic%20Nerd%20Font%20Complete.ttf"
powerline_fonts="https://github.com/powerline/fonts"

# TMUX Plugins
tpm="https://github.com/tmux-plugins/tpm"

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
	installpkg(){ brew update 2>&1 | lognoc && < "$pkg" xargs brew install 2>&1 | lognoc ;}
	installguipkg(){ brew update 2>&1 | lognoc && < "$guipkg" xargs brew install --cask 2>&1 | lognoc ;}
	installworkpkg(){ brew update 2>&1 | lognoc && < "$workpkg" xargs brew install 2>&1 | lognoc ;}
	installworkguipkg(){ brew update 2>&1 | lognoc && < "$workguipkg" xargs brew install --cask 2>&1 | lognoc ;}
	installzsh() {
		brew install zsh 2>&1 | lognoc
		chmod g-w "$(brew --prefix)/share" 2>&1 | lognoc
		chmod g-w "$(brew --prefix)/share/zsh" 2>&1 | lognoc
		chmod g-w "$(brew --prefix)/share/zsh/sites-functions" 2>&1 | lognoc
		git clone https://github.com/zplug/zplug "$HOME"/.config/zsh/zplug
	}
elif type apt-get > /dev/null 2>&1; then
	greppkg(){ pkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[D][^,]*" | sed '/^W/d' | sed 's/^.*,//g' > "$pkg" ;}
	grepworkpkg(){ workpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[D][^,]*" | sed 's/^.*,//g' > "$workpkg" ;}
	installpkg(){ sudo apt-get update 2>&1 | lognoc && while IFS= read -r line; do sudo apt-get install -y "$line" 2>&1 | lognoc; done < "$pkg" ;}
	installworkpkg(){ sudo apt-get update 2>&1 | lognoc && while IFS= read -r line; do sudo apt-get install -y "$line" 2>&1 | lognoc; done < "$workpkg" ;}
	installsudo(){ apt-get update 2>&1 | lognoc && apt-get install -y sudo 2>&1 | lognoc ;}
	installzsh(){ sudo apt-get update 2>&1 | lognoc && sudo apt-get install -y zsh 2>&1 | lognoc && git clone https://github.com/zplug/zplug "$HOME"/.config/zsh/zplug 2>&1 | lognoc ;}
elif type yum > /dev/null 2>&1; then
	greppkg(){ pkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[R][^,]*" | sed '/^W/d' | sed 's/^.*,//g' > "$pkg" ;}
	grepworkpkg(){ workpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[R][^,]*" | sed 's/^.*,//g' > "$workpkg" ;}
	installpkg(){ sudo yum update -y 2>&1 | lognoc && while IFS= read -r line; do sudo yum install -y "$line" 2>&1 | lognoc; done < "$pkg" ;}
	installworkpkg(){ sudo yum update -y 2>&1 | lognoc && while IFS= read -r line; do sudo yum install -y "$line" 2>&1 | lognoc; done < "$workpkg" ;}
	installsudo(){ yum update -y 2>&1 | lognoc && yum install -y sudo 2>&1 | lognoc ;}
	installzsh(){ sudo yum update -y 2>&1 | lognoc && sudo yum install -y zsh 2>&1 | lognoc && git clone https://github.com/zplug/zplug "$HOME"/.config/zsh/zplug 2>&1 | lognoc ;}
elif type pacman yay > /dev/null 2>&1; then
	greppkg(){ pkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[A][^,]*" | sed '/^W/d' | sed 's/^.*,//g' > "$pkg" ;}
	grepworkpkg(){ workpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[A][^,]*" | sed 's/^.*,//g' > "$workpkg" ;}
	installpkg(){ sudo pacman -Syu --noconfirm 2>&1 | lognoc && while IFS= read -r line; do sudo pacman --noconfirm --needed -S "$line" 2>&1 | lognoc; done < "$pkg" ;}
	installworkpkg(){ sudo pacman -Syu --noconfirm 2>&1 | lognoc && while IFS= read -r line; do sudo pacman --noconfirm --needed -S "$line" 2>&1 | lognoc; done < "$workpkg" ;}
	installsudo(){ pacman -Syu --noconfirm 2>&1 | lognoc && pacman --noconfirm --needed -S sudo 2>&1 | lognoc ;}
	installzsh(){ sudo pacman -Syu --noconfirm 2>&1 | lognoc && sudo pacman --needed --noconfirm -S zsh 2>&1 | lognoc && git clone https://github.com/zplug/zplug "$HOME"/.config/zsh/zplug 2>&1 | lognoc ;}
	grepaurpkg(){ aurpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[Y][^,]*" | sed '/^W/d' | sed 's/^.*,//g' > "$aurpkg" ;}
	grepworkaurpkg(){ workaurpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[Y][^,]*" | sed 's/^.*,//g' > "$workaurpkg" ;}
	installaurpkg(){ while IFS= read -r line; do yay ---answerclean All --answerdiff None --nocleanmenu --nodiffmenu -S "$line" 2>&1 | lognoc; done < "$aurpkg" ;}
	installworkaurpkg(){ while IFS= read -r line; do yay ---answerclean All --answerdiff None --nocleanmenu --nodiffmenu -S "$line" 2>&1 | lognoc; done < "$workaurpkg" ;}
elif type pacman > /dev/null 2>&1; then
	greppkg(){ pkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[A][^,]*" | sed '/^W/d' | sed 's/^.*,//g' > "$pkg" ;}
	grepworkpkg(){ workpkg=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[A][^,]*" | sed 's/^.*,//g' > "$workpkg" ;}
	installpkg(){ sudo pacman -Syu --noconfirm 2>&1 | lognoc && while IFS= read -r line; do sudo pacman --noconfirm --needed -S "$line" 2>&1 | lognoc; done < "$pkg" ;}
	installworkpkg(){ sudo pacman -Syu --noconfirm 2>&1 | lognoc && while IFS= read -r line; do sudo pacman --noconfirm --needed -S "$line" 2>&1 | lognoc; done < "$workpkg" ;}
	installsudo(){ pacman -Syu --noconfirm 2>&1 | lognoc && pacman --noconfirm --needed -S sudo 2>&1 | lognoc ;}
	installzsh(){ sudo pacman -Syu --noconfirm 2>&1 | lognoc && sudo pacman --needed --noconfirm -S zsh 2>&1 | lognoc && git clone https://github.com/zplug/zplug "$HOME"/.config/zsh/zplug 2>&1 | lognoc ;}
fi

grepstoreapp(){ if type mas > /dev/null 2>&1; then storeapp=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[S][^,]*" | sed '/^W/d' | sed 's/^.*,//g' | awk '{print $1}' > "$storeapp"; fi ;}
grepworkstoreapp(){ if type mas > /dev/null 2>&1; then workstoreapp=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[S][^,]*" | sed 's/^.*,//g' | awk '{print $1}' > "$workstoreapp"; fi ;}
installstoreapp(){ if type mas > /dev/null 2>&1; then < "$storeapp" xargs mas install 2>&1 | lognoc; fi ;}
installworkstoreapp(){ if type mas > /dev/null 2>&1; then < "$workstoreapp" xargs mas install 2>&1 | lognoc; fi ;}

grepgitrepo(){ if type git > /dev/null 2>&1; then repo=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[G][^,]*" | sed '/^W/d' | sed 's/^.*,//g' | awk '{print $1}' > "$repo"; fi ;}
grepworkgitrepo(){ if type git > /dev/null 2>&1; then	workrepo=$(mktemp) && sed '/^#/d' "$HOME"/apps.csv | grep "[G][^,]*" | sed 's/^.*,//g' | awk '{print $1}' > "$workrepo" ; fi ;}
installgitrepo(){ if [[ ! -d "$gitrepoloc" ]]; then mkdir -p "$gitrepoloc" > /dev/null 2>&1; fi && if type git > /dev/null 2>&1; then < "$repo" xargs -n1 -I url git -C "$gitrepoloc" clone url 2>&1 | lognoc; fi ;}
installworkgitrepo(){ if [[ ! -d "$gitrepoloc" ]]; then mkdir -p "$gitrepoloc" > /dev/null 2>&1; fi && if type git > /dev/null 2>&1; then < "$workrepo" xargs -n1 -I url git -C "$gitrepoloc" clone url 2>&1 | lognoc; fi ;}

installperldeps(){
	perlx=$(find "$gitrepoloc" -maxdepth 3 -perm -111 -type f -name '*.pl')
	# Nikto
	if [[ "$perlx" =~ nikto.pl ]]; then
		if ! perl -MNet::SSLeay -e 1 > /dev/null 2>&1; then
			if type apt-get > /dev/null 2>&1; then
				sudo apt-get update 2>&1 | lognoc && sudo apt-get install -y libnet-ssleay-perl 2>&1 | lognoc
			elif type cpanm > /dev/null 2>&1; then
				cpanm --force Net::SSLeay 2>&1 | lognoc
			fi
		fi
	fi
}

installpythondeps(){
	pythonx=$(find "$gitrepoloc" -maxdepth 3 -perm -111 -type f -name '*.py')
	# VxAPI
	if [[ "$pythonx" =~ vxapi.py ]]; then
		pip install requests colorama 2>&1 | lognoc
	fi
}


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
			installsrvpkg(){ sudo pacman --noconfirm --needed -Sy 2>&1 | lognoc && while IFS= read -r line; do sudo pacman --noconfirm --needed -S "$line" 2>&1 | lognoc; done < "$srvpkg" ;}
		fi
	fi
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
		echo -e "Package 'sudo' is now installed" 2>&1 | logc
		echo -e "Please configure sudo with the command \"visudo\"" 2>&1 | logc
		echo -e "Once sudo is configured, run this script again with a normal user with sudo rights" 2>&1 | logc
		echo -e 2>&1 | logc
		exit 0
	fi
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
# Linux - Install 'sudo' (Requirement)
#=============
if [[ "$OSTYPE" == "linux-gnu" ]] && ! type sudo > /dev/null 2>&1; then
	echo -e "The package 'sudo' is not installed on the system" 2>&1 | logc
	echo -e "Installing 'sudo'..." 2>&1 | logc
	if [[ "$EUID" != 0 ]]; then
		echo -e "Please run the script as root in order to install the requirements" 2>&1 | logc
		exit 1
	else
		installsudo
		echo -e "Package 'sudo' is now installed" 2>&1 | logc
		echo -e "Please configure sudo with the command \"visudo\"" 2>&1 | logc
		echo -e "Once sudo is configured, run this script again with a normal user with sudo rights" 2>&1 | logc
		echo -e 2>&1 | logc
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
					git clone "$aurhelper" "$HOME"/yay 2>&1 | lognoc
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
				mkdir "$HOME"/fonts
				if type wget > /dev/null 2>&1; then
					wget -c --content-disposition -P "$HOME"/fonts/ "$mononoki_regular" 2>&1 | lognoc
					wget -c --content-disposition -P "$HOME"/fonts/ "$mononoki_bold" 2>&1 | lognoc
					wget -c --content-disposition -P "$HOME"/fonts/ "$mononoki_italic" 2>&1 | lognoc
					wget -c --content-disposition -P "$HOME"/fonts/ "$jetbrainsmono_regular" 2>&1 | lognoc
					wget -c --content-disposition -P "$HOME"/fonts/ "$jetbrainsmono_bold" 2>&1 | lognoc
					wget -c --content-disposition -P "$HOME"/fonts/ "$jetbrainsmono_italic" 2>&1 | lognoc
					wget -c --content-disposition -P "$HOME"/fonts/ "$sourcecodepro_regular" 2>&1 | lognoc
					wget -c --content-disposition -P "$HOME"/fonts/ "$sourcecodepro_bold" 2>&1 | lognoc
					wget -c --content-disposition -P "$HOME"/fonts/ "$sourcecodepro_italic" 2>&1 | lognoc
				elif type curl > /dev/null 2>&1; then
					cd "$HOME"/fonts || exit
					curl -fSLO "$mononoki_regular" 2>&1 | lognoc
					curl -fSLO "$mononoki_bold" 2>&1 | lognoc
					curl -fSLO "$mononoki_italic" 2>&1 | lognoc
					curl -fSLO "$jetbrainsmono_regular" 2>&1 | lognoc
					curl -fSLO "$jetbrainsmono_bold" 2>&1 | lognoc
					curl -fSLO "$jetbrainsmono_italic" 2>&1 | lognoc
					curl -fSLO "$sourcecodepro_regular" 2>&1 | lognoc
					curl -fSLO "$sourcecodepro_bold" 2>&1 | lognoc
					curl -fSLO "$sourcecodepro_italic" 2>&1 | lognoc
					for i in *; do mv "$i" "$(echo "$i" | sed 's/%20/ /g')"; done
				fi
				if [[ "$OSTYPE" == "darwin"* ]]; then
					mv "$HOME"/fonts/*.ttf "$HOME"/Library/Fonts/ 2>&1 | lognoc
				elif [[ "$OSTYPE" == "linux-gnu" ]]; then
					if [[ ! -d /usr/share/fonts ]]; then
						sudo mkdir /usr/share/fonts
					fi
					if type fc-cache > /dev/null 2>&1; then
						sudo mv "$HOME"/fonts/*.ttf /usr/share/fonts/ && fc-cache 2>&1 | lognoc
					else
						echo -e "Please install a font configuration handler such as 'fontconfig'!" 2>&1 | logc
						exit 1
					fi
				fi
				echo -e 2>&1 | logc
				git clone "$powerline_fonts" "$HOME"/fonts 2>&1 | lognoc && "$HOME"/fonts/install.sh
				cd "$HOME" || exit
				rm -Rf "$HOME"/fonts > /dev/null 2>&1
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
				git clone "$tpm" "$HOME"/.config/tmux/plugins/tpm 2>&1 | lognoc
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
				git clone "$tpm" "$HOME"/.config/tmux/plugins/tpm 2>&1 | lognoc
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
						if [[ "$name" =~ ^[A-z0-9-]{0,15}$ ]]; then
							sudo scutil --set ComputerName "$name"
							sudo scutil --set LocalHostName "$name"
							sudo scutil --set HostName "$name"
							echo -e "Computer's name successfully changed" 2>&1 | logc
							echo -e 2>&1 | logc
							break
						else
							echo -e "Invalid computer name! The name should be between 1 and 15 characters and must not contain special characters except \"-\"" 2>&1 | logc
							echo -e 2>&1 | logc
						fi
					done
				break
				elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
					echo -e
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

			# Build the 'locate' database
			if type updatedb > /dev/null 2>&1; then
				sudo updatedb
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
			git clone --recurse-submodules "$dfrepo" "$dfloc" 2>&1 | lognoc
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
					mkdir "$HOME"/.old-dotfiles > /dev/null 2>&1
				else
					rm -Rf "$HOME"/.old-dotfiles > /dev/null 2>&1
					mkdir "$HOME"/.old-dotfiles > /dev/null 2>&1
				fi
				mv "$HOME"/.bash_profile "$HOME"/.old-dotfiles/bash_profile > /dev/null 2>&1
				mv "$HOME"/.bashrc "$HOME"/.old-dotfiles/bashrc > /dev/null 2>&1
				mv "$HOME"/.gitconfig "$HOME"/.old-dotfiles/gitconfig > /dev/null 2>&1
				if [[ -f "$HOME"/.msmtprc ]]; then mv "$HOME"/.msmtprc "$HOME"/.old-dotfiles/msmtprc > /dev/null 2>&1; else mv "$HOME"/.config/msmtp "$HOME"/.old-dotfiles/msmtp > /dev/null 2>&1; fi
				if [[ -f "$HOME"/.tmux.conf ]]; then mv "$HOME"/.tmux.conf "$HOME"/.old-dotfiles/tmux.conf > /dev/null 2>&1; else mv "$HOME"/.config/tmux/tmux.conf "$HOME"/.old-dotfiles/tmux.conf > /dev/null 2>&1; fi
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
				mv "$HOME"/.config/vifm "$HOME"/.old-dotfiles/vifm > /dev/null 2>&1
				mv "$HOME"/.config/alacritty "$HOME"/.old-dotfiles/alacritty > /dev/null 2>&1
				mv "$HOME"/.w3m "$HOME"/.old-dotfiles/w3m > /dev/null 2>&1
				mv "$HOME"/.config/surfraw/conf "$HOME"/.old-dotfiles/surfraw > /dev/null 2>&1
				mv "$HOME"/.config/newsboat "$HOME"/.old-dotfiles/newsboat > /dev/null 2>&1
				break
			elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
				rm -rf "$HOME"/.bash_profile
				rm -rf "$HOME"/.bashrc
				rm -rf "$HOME"/.gitconfig
				if [[ -f "$HOME"/.msmtprc ]]; then rm -rf "$HOME"/.msmtprc; else rm -Rf "$HOME"/.config/msmtp; fi
				if [[ -f "$HOME"/.p10k.zsh ]]; then rm -rf "$HOME"/.p10k.zsh; else rm -Rf "$HOME"/.config/zsh/.p10k.zsh; fi
				if [[ -f "$HOME"/starship.toml ]]; then rm -rf "$HOME"/starship.toml else rm -Rf "$HOME"/.config/starship.toml; fi
				if [[ -f "$HOME"/.tmux.conf ]]; then rm -rf "$HOME"/.tmux.conf; else rm -Rf "$HOME"/.config/tmux/tmux.conf; fi
				rm -rf "$HOME"/.vim
				rm -rf "$HOME"/.vimrc
				if [[ -f "$HOME"/.zshrc ]]; then rm -rf "$HOME"/.zshrc; else rm -Rf "$HOME"/.config/zsh/.zshrc; fi
				rm -rf "$HOME"/.zprofile
				rm -rf "$HOME"/.zshenv
				rm -rf "$HOME"/.config/nvim/init.vim
				rm -rf "$HOME"/.config/nvim
				rm -rf "$HOME"/.config/wget
				rm -rf "$HOME"/.config/vifm
				rm -rf "$HOME"/.config/alacritty
				rm -rf "$HOME"/.w3m
				rm -rf "$HOME"/.config/surfraw/conf
				rm -rf "$HOME"/.config/newsboat
				rm -rf "$HOME"/.config/weechat
				rm -rf "$HOME"/config/weechat/irc.conf 2>&1 | lognoc
				rm -rf "$HOME"/config/weechat/perl 2>&1 | lognoc
				rm -rf "$HOME"/config/weechat/python 2>&1 | lognoc
				rm -rf "$HOME"/config/weechat/trigger.conf 2>&1 | lognoc
				rm -rf "$HOME"/config/weechat/weechat.conf 2>&1 | lognoc
				rm -rf "$HOME"/config/weechat/xfer.conf 2>&1 | lognoc
				rm -rf "$HOME"/config/weechat/buflist.conf 2>&1 | lognoc
				rm -rf "$HOME"/config/weechat/colorize_nicks.conf 2>&1 | lognoc
				rm -rf "$HOME"/config/weechat/fset.conf 2>&1 | lognoc
				rm -rf "$HOME"/config/weechat/iset.conf 2>&1 | lognoc
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
						mkdir "$HOME"/.config/weechat
						mv "$HOME"/.old-dotfiles/weechat/sec.conf "$HOME"/.config/weechat/sec.conf
					else
						mv "$HOME"/.config/weechat/sec.conf "$HOME"/sec.conf
						rm -Rf "$HOME"/.config/weechat
						mkdir "$HOME"/.config/weechat
						mv "$HOME"/sec.conf "$HOME"/.config/weechat/sec.conf
					fi
					break
				fi
			done
		fi

		# Create symlinks in the home folder
		echo -e "Installing new dotfiles..." 2>&1 | logc
		if [[ ! -d "$HOME"/.config ]]; then mkdir "$HOME"/.config; fi
		if type bash > /dev/null 2>&1; then
			ln -s "$dfloc"/shellconfig/bashrc "$HOME"/.bashrc 2>&1 | lognoc
			touch "$HOME"/.bash_profile && echo -e "source $HOME/.bashrc" > "$HOME"/.bash_profile
		fi
		if type git > /dev/null 2>&1; then
			ln -s "$dfloc"/gitconfig "$HOME"/.gitconfig 2>&1 | lognoc
		fi
		if type zsh > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/zsh ]]; then
				mkdir -pv "$HOME"/.config/zsh 2>&1 | lognoc
			fi
			ln -s "$dfloc"/shellconfig/zshrc "$HOME"/.config/zsh/.zshrc 2>&1 | lognoc
			ln -s "$dfloc"/shellconfig/zshenv "$HOME"/.zshenv 2>&1 | lognoc
		fi
		if type starship > /dev/null 2>&1; then
			ln -s "$dfloc"/config/starship/starship.toml "$HOME"/.config/starship.toml 2>&1 | lognoc
		fi
		if type weechat > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/weechat ]]; then
				mkdir "$HOME"/.config/weechat 2>&1 | lognoc
			fi
			ln -s "$dfloc"/config/weechat/irc.conf "$HOME"/.config/weechat/irc.conf 2>&1 | lognoc
			ln -s "$dfloc"/config/weechat/perl "$HOME"/.config/weechat/perl 2>&1 | lognoc
			ln -s "$dfloc"/config/weechat/python "$HOME"/.config/weechat/python 2>&1 | lognoc
			ln -s "$dfloc"/config/weechat/trigger.conf "$HOME"/.config/weechat/trigger.conf 2>&1 | lognoc
			ln -s "$dfloc"/config/weechat/weechat.conf "$HOME"/.config/weechat/weechat.conf 2>&1 | lognoc
			ln -s "$dfloc"/config/weechat/xfer.conf "$HOME"/.config/weechat/xfer.conf 2>&1 | lognoc
			ln -s "$dfloc"/config/weechat/buflist.conf "$HOME"/.config/weechat/buflist.conf 2>&1 | lognoc
			ln -s "$dfloc"/config/weechat/colorize_nicks.conf "$HOME"/.config/weechat/colorize_nicks.conf 2>&1 | lognoc
			ln -s "$dfloc"/config/weechat/fset.conf "$HOME"/.config/weechat/fset.conf 2>&1 | lognoc
			ln -s "$dfloc"/config/weechat/iset.conf "$HOME"/.config/weechat/iset.conf 2>&1 | lognoc
		fi
		if type wget > /dev/null 2>&1; then
			ln -s "$dfloc"/config/wget "$HOME"/.config/wget 2>&1 | lognoc
		fi
		if type vim > /dev/null 2>&1; then
			ln -s "$dfloc"/vim "$HOME"/.vim 2>&1 | lognoc
			ln -s "$dfloc"/vim/vimrc "$HOME"/.vimrc 2>&1 | lognoc
		fi
		if type nvim > /dev/null 2>&1; then
			ln -s "$HOME"/.vim "$HOME"/.config/nvim 2>&1 | lognoc
			# ln -s "$HOME"/.vim/vimrc "$HOME"/.config/nvim/init.vim 2>&1 | lognoc
		fi
		if type vifm > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/vifm ]]; then
				mkdir "$HOME"/.config/vifm 2>&1 | lognoc
			fi
			ln -s "$dfloc"/config/vifm/colors "$HOME"/.config/vifm/colors 2>&1 | lognoc
			ln -s "$dfloc"/config/vifm/vifmrc "$HOME"/.config/vifm/vifmrc 2>&1 | lognoc
		fi
		if type msmtp > /dev/null 2>&1; then
			ln -s "$dfloc"/config/msmtp "$HOME"/.config/msmtp 2>&1 | lognoc
		fi
		if type alacritty > /dev/null 2>&1 || [[ -d /Applications/Alacritty.app ]]; then
			if [[ "$OSTYPE" == "darwin"* ]]; then
				mkdir "$HOME"/.config/alacritty && ln -s "$dfloc"/config/alacritty/alacritty-macos.yml "$HOME"/.config/alacritty/alacritty.yml 2>&1 | lognoc
			elif [[ "$OSTYPE" == "linux-gnu" ]]; then
				mkdir "$HOME"/.config/alacritty && ln -s "$dfloc"/config/alacritty/alacritty-linux.yml "$HOME"/.config/alacritty/alacritty.yml 2>&1 | lognoc
			fi
		fi
		if [[ -d /Applications/iTerm.app ]]; then
			ln -s "$dfloc"/iterm2 "$HOME"/.iterm2 > /dev/null 2>&1
		fi
		if type w3m > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.w3m ]]; then
				mkdir -pv "$HOME"/.w3m > /dev/null 2>&1 | lognoc
			fi
			ln -s "$dfloc"/w3m/config "$HOME"/.w3m/config 2>&1 | lognoc
		fi
		if type surfraw > /dev/null 2>&1 || type sr > /dev/null 2>&1; then
			if [[ ! -d "$HOME"/.config/surfraw ]]; then
				mkdir -pv "$HOME"/.config/surfraw 2>&1 | lognoc
			fi
			ln -s "$dfloc"/config/surfraw/conf "$HOME"/.config/surfraw/conf 2>&1 | lognoc
		fi
		if type newsboat > /dev/null 2>&1 || type sr > /dev/null 2>&1; then
			mkdir -pv "$HOME"/.config/newsboat > /dev/null 2>&1 | lognoc
			if type tsp > /dev/null 2>&1; then
				ln -s "$dfloc"/config/newsboat/config-tsp "$HOME"/.config/newsboat/config 2>&1 | lognoc
				ln -s "$dfloc"/config/newsboat/urls "$HOME"/.config/newsboat/urls 2>&1 | lognoc
			else
				ln -s "$dfloc"/config/newsboat/config-ts "$HOME"/.config/newsboat/config 2>&1 | lognoc
				ln -s "$dfloc"/config/newsboat/urls "$HOME"/.config/newsboat/urls 2>&1 | lognoc
			fi
		fi

		# If this is a SSH connection, install the server config of TMUX
		if type tmux > /dev/null 2>&1; then
			if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
				ln -s "$dfloc"/tmux/tmux29-server.conf "$HOME"/.tmux.conf 2>&1 | lognoc
			else
				if [[ ! -d "$HOME"/.config/tmux ]]; then
					mkdir -pv "$HOME"/.config/tmux 2>&1 | lognoc
				fi
				ln -s "$dfloc"/tmux/tmux-workstation.conf "$HOME"/.config/tmux/tmux.conf 2>&1 | lognoc
			fi
		fi

		echo -e "New dotfiles installed" 2>&1 | logc
		echo -e 2>&1 | logc
		break
	elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
		echo -e
		break
	fi
done

#==============
# Custom scripts
#==============
if [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] && [[ ! -d "$scriptsloc" ]]; then
	while read -p "Do you want to install custom scripts? (Y/n) " -n 1 -r; do
		echo -e 2>&1 | logc
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then
			echo -e "Installing custom scripts..." 2>&1 | logc
			mkdir "$scriptsloc"
			git clone --recurse-submodules "$scriptsrepo" "$scriptsloc" 2>&1 | lognoc
			git -C "$scriptsloc" submodule foreach --recursive git checkout master 2>&1 | lognoc
			echo -e "Custom scripts installed" 2>&1 | logc
			echo -e 2>&1 | logc
			break
		elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
			echo -e
			break
		fi
	done
elif [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] && [[ -d "$scriptsloc" ]]; then
	while read -p "Custom scripts are already installed. Do you want to update custom scripts? (Y/n) " -n 1 -r; do
		echo -e 2>&1 | logc
		if [[ "$REPLY" =~ ^[Yy]$ ]]; then
			echo -e "Updating custom scripts..." 2>&1 | logc
			git -C "$scriptsloc" pull 2>&1 | lognoc
			echo -e "Custom scripts updated" 2>&1 | logc
			echo -e 2>&1 | logc
			break
		elif [[ "$REPLY" =~ ^[Nn]$ ]]; then
			echo -e
			break
		fi
	done
fi

#==============
# Git Repositories
#==============
if [[ -z "$SSH_CLIENT" ]] || [[ -z "$SSH_TTY" ]] && [[ -d "$gitrepoloc" ]]; then
	echo -e "Symlinking binaries from Git repositories..." 2>&1 | logc
	if [[ ! -d "$gitrepoloc/bin" ]]; then mkdir "$gitrepoloc/bin"; fi
	find "$gitrepoloc" -maxdepth 3 -perm -111 -type f -exec ln -s '{}' "$gitrepoloc/bin" ';' 2>&1 | lognoc
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
echo -e "If anything has been modified, please reboot the computer for all the settings to be applied (not applicable to servers)." 2>&1 | logc
echo -e "A log file called \"$logfile\" contains the details of all operations. Check if for errors." 2>&1 | logc