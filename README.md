# Bootstrap
This is a script that can be used to automate the setup of a workstation or a personal computer.

:warning: **This script should not be used to setup a server!** Please use a proper automation framework such as Ansible to do so.
However, I use it to install my dotfiles and optionally (choice is provided) install certain useful tools.

# Compatibility
This works on macOS and various flavors of Linux (mainly Debian based, Red Hat based and Arch based).
It also been successfully tested on WSL (Windows Subsystem for Linux) with Ubuntu/Debian image.

# Usage
In order to execute this script, download this repository and execute the .bootstrap.sh script.
Execute the following commands for easy setup:

```
curl -sLO https://raw.githubusercontent.com/GSquad934/bootstrap/master/bootstrap.sh
bash bootstrap.sh
```

The script will not install any software without asking first. All software can be refused in order to only install the dotfiles.
For a list of software, see the text files in this repository.

# TODO
There are still quite a few enhancements to be done. Here is a list of things required:

- ~~Automate installation of apps from the AppStore on macOS~~ :warning: The application **mas** displays wrong ID for apps
- Validate the Linux software list to make sure all names are correct
- (Optional or Separate) Create a list of useful tools for servers
- (Super Optional) Create a nice menu to actually select which software will be installed
