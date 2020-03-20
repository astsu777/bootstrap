#!/bin/bash
#
# Description: this script automates the installation of my personal computer
# Compatibility: it works for both macOS and Linux

#=============
# Install Homebrew if macOS
#=============
if [[ "$OSTYPE" == "darwin"* ]] && ! command -v brew > /dev/null 2>&1; then
	echo "Installing Homebrew..."
	sudo chown -R "$(whoami)":admin /usr/local
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" > /dev/null 2>&1
	brew doctor > /dev/null 2>&1
	brew update > /dev/null 2>&1
fi

#=============
# Install packages
#=============
if [[ "$OSTYPE" == "darwin"* ]]; then
	read -p "Do you want to install common applications? (Y/n) " -n 1 -r
	echo
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		echo "Installing common software..."
		brew update > /dev/null 2>&1
		curl -fsSL https://raw.githubusercontent.com/GSquad934/bootstrap/master/macos_common_apps.txt --output ~/macos_common_apps.txt > /dev/null 2>&1
		curl -fsSL https://raw.githubusercontent.com/GSquad934/bootstrap/master/macos_common_casks.txt --output ~/macos_common_casks.txt > /dev/null 2>&1
		< ~/macos_common_apps.txt xargs brew install > /dev/null 2>&1
		< ~/macos_common_casks.txt xargs brew cask install > /dev/null 2>&1
		rm ~/macos_common*.txt
		echo "Common software installed"
	fi
	read -p "Do you want to install work applications? (Y/n) " -n 1 -r
	echo
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		echo "Installing work software..."
		curl -fsSL https://raw.githubusercontent.com/GSquad934/bootstrap/master/macos_work_apps.txt --output ~/macos_work_apps.txt > /dev/null 2>&1
		curl -fsSL https://raw.githubusercontent.com/GSquad934/bootstrap/master/macos_work_casks.txt --output ~/macos_work_casks.txt > /dev/null 2>&1
		< macos_work_apps.txt xargs brew install > /dev/null 2>&1
		< macos_work_casks.txt xargs brew cask install > /dev/null 2>&1
		rm ~/macos_work*.txt
		echo "Work software installed"
	fi
elif [[ "$OSTYPE" == "linux-gnu" ]] && command -v apt > /dev/null 2>&1; then
	read -p "Do you want to install common applications? (Y/n) " -n 1 -r
	echo
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		echo "Installing common software..."
		sudo apt update > /dev/null 2>&1
		curl -fsSL https://raw.githubusercontent.com/GSquad934/bootstrap/master/debian_common_apps.txt --output ~/debian_common_apps.txt > /dev/null 2>&1
		< ~/debian_common_apps.txt xargs sudo apt install -y > /dev/null 2>&1
		rm ~/debian_common*.txt
		echo "Common software installed"
	fi
	read -p "Do you want to install work applications? (Y/n) " -n 1 -r
	echo
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		echo "Installing work software..."
		curl -fsSL https://raw.githubusercontent.com/GSquad934/bootstrap/master/debian_work_apps.txt --output ~/debian_work_apps.txt > /dev/null 2>&1
		< debian_work_apps.txt xargs brew install > /dev/null 2>&1
		rm ~/debian_work*.txt
		echo "Work software installed"
	fi
elif [[ "$OSTYPE" == "linux-gnu" ]] && command -v apt-get > /dev/null 2>&1; then
	read -p "Do you want to install common applications? (Y/n) " -n 1 -r
	echo
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		echo "Installing common software..."
		sudo apt-get update
		curl -fsSL https://raw.githubusercontent.com/GSquad934/bootstrap/master/debian_common_apps.txt --output ~/debian_common_apps.txt > /dev/null 2>&1
		< ~/debian_common_apps.txt xargs sudo apt-get install -y > /dev/null 2>&1
		rm ~/debian_common*.txt
		echo "Common software installed"
	fi
	read -p "Do you want to install work applications? (Y/n) " -n 1 -r
	echo
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		echo "Installing work software..."
		curl -fsSL https://raw.githubusercontent.com/GSquad934/bootstrap/master/debian_work_apps.txt --output ~/debian_work_apps.txt > /dev/null 2>&1
		< ~/debian_work_apps.txt xargs brew install > /dev/null 2>&1
		rm ~/debian_work*.txt
		echo "Work software installed"
	fi
