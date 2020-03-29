# Bootstrap
This is a script that can be used to automate the setup of a workstation or a personal computer.

:warning: **This script should not be used to setup a server!** Please use a proper automation framework such as Ansible to do so.

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

# TODO
There are still quite a few enhancements to be done. Here is a list of things required:

- Fully automate the system preferences on macOS (some still require the GUI)
- Automate installation of apps from the AppStore on macOS
