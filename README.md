# Bootstrap

![](https://i.postimg.cc/vZkGP5k2/screenshot-20210324-001.png)

This repository hosts a *BASH* bootstrap script that can be used to setup workstations and personal computers running on either Linux or macOS. The script has the following abilities:

* Modular usage: only desired operations can be performed (Ex.: only deploy dotfiles without installing any software)
* Setup 3rd party repositories to install software not available in the system default ones
* Automatically install TUI & GUI software
* Install professional software for a workstation
* Deploy 3rd party fonts commonly used such as *JetBrainsMono*, etc...
* Configure the prompt automatically (*BASH* & *ZSH* supported). The script will ask to set ZSH as the default shell too
* Install *TMUX* and necessary plugins
* Configure the system to personal preferences
* Detect the computer's video card and install the proper driver (open-source only)
* Detect a laptop and propose to install power management
* Detect a server connection (=SSH) and adjust the authorized operations
* Clean output to the console, but all operations are logged to a log file
* On a bare Arch Linux installation, deploy necessary packages for a GUI & (optional) deploy a GUI environment (WM & DE)
* When installing a GUI environment, offers the choice to login via *Xinit* (text mode) or with *LightDM*
* Deploy custom theme for CLI applications, but also proposes Gruvbox as an alternative
* Deploy custom GTK/QT theme for GUI applications

⚠️ **This script should not be used to setup a server!** Please use a proper automation framework such as [Ansible](https://www.ansible.com/) to do so.
However, I use it to install my dotfiles and optionally (choice is provided) install certain useful tools on the servers I manage.

# Requirements
*TLDR*: there is nothing to manually install to use this script.

Whenever the script is ran, it performs a series of check to automatically install the necessary requirements:

1. Detect the current operating system by reading the *$OSTYPE* environment variable
	* If Linux is detected, it will detect if you run the script as root. If it is the case, it will ask you to create a new user and provide SUDO privilege (DOAS not yet supported). It will then ask to logout and run the script again as a regular user
	* If macOS is detected, it will install Homebrew and also the XCode Command Line Tools if they are not already installed
2. Detect the package manager used by the OS: this is necessary to properly install software. The most popular package managers are supported but it does not support any snaps, flatpacks or AppImages

<u>**Note**</u>: if Arch Linux (or derivative) is detected, the script will prompt to install the *YAY* AUR helper. This is optional, but recommended to deploy applications only available in the AUR.

# Compatibility
This script has been fully validated with the following systems:

| OS | Compatibility | Comment |
|:-:|:-:|:-|
| macOS 10/11/12 (Monterey) | ✅| Fully compatible |
| Arch Linux & SystemD derivatives | ✅ | Fully compatible |
| Artix Linux & OpenRC/Runit/S6/66 derivatives | ✅ | Fully compatible |
| Debian (+ distros based on it) | ✅ | Fully compatible |
| Red Hat (+ distros based on it) | ✅ | Fully compatible |
| Void Linux | ✅ | Fully compatible |
| BSD | ❌ | Not compatible yet |
| Windows Subsystem for Linux (WSL) | ❗ | Graphical software won't install/work and dotfiles not behave as intended |

Depending on the packages availability in the repositories, some software may be missing and/or not be compatible. If your system is using *OpenRC*/*Runit*/*S6*/*Suite66*, some scripts may not be available for services. In that case, check the documentation.

The script supports the following package managers for now:

* APT (commands: **apt-get** and **apt**)
* DNF aka *Dandified YUM* & DNF (commands: **dnf**)
* Homebrew for macOS (command: **brew**)
* Pacman (command: **pacman**)
* Snap (command: **snap**)
* XBPS aka *X Binary Package System* (commands: xbps-install/query/etc...)
* YAY aka *Yet Another Yogurt* as the AUR helper (command: **yay**)
* YUM aka *Yellowdog Update Modified* & DNF (commands: **yum**)

# Usage
The configuration has two parts: the list of applications needed to be installed and some variables to define (latter is optional).

### Applications To Install
The file *apps.csv* is very simple to use. It consists of a list of applications (one per line) and some tags in front of the application name. The following tags are available:

| Tag | Comment |
|:-:|:-:|
| S | Mark the application as a *server* application. If this is the only defined tag, the program will only be installed on remote servers |
| W | Mark the application as a *work* application (all other programs are considered as common) |
| X | Mark the application as a necessary package to install a GUI environment (Arch/Artix only) |
| Y | Mark the application as a necessary package to install a GUI environment (Void Linux only) |
| M | Application matching a S6 service script |
| N | Application matching a Suite66 service script |
| O | Application matching an OpenRC service script |
| P | Application matching a Runit service script |
| 0 | The application can be cloned from a Git repository |
| 1 | The application is binary directly downloaded from the Internet |
| 2 | The application can be installed with Homebrew on macOS and is a TUI program |
| 3 | The application can be installed with Homebrew on macOS and is a GUI program |
| 5 | The application can be installed with Pacman on Arch Linux & derivatives |
| 6 | The application can be installed with APT on Debian & derivatives |
| 7 | The application can be installed with YUM/DNF on Red Hat & derivatives |
| 8 | The application can be installed with YAY (AUR) on Arch Linux & derivatives |
| 9 | The application can be installed with XBPS on Void Linux |

The file is structured in this way because some applications have different names depending on the OS. Also, some applications are not available on some systems. Personally, I also use different applications on different systems depending on my workflow.

<u>**Note**</u>: the "0" tag will trigger the script to detect binaries in the cloned repositories and symlinked them in a location defined by the *$gitrepoloc* in their defined location (see chapter **Variables** below for details).

### Variables
The file *bootstrap&#46;sh* has a lot of variables defined at the very beginning. This allows changing the configuration of the script without actually modifying the code. It is recommended to change the following variables:

* **applist**: defines the URL of the *apps.csv* file
* **dfloc**: this variable defines where the installed dotfiles need to be stored. Default value is *$HOME/.dotfiles*
* **dfrepo**: this variable indicates what repository of dotfiles needs to be installed (this points to [my dotfiles](https://github.com/GSquad934/dotfiles))
* **scriptsloc**: this variable defines where custom scripts will be stored. Personally, I use this to auto-create this folder so my dotfiles will deploy scripts there and add this folder to my *&#36;PATH*. Default value is *$HOME/.local/bin*
* **resourcesloc**: this variable defines where resources to be used by custom scripts are located (Ex.: a list of all unicode characters)
* **gitrepoloc**: this variable defines where cloned Git repositories will be stored. Default value is *$HOME/.sources/repos*
* **ddloc**: this variable defines where downloaded binaries will be stored. Default value is */usr/local/bin*
* **sourcesloc**: this variable defines where software sources will be stored. Default value is *$HOME/.sources*
* **wallpapers**: this variable indicates what repository of wallpapers can be downloaded
* **wallpapersloc**: this variable defines where downloaded wallpapers will be stored. Default value is *$HOME/.local/share/wallpapers*

Other variables define URLs for custom fonts, a plugin manager for *TMUX*, etc... They are self-explanatory and can also be customized.

### Execution
Once everything is customized to your needs, execute the following command:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/GSquad934/bootstrap/master/bootstrap.sh)"
```

If *curl* is not installed, execute the following command that uses *wget*:

```
/bin/bash -c "$(wget -O - https://raw.githubusercontent.com/GSquad934/bootstrap/master/bootstrap.sh)"
```

You can also clone this repository and execute the script locally (it will still download the *apps.csv* file using the *$applist* variable):

```
git clone --depth 1 https://github.com/GSquad934/bootstrap.git
cd bootstrap
/bin/bash ./bootstrap.sh
```

If you use my dotfiles, a [function called bootstrap](https://github.com/GSquad934/dotfiles/blob/master/shellconfig/functions#L56) will automatically call this script again.

# Laptop
When being executed, the script will try to determine if the machine is a laptop or not. If it is the case, the script will say so and propose to install *tlp*, a power saver software that can greatly increase a laptop's battery life.


# Server
![](https://i.postimg.cc/wvcHTZvn/screenshot-20210324-002.png)

If the script is ran via a SSH connection, it will consider it is running on a remote server and adapt its behavior. It will then only propose two operations:

* Install some useful server tools (tagged with "**I**" in the *apps.csv* file)
* Deploy dotfiles

[My personal dotfiles](https://github.com/GSquad934/dotfiles) are suited to run on both a workstation and server. The reason for this is the dynamism in them that does not disrupt the remote servers at all.

# Log
The output to the console is pretty empty in order to keep everything clean. However, a log file is always created in the *$HOME* folder and is unique for each run. This way, it is possible to review all performed operations and check for errors.

# Contact
You can always reach out to me:

* [Twitter](https://twitter.com/gaetanict)
* [Email](mailto:gaetan@ictpourtous.com)
