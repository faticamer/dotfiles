# Overview

Give necessary permissions to the script you want to run:

```bash
sudo chmod +x {script_name.sh}
```

> [!NOTE]
> Curly braces are excluded in the command above.

## gogh.sh
Borrowed from [Gogh](https://github.com/Gogh-Co/Gogh). Quickly install a color scheme for your terminal emulator.

## install.sh
Installation & setup of all tools I use for my development environment. Each tool is installed either via Ubuntu/Debian package manager - apt, or by following the instructions from tool's respective repos on GitHub. This script is used for freshly installed Debian-based systems (with apt package manager).

## install-minimal.sh
Same script as install.sh, excluding Alacritty terminal emulator. Run this script if you want to quickly install all the tools inside the WSL.

## install-plugs-ranger.sh
Install some plugins for the Ranger, a terminal-based file manager tool.
