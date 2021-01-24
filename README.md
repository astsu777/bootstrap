# Bootstrap
This is a script that can be used to automate the setup of a workstation or a personal computer.

:warning: **This script should not be used to setup a server!** Please use a proper automation framework such as Ansible to do so.
However, I use it to install my dotfiles and optionally (choice is provided) install certain useful tools. If the script is ran via a SSH connection, it will consider the remote machine as a server and will not propose to install workstation applications.

# Compatibility
This script has been fully validated with the following systems:

- [x] macOS (up until Catalina)
- [x] Manjaro Linux (last tested on 24th January 2021)
- [x] Arch Linux (last tested on 24th January 2021)
- [ ] Other Linux distributions and WSL2

It should work with other Linux distributions too as this script if built to work with distros based on Debian, Red Hat, Arch Linux and macOS. The only issue you may encounter is that some packages may be missing from your package manager.
The script has been tested on WSL2 and works well enough except for the software installation (obviously).

# Usage
In order to execute this script, download this repository and execute the .bootstrap.sh script.
Execute the following commands for easy setup:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/GSquad934/bootstrap/master/bootstrap.sh)"
```

It is possible to chose where the dotfiles, scripts and several applications will be located by changing the *$dfloc*, *$scriptsloc* and the other location variables at the top of the script.

The script will not install any software without asking first. All software can be refused in order to only install the dotfiles.
For a list of software, see the text files in this repository. The list of software can be customized to your needs.

__Note__ If the dotfiles are installed, it is possible to invoke this bootstrap script with the command *bootstrap*. If you just want to download the dotfiles but not have the GIT repository hosted on your computer, simply download a ZIP copy or fork this repo.

# Log
The output to the console is pretty empty in order to keep everything clean. However, a log file is always created in the $HOME folder and is unique for each run. This way, it is possible to review errors if required.
