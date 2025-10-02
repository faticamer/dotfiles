#!/bin/bash

#  __      __  _________.____
# /  \    /  \/   _____/|    |
# \   \/\/   /\_____  \ |    |
#  \        / /        \|    |___
#   \__/\  / /_______  /|_______ \
#        \/          \/         \/

core_packages=("gcc" "make" "curl" "git" "tree" "xclip" "bat" "ranger" "libevent-dev"
  "libncurses-dev" "build-essential" "bison" "pkg-config" "dconf-cli" "uuid-runtime")

typecheck_packages=("tmux" "nvim" "fdfind" "fzf" "rg" "lazygit")
error_counter=0

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
    echo "####### Binary not found: $1. #######"
    echo -e "Failed to execute:\n$1\n" >>/tmp/install-minimal-logs
    error_counter=$((error_counter + 1))
  }
}

perform_typechecks() {
  for ((i = 0; i < ${#typecheck_packages[@]}; i++)); do
    typecheck "${typecheck_packages[i]}"
  done
}

source_profile() {
  source ~/.profile
}

source_bashrc() {
  source ~/.bashrc
}

add_alias() {
  # Note: if bat is installed thru apt, setting an alias
  # is not enough for fzf to find the binary, so the original package name
  # needs to be specified --batcat
  {
    echo -e "\nalias anvim='nvim \$(fzf -m --preview=\"batcat --color=always --style=numbers --line-range=:500 {}\")'"
    echo -e "\nalias xnvim='rg var | fzf | cut -d':' -f 1 | xargs -n 1 nvim'"
    echo -e '\nalias bat="batcat"'
    echo -e "\neval '$(zoxide init --cmd cd bash)'"
  } >>~/.bashrc

}

# -- Fetch repository package updates
sudo apt update && yes | sudo apt upgrade
# --

# -- Verify that core packages are present in the distro
ensure_core_packages_are_installed
# --

# -- Don't proceed if cURL binary is missing
if ! command -v curl >/dev/null 2>&1; then
  echo "####### Failed!!! cURL has not been installed. Aborting. #######"
  exit 1
fi

# -- Grab tmux 3.5a tarball, unpack, and install
echo "####### Setting up TMUX ... #######"
curl -L https://github.com/tmux/tmux/releases/download/3.5a/tmux-3.5a.tar.gz >~/tmux.tar.gz
sudo tar -C "$HOME" -xzf ~/tmux.tar.gz
cd ~/tmux-3.5a && sudo ./configure && sudo make
sudo make install
cd || exit
# --

# -- Grab the latest NeoVim AppImage...
echo "####### Setting up NeoVim ... #######"
curl -L https://github.com/neovim/neovim/releases/download/v0.11.3/nvim-linux-x86_64.appimage >~/nvim-linux-x86_64.appimage
sudo cp nvim-linux-x86_64.appimage /usr/bin/nvim
sudo chmod 775 /usr/bin/nvim
rm nvim-linux-x86_64.appimage
cd || exit
# --

# -- Go Installation
echo "####### Installing Go... #######"
cd || exit
curl -LOk https://go.dev/dl/go1.25.0.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.25.0.linux-amd64.tar.gz
source ~/.profile
# --

# Install fd-find
echo "####### Installing fdfind #######"
yes | sudo apt-get install fd-find

# Install fzf
echo "####### Installing fzf #######"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
mkdir -p ~/.cargo/bin # .fzf might not create it

# Install Python3
echo "####### Installing Python #######"
yes | sudo apt-get install python3

# Install ripgrep
echo "####### Installing Ripgrep #######"
sudo apt-get install ripgrep

# Install Lazygit
echo "####### Installing Lazygit #######"
go install github.com/jesseduffield/lazygit@latest

# Install luarocks
echo "####### Installing Luarocks #######"
yes | sudo apt-get install luarocks

# Install zoxide
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# Install Starship manually...
# curl -sS https://starship.rs/install.sh | sh
# Add eval to the .bashrc manually
# echo -e '\neval "$(starship init bash)"' \
# >>~/.bashrc

# -- Setup Git credentials
# git config --global user.name $user
# git config --global user.email $email
# --

# Update path
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin/:$HOME/.local/bin/:$HOME/.cargo/bin/" >>~/.profile

source_profile

# Typecheck all binaries
perform_typechecks

# Check errors - if for some reason .profile is ignored, update .bashrc instead
if [ $error_counter -gt 1 ]; then
  echo "export PATH=$PATH:/usr/local/go/bin:/$HOME/go/bin/:$HOME/.local/bin/:$HOME/.cargo/bin/" >>~/.bashrc
  source_bashrc
fi

# Add some aliases
add_alias

# Fetch TPM
echo " ####### Setting up TPM #######"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# --

echo -e "\n####### Installation complete!!! #######"
echo -e "\n####### NOTE: Install Starship manually. #######"
