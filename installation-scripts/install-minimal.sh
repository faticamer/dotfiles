#!/bin/bash

#  __      __  _________.____
# /  \    /  \/   _____/|    |
# \   \/\/   /\_____  \ |    |
#  \        / /        \|    |___
#   \__/\  / /_______  /|_______ \
#        \/          \/         \/

core_packages=("gcc" "make" "curl" "git" "tree" "xclip" "bat" "ranger" "libevent-dev"
  "libncurses-dev" "build-essential" "bison" "pkg-config")

ensure_is_installed() {
  type "$1" >/dev/null 2>&1 || {
    echo "####### Installing missing package: $1 #######"
    yes | sudo apt-get install "$1"
  }
}

ensure_core_packages_are_installed() {
  for ((i = 0; i < ${#core_packages[@]}; i++)); do
    ensure_is_installed "${core_packages[i]}"
  done
}

typecheck() {
  type "$1" >/dev/null 2>&1 || {
    echo "####### Binary not found: $1 #######"
    echo -e "Failed to execute:\n$1\n" >>/tmp/install-minimal-logs.txt
  }
}

add_alias() {
  # Note: if bat is installed thru apt, setting an alias
  # is not enough for fzf to find the binary, so the original package name
  # needs to be specified --batcat
  echo -e "\nalias anvim='nvim \$(fzf -m --preview=\"batcat --color=always --style=numbers --line-range=:500 {}\")'" \
    >>~/.bashrc

  echo -e '\nalias bat="batcat"' \
    >>~/.bashrc

  source ~/.bashrc
}

# -- Fetch repository package updates
sudo apt update && yes | sudo apt upgrade
# --

# -- Verify that core packages are present in the distro
ensure_core_packages_are_installed
# --

# -- Grab tmux 3.5a tarball, unpack, and install
echo "####### Setting up TMUX ... #######"
curl -L https://github.com/tmux/tmux/releases/download/3.5a/tmux-3.5a.tar.gz >~/tmux.tar.gz
sudo tar -C $HOME -xzf ~/tmux.tar.gz
cd ~/tmux-3.5a && sudo ./configure && sudo make
sudo make install
typecheck tmux
cd || exit
# --

# -- Grab the latest NeoVim AppImage...
echo "####### Setting up NeoVim ... #######"
curl -L https://github.com/neovim/neovim/releases/download/v0.11.3/nvim-linux-x86_64.appimage >~/Downloads/nvim-linux-x86_64.appimage
cd ~/Downloads || exit
sudo cp nvim-linux-x86_64.appimage /usr/bin/nvim
sudo chmod 775 /usr/bin/nvim
rm nvim-linux-x86_64.appimage
cd || exit
typecheck nvim
# --

# -- Go Installation
echo "####### Installing Go... #######"
cd || exit
curl -LOk https://go.dev/dl/go1.25.0.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.25.0.linux-amd64.tar.gz
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >>~/.profile
source ~/.profile
typecheck go
# --

# Grab fd-find
echo "####### Installing fdfind #######"
yes | sudo apt-get install fd-find &&
  typecheck fdfind

# Grab fzf
echo "####### Installing fzf #######"
yes | sudo apt-get install fzf &&
  typecheck fzf

# Grab python3
echo "####### Installing Python #######"
yes | sudo apt-get install python3 &&
  typecheck python3

# Grab ripgrep
echo "####### Installing Ripgrep #######"
sudo apt-get install ripgrep &&
  typecheck rg

# Grab Lazygit
echo "####### Installing Lazygit #######"
go install github.com/jesseduffield/lazygit@latest &&
  typecheck lazygit

# Grab luarocks
echo "####### Installing Luarocks #######"
yes | sudo apt-get install luarocks

# -- Setup Git credentials
# git config --global user.name $user
# git config --global user.email $email
# --

# Add some aliases
add_alias

# Fetch TPM
echo " ####### Setting up TPM #######"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# --
