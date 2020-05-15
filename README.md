# Bootstrap
This is a script that can be used to automate the setup of a workstation or a personal computer.

:warning: **This script should not be used to setup a server!** Please use a proper automation framework such as Ansible to do so.
However, I use it to install my dotfiles and optionally (choice is provided) install certain useful tools. If the script is ran via a SSH connection, it will consider the remote machine as a server and will not propose to install workstation applications.

# Compatibility
This works on macOS and various flavors of Linux (mainly Debian based, Red Hat based and Arch based).
It also been successfully tested on WSL (Windows Subsystem for Linux) with Ubuntu/Debian image.

# Usage
In order to execute this script, download this repository and execute the .bootstrap.sh script.
Execute the following commands for easy setup:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/GSquad934/bootstrap/master/bootstrap.sh)"
```

It is possible to chose where the dotfiles will be located by changing the *$dfloc* variable at the top of the script.

The script will not install any software without asking first. All software can be refused in order to only install the dotfiles.
For a list of software, see the text files in this repository.

__Note__ If the dotfiles are installed, it is possible to invoke this bootstrap script with the command *bootstrap*.

# Logs
The output to the console is pretty empty in order to keep everything clean. However, a log file is always created in the $HOME folder and is unique for each run. This way, it is possible to review errors if required.

# TODO

- Merge all application lists into a single one with tags
- Include tools that need compiling (and keep the sources or not)
