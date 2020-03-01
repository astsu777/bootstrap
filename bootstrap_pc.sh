#!/bin/bash
#
# Description: this script automates the installation of my personal computers
# Compatibility: it works for both macOS and Linux

#=============
# Install Homebrew if macOS
#=============
if [[ $OSTYPE == "darwin"* ]]; then
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
	< pc_apps.txt xargs brew install > /dev/null 2>&1
## BUG: PACKAGES ARE NOT NECESSARILY AVAILABLE ON LINUX SYSTEMS
#elif [[ $(which apt | grep apt) == *"apt" ]] || [[ $(which apt-get | grep apt-get) == *"apt-get" ]]; then
#	sudo apt update
#	< pc_apps.txt xargs sudo apt install -y > /dev/null 2>&1
#elif [[ $(which yum | grep yum) == *"yum" ]]; then
#	sudo yum update
#	< pc_apps.txt xargs sudo yum install -y > /dev/null 2>&1
#elif [[ $(which pacman | grep pacman) == *"pacman" ]]; then
#	sudo pacman -Syyu
#	< pc_apps.txt xargs sudo pacman -S --noconfirm install > /dev/null 2>&1
fi

#=============
# Brew Cask packages if macOS
#=============
if [[ $OSTYPE == "darwin"* ]]; then
	echo "Installing graphical software..."
	brew cask install balenaetcher > /dev/null 2>&1
	brew cask install dosbox > /dev/null 2>&1
	brew cask install keepassxc > /dev/null 2>&1
	brew cask install plex-media-player > /dev/null 2>&1
	brew cask install rambox > /dev/null 2>&1
	brew cask install vlc > /dev/null 2>&1
fi

#============
# Install Powerline font
#============
if [[ $OSTYPE == "darwin"* ]]; then
	cd ~/Library/Fonts
	wget https://github.com/powerline/fonts/blob/master/SourceCodePro/Source%20Code%20Pro%20Medium%20for%20Powerline.otf
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
echo "Retrieving dotfiles..."
git clone --recurse-submodules -j8 https://github.com/gsquad934/dotfiles.git ~/projects/dotfiles > /dev/null 2>&1
git -C ~/projects/dotfiles submodule foreach --recursive git checkout master > /dev/null 2>&1

#==============
# Remove and backup all original dotfiles
#==============
echo "Backup your current dotfiles..."
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
ln -sf ~/projects/dotfiles/shellconfig/zshrc ~/.zshrc

#==============
# And we are done
#==============
echo -e "\n====== All Done! ======\n"
echo
echo "You may now restart your shell to finish the installation. Enjoy!"