elif [[ "$OSTYPE" == "linux-gnu" ]] && command -v yum > /dev/null 2>&1; then
	read -p "Do you want to install common applications? (Y/n) " -n 1 -r
	echo
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		echo "Installing common software..."
		sudo yum update
		curl -fsSL https://raw.githubusercontent.com/GSquad934/bootstrap/master/redhat_common_apps.txt --output ~/redhat_common_apps.txt > /dev/null 2>&1
		< ~/redhat_common_apps.txt xargs sudo yum install -y > /dev/null 2>&1
		rm ~/redhat_common*.txt
		echo "Common software installed"
	fi
	read -p "Do you want to install work applications? (Y/n) " -n 1 -r
	echo
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		echo "Installing work software..."
		curl -fsSL https://raw.githubusercontent.com/GSquad934/bootstrap/master/redhat_work_apps.txt --output ~/redhat_work_apps.txt > /dev/null 2>&1
		< ~/redhat_work_apps.txt xargs brew install > /dev/null 2>&1
		rm ~/redhat_work*.txt
		echo "Work software installed"
	fi
elif [[ "$OSTYPE" == "linux-gnu" ]] && command -v pacman > /dev/null 2>&1; then
	read -p "Do you want to install common applications? (Y/n) " -n 1 -r
	echo
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		echo "Installing common software..."
		sudo pacman -Syyu
		curl -fsSL https://raw.githubusercontent.com/GSquad934/bootstrap/master/linux_common_apps.txt --output ~/linux_common_apps.txt > /dev/null 2>&1
		< ~/linux_common_apps.txt xargs sudo pacman -S --noconfirm install > /dev/null 2>&1
		rm ~/linux_common*.txt
		echo "Common software installed"
	fi
	read -p "Do you want to install work applications? (Y/n) " -n 1 -r
	echo
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		echo "Installing work software..."
		curl -fsSL https://raw.githubusercontent.com/GSquad934/bootstrap/master/linux_work_apps.txt --output ~/linux_work_apps.txt > /dev/null 2>&1
		< ~/linux_work_apps.txt xargs brew install > /dev/null 2>&1
		rm ~/linux_work*.txt
		echo "Work software installed"
	fi
fi

