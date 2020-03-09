#!/bin/sh
#
# Description: this script automates the installation of my personal computer
# Compatibility: it works for both macOS and Linux

#=============
# Install Homebrew if macOS
#=============
if [[ $OSTYPE == "darwin"* ]] && !command -v brew > /dev/null 2>&1; then
	echo "Installing Homebrew..."
	sudo chown -R $(whoami):admin /usr/local
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" > /dev/null 2>&1
	brew doctor > /dev/null 2>&1
	brew update > /dev/null 2>&1
fi

#=============
# Install packages
#=============
echo "Installing software..."
if [[ $OSTYPE == "darwin"* ]]; then
	brew update
	< macos_common_apps.txt xargs brew install
	< macos_common_casks.txt xargs brew cask install
	read -p "Do you want to install work applications?" -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		< macos_work_apps.txt xargs brew install
		< macos_work_casks.txt xargs brew cask install
	fi
elif [[ $OSTYPE == "linux-gnu" ]] && command -v apt > /dev/null 2>&1; then
	sudo apt update
	< debian_common_apps.txt xargs sudo apt install -y > /dev/null 2>&1
	read -p "Do you want to install work applications?" -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		< debian_work_apps.txt xargs brew install
	fi
elif [[ $OSTYPE == "linux-gnu" ]] && command -v apt-get > /dev/null 2>&1; then
	sudo apt-get update
	< debian_common_apps.txt xargs sudo apt-get install -y > /dev/null 2>&1
	read -p "Do you want to install work applications?" -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		< debian_work_apps.txt xargs brew install
	fi
elif [[ $OSTYPE == "linux-gnu" ]] && command -v yum > /dev/null 2>&1; then
	sudo yum update
	< redhat_common_apps.txt xargs sudo yum install -y > /dev/null 2>&1
	read -p "Do you want to install work applications?" -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		< redhat_work_apps.txt xargs brew install
	fi
elif [[ $OSTYPE == "linux-gnu" ]] && command -v pacman > /dev/null 2>&1; then
	sudo pacman -Syyu
	< linux_common_apps.txt xargs sudo pacman -S --noconfirm install > /dev/null 2>&1
	read -p "Do you want to install work applications?" -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		< linux_work_apps.txt xargs brew install
	fi
fi

#============
# Install Powerline font
#============
if [[ $OSTYPE == "darwin"* ]] && [[ -f "~/Library/Fonts/Source Code Pro Medium for Powerline.otf" ]]; then
	cd ~/Library/Fonts
	wget https://github.com/powerline/fonts/blob/master/SourceCodePro/Source%20Code%20Pro%20Medium%20for%20Powerline.otf
fi

#============
# macOS - Set some defaults
#============

if [[ $OSTYPE == "darwin"* ]]; then
	# Close any open System Preferences panes, to prevent them from overriding
	# settings we’re about to change
	osascript -e 'tell application "System Preferences" to quit'

	# Ask for the administrator password upfront
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
	git clone --recurse-submodules -j8 https://github.com/gsquad934/dotfiles.git ~/projects/dotfiles > /dev/null 2>&1
	git -C ~/projects/dotfiles submodule foreach --recursive git checkout master > /dev/null 2>&1
fi

#==============
# Remove and backup all original dotfiles
#==============
if [[ ! -d ~/.old-dotfiles ]]; then
	echo "Backup your current dotfiles to ~/.old-dotfiles ..."
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

#==============
# And we are done
#==============
echo -e "\n====== All Done! ======\n"
echo
echo "You may now logout and login again for all the modifications to be applied. Enjoy!"
