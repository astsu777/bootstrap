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
		curl -fsSL https://raw.githubusercontent.com/GSquad934/bootstrap/master/arch_common_apps.txt --output ~/arch_common_apps.txt > /dev/null 2>&1
		< ~/arch_common_apps.txt xargs sudo pacman -S --noconfirm install > /dev/null 2>&1
		rm ~/arch_common*.txt
		echo "Common software installed"
	fi
	read -p "Do you want to install work applications? (Y/n) " -n 1 -r
	echo
	if [[ "$REPLY" =~ ^[Yy]$ ]]; then
		echo "Installing work software..."
		curl -fsSL https://raw.githubusercontent.com/GSquad934/bootstrap/master/arch_work_apps.txt --output ~/arch_work_apps.txt > /dev/null 2>&1
		< ~/arch_work_apps.txt xargs brew install > /dev/null 2>&1
		rm ~/arch_work*.txt
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
		wget -c --content-disposition https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Mononoki/Regular/complete/mononoki-Regular%20Nerd%20Font%20Complete.ttf > /dev/null 2>&1
		mv "$HOME"/fonts/*.ttf "$HOME"/Library/Fonts/ > /dev/null 2>&1
		rm -Rf "$HOME"/fonts > /dev/null 2>&1
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
#             NOTES: For this to work you must have cloned the Github
#                 repo to your home folder as ~/projects/dotfiles
#
#===============================================================================

#==============
# Clone the GitHub repository with all wanted dotfiles
#==============
if [[ ! -d ~/projects/dotfiles ]]; then
	echo "Retrieving dotfiles..."
	git clone --recurse-submodules https://github.com/gsquad934/dotfiles.git ~/projects/dotfiles > /dev/null 2>&1
	git -C ~/projects/dotfiles submodule foreach --recursive git checkout master > /dev/null 2>&1
else
	git -C ~/projects/dotfiles pull > /dev/null 2>&1
fi

if [[ ! -d ~/projects/scripts ]]; then
	echo "Installing custom scripts..."
	git clone --recurse-submodules https://github.com/gsquad934/scripts.git ~/projects/scripts > /dev/null 2>&1
	git -C ~/projects/scripts submodule foreach --recursive git checkout master > /dev/null 2>&1
fi

#==============
# Remove and backup all original dotfiles
#==============
echo "Backup your current dotfiles to ~/.old-dotfiles..."
if [[ ! -d "$HOME"/.old-dotfiles ]]; then
	mkdir ~/.old-dotfiles > /dev/null 2>&1
else
	rm -Rf ~/.old-dotfiles > /dev/null 2>&1
	mkdir ~/.old-dotfiles > /dev/null 2>&1
fi
mv ~/.bash_profile ~/.old-dotfiles/bash_profile > /dev/null 2>&1
mv ~/.bashrc ~/.old-dotfiles/bashrc > /dev/null 2>&1
mv ~/.gitconfig ~/.old-dotfiles/gitconfig > /dev/null 2>&1
mv ~/.iterm2 ~/.old-dotfiles/iterm2 > /dev/null 2>&1
mv ~/.msmtprc ~/.old-dotfiles/msmtprc > /dev/null 2>&1 || mv ~/.config/msmtp ~/.old-dotfiles/msmtp > /dev/null 2>&1
mv ~/.p10k.zsh ~/.old-dotfiles/p10k.zsh > /dev/null 2>&1
mv ~/.tmux.conf ~/.old-dotfiles/tmux.conf > /dev/null 2>&1
mv ~/.vim ~/.old-dotfiles/vim > /dev/null 2>&1
mv ~/.vimrc ~/.old-dotfiles/vimrc > /dev/null 2>&1
mv ~/.zshrc ~/.old-dotfiles/zshrc > /dev/null 2>&1
mv ~/.config/nvim/init.vim ~/.old-dotfiles/zshrc > /dev/null 2>&1
mv ~/.config/nvim ~/.old-dotfiles/nvim > /dev/null 2>&1
mv ~/.config/wget ~/.old-dotfiles/wget > /dev/null 2>&1
mv ~/.config/weechat ~/.old-dotfiles/weechat > /dev/null 2>&1

#==============
# Create symlinks in the home folder
#==============
echo "Installing new dotfiles..."
ln -s ~/projects/dotfiles/gitconfig ~/.gitconfig > /dev/null 2>&1
ln -s ~/projects/dotfiles/shellconfig/p10k.zsh ~/.p10k.zsh > /dev/null 2>&1
ln -s ~/projects/dotfiles/tmux/tmux-workstation.conf ~/.tmux.conf > /dev/null 2>&1
ln -s ~/projects/dotfiles/vim ~/.vim > /dev/null 2>&1
ln -s ~/projects/dotfiles/vim/vimrc ~/.vimrc > /dev/null 2>&1
ln -s ~/projects/dotfiles/shellconfig/bashrc ~/.bashrc > /dev/null 2>&1
ln -s ~/projects/dotfiles/shellconfig/zshrc ~/.zshrc > /dev/null 2>&1
ln -s ~/.vim ~/.config/nvim > /dev/null 2>&1
ln -s ~/.vim/vimrc ~/.config/nvim/init.vim > /dev/null 2>&1
ln -s ~/projects/dotfiles/config/wget ~/.config/wget > /dev/null 2>&1
if command -v weechat > /dev/null 2>&1; then
	mkdir ~/.config/weechat
	ln -s ~/projects/dotfiles/config/weechat/irc.conf ~/.config/weechat/irc.conf > /dev/null 2>&1
	ln -s ~/projects/dotfiles/config/weechat/perl ~/.config/weechat/perl > /dev/null 2>&1
	ln -s ~/projects/dotfiles/config/weechat/python ~/.config/weechat/python > /dev/null 2>&1
	ln -s ~/projects/dotfiles/config/weechat/trigger.conf ~/.config/weechat/trigger.conf > /dev/null 2>&1
	ln -s ~/projects/dotfiles/config/weechat/weechat.conf ~/.config/weechat/weechat.conf > /dev/null 2>&1
	ln -s ~/projects/dotfiles/config/weechat/xfer.conf ~/.config/weechat/xfer.conf > /dev/null 2>&1
	ln -s ~/projects/dotfiles/config/weechat/buflist.conf ~/.config/weechat/buflist.conf > /dev/null 2>&1
	ln -s ~/projects/dotfiles/config/weechat/colorize_nicks.conf ~/.config/weechat/colorize_nicks.conf > /dev/null 2>&1
	ln -s ~/projects/dotfiles/config/weechat/fset.conf ~/.config/weechat/fset.conf > /dev/null 2>&1
	ln -s ~/projects/dotfiles/config/weechat/iset.conf ~/.config/weechat/iset.conf > /dev/null 2>&1
fi
if command -v msmtp > /dev/null 2>&1; then
	ln -s ~/projects/dotfiles/config/msmtp ~/.config/msmtp > /dev/null 2>&1
fi
if [[ "$OSTYPE" == "darwin"* ]] && [[ -d /Applications/iTerm.app ]]; then
	ln -s ~/projects/dotfiles/iterm2 ~/.iterm2 > /dev/null 2>&1
fi

#==============
# Amethyst Configuration
#==============
if [[ "$OSTYPE" == "darwin"* ]] && [[ -d /Applications/Amethyst.app ]]; then
	# Set windows to always stay in floating mode
	defaults write com.amethyst.Amethyst.plist floating '(
	        {
        id = "com.apple.systempreferences";
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
	defaults write com.amethyst.Amethyst.plist window-margin-size 6
	# Do not display layout names
	defaults write com.amethyst.Amethyst.plist enables-layout-hud 0
	defaults write com.amethyst.Amethyst.plist enables-layout-hud-on-space-change 0
	# Disable automatic update check as it is done by Homebrew
	defaults write com.amethyst.Amethyst.plist SUEnableAutomaticChecks 0
	# Delete the plist cache
	defaults read com.amethyst.Amethyst.plist > /dev/null 2>&1
fi
echo "New dotfiles installed"

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