#============
# Install font
#============
if [[ "$OSTYPE" == "darwin"* ]]; then
	read -p "Do you want to install Powerline fonts? (Y/n) " -n 1 -r
	echo
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		echo "Installing Powerline fonts..."
		git clone https://github.com/powerline/fonts "$HOME"/fonts > /dev/null 2>&1 && "$HOME"/fonts/install.sh
		rm -Rf "$HOME"/fonts
	fi
	read -p "Do you want to install Nerd fonts? (Y/n) " -n 1 -r
	echo
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		echo "Installing Nerd fonts..."
		mkdir "$HOME"/fonts && cd "$HOME/fonts" || exit
		wget -c --content-disposition https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Mononoki/Regular/complete/mononoki-Regular%20Nerd%20Font%20Complete.ttf
		mv "$HOME"/fonts/*.ttf "$HOME"/Library/Fonts/
		rm -Rf "$HOME"/fonts
	fi
fi

#============
# Install Tmux Plugin Manager
#============
if [[ "$OSTYPE" == "darwin"* ]]; then
	read -p "Do you want to handle TMUX plugins? (Y/n) " -n 1 -r
	echo
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		echo "Installing TMUX Plugin Manager..."
		git clone https://github.com/tmux-plugins/tpm "$HOME"/.tmux/plugins/tpm > /dev/null 2>&1
		echo "In TMUX, press <PREFIX> + I to install plugins"
	fi
fi

#============
# macOS - Set some defaults
#============

if [[ "$OSTYPE" == "darwin"* ]]; then
	# Close any open System Preferences panes, to prevent them from overriding
	# settings we’re about to change
	osascript -e 'tell application "System Preferences" to quit'

	# Ask for the administrator password upfront
	echo "Setting up system preferences..."
	sudo -v

	# Keep-alive: update existing `sudo` time stamp until bootstrap has finished
	while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

	# Disable automatic spelling correction
	defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

	# Disable automatic capitalization
	defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

	# Adjust smart quotes
	defaults write NSGlobalDomain NSUserQuotesArray -array '"\""' '"\""' '"'\''"' '"'\''"'

	# Enable Dark mode
	defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

	# Set a blazingly fast keyboard repeat rate
	defaults write NSGlobalDomain KeyRepeat -int 1
	defaults write NSGlobalDomain InitialKeyRepeat -int 10

	echo "System preferences configured"
fi

#===============================================================================
#
#             NOTES: For this to work you must have cloned the github
#                    repo to your home folder as ~/dotfiles/
#
#===============================================================================

#==============
# Clone the GitHub repository with all wanted dotfiles
#==============
if [[ ! -d ~/projects/dotfiles ]]; then
	echo "Retrieving dotfiles..."
	git clone --recurse-submodules https://github.com/gsquad934/dotfiles.git ~/projects/dotfiles > /dev/null 2>&1
	git -C ~/projects/dotfiles submodule foreach --recursive git checkout master > /dev/null 2>&1

elif [[ ! -d ~/projects/scripts ]]; then
	echo "Installing custom scripts..."
	git clone --recurse-submodules https://github.com/gsquad934/dotfiles.git ~/projects/scripts > /dev/null 2>&1
	git -C ~/projects/scripts submodule foreach --recursive git checkout master > /dev/null 2>&1

#==============
# Remove and backup all original dotfiles
#==============
	if [[ ! -d ~/.old-dotfiles ]]; then
		echo "Backup your current dotfiles to ~/.old-dotfiles..."
		mkdir ~/.old-dotfiles > /dev/null 2>&1
		mv ~/.bash_profile ~/.old-dotfiles/bash_profile > /dev/null 2>&1
		mv ~/.bashrc ~/.old-dotfiles/bashrc > /dev/null 2>&1
		mv ~/.gitconfig ~/.old-dotfiles/gitconfig > /dev/null 2>&1
		mv ~/.iterm2 ~/.old-dotfiles/iterm2 > /dev/null 2>&1
		mv ~/.msmtprc ~/.old-dotfiles/msmtprc > /dev/null 2>&1
		mv ~/.tmux.conf ~/.old-dotfiles/tmux.conf > /dev/null 2>&1
		mv ~/.vim ~/.old-dotfiles/vim > /dev/null 2>&1
		mv ~/.vimrc ~/.old-dotfiles/vimrc > /dev/null 2>&1
		mv ~/.zshrc ~/.old-dotfiles/zshrc > /dev/null 2>&1
	fi

#==============
# Create symlinks in the home folder
# Allow overriding with files of matching names in the custom-configs dir
#==============
	echo "Installing new dotfiles..."
	ln -sf ~/projects/dotfiles/gitconfig ~/.gitconfig
	ln -sf ~/projects/dotfiles/iterm2 ~/.iterm2
	ln -sf ~/projects/dotfiles/msmtprc ~/.msmtprc
	ln -sf ~/projects/dotfiles/shellconfig/p10k.zsh ~/.p10k.zsh
	ln -sf ~/projects/dotfiles/tmux/tmux-workstation.conf ~/.tmux.conf
	ln -sf ~/projects/dotfiles/vim ~/.vim
	ln -sf ~/projects/dotfiles/vim/vimrc ~/.vimrc
	ln -sf ~/projects/dotfiles/shellconfig/bashrc ~/.bashrc
	ln -sf ~/projects/dotfiles/shellconfig/zshrc ~/.zshrc
	ln -sf ~/.vim ~/.config/nvim
	ln -sf ~/.vim/vimrc ~/.config/nvim/init.vim
	if [[ "$OSTYPE" == "darwin"* ]]; then
		rm ~/Library/Preferences/com.amethyst.Amethyst.plist > /dev/null 2>&1
		ln -sf ~/projects/dotfiles/config/com.amethyst.Amethyst.plist ~/Library/Preferences/com.amethyst.Amethyst.plist
	fi
	echo "New dotfiles installed"
fi

#==============
# DONE
#==============
echo
echo
echo "########################"
echo "#====== ALL DONE ======#"
echo "########################"
echo
echo "You may now logout and login again for all the modifications to be applied."
