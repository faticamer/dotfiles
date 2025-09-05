#!/bin/bash

# ________        ___.   .__                     /\   ____ ______.                 __
# \______ \   ____\_ |__ |__|____    ____       / /  |    |   \_ |__  __ __  _____/  |_ __ __
#  |    |  \_/ __ \| __ \|  \__  \  /    \     / /   |    |   /| __ \|  |  \/    \   __\  |  \
#  |    `   \  ___/| \_\ \  |/ __ \|   |  \   / /    |    |  / | \_\ \  |  /   |  \  | |  |  /
# /_______  /\___  >___  /__(____  /___|  /  / /     |______/  |___  /____/|___|  /__| |____/
#         \/     \/    \/        \/     \/   \/                    \/           \/

core_packages=("gcc" "make" "curl" "git" "tree" "xclip" "bat" "ranger" "libevent-dev"
  "libncurses-dev" "build-essential" "bison" "pkg-config" "cmake" "g++" "libfontconfig1-dev"
  "libxcb-xfixes0-dev" "libxkbcommon-dev" "dconf-cli" "uuid-runtime")

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

  echo -e "\nalias xnvim='rg var | fzf | cut -d':' -f 1 | xargs -n 1 nvim'" \
    >>~/.bashrc

  echo -e '\nalias bat="batcat"' \
    >>~/.bashrc

  # evals
  echo -e '\neval "$(zoxide init --cmd cd bash)"' \
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
source ~/.profile
typecheck go
# --

# -- Alacritty Installation
echo "" | curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.bashrc
git clone https://github.com/alacritty/alacritty.git
rustup override set stable
rustup update stable
cd alacritty || exit
cargo build --release
sudo cp target/release/alacritty /usr/local/bin
sudo cp extra/logo/alacritty-term.svg /usr/share/pixmaps/Alacritty.svg
sudo desktop-file-install extra/linux/Alacritty.desktop
sudo update-desktop-database
gotoHome

# Install fd-find
echo "####### Installing fdfind #######"
yes | sudo apt-get install fd-find &&
  typecheck fdfind

# Install fzf
echo "####### Installing fzf #######"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
typecheck fzf

# Install Python3
echo "####### Installing Python #######"
yes | sudo apt-get install python3 &&
  typecheck python3

# Install ripgrep
echo "####### Installing Ripgrep #######"
sudo apt-get install ripgrep &&
  typecheck rg

# Install Lazygit
echo "####### Installing Lazygit #######"
go install github.com/jesseduffield/lazygit@latest &&
  typecheck lazygit

# Install luarocks
echo "####### Installing Luarocks #######"
yes | sudo apt-get install luarocks

# Install zoxide
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
source ~/.bashrc

# Install Starship manually...
# curl -sS https://starship.rs/install.sh | sh
# Add eval to the .bashrc manually
# echo -e '\neval "$(starship init bash)"' \
# >>~/.bashrc
#
# -- Setup Git credentials
# git config --global user.name $user
# git config --global user.email $email
# --

# Update path
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin/:$HOME/.local/bin/" >>~/.profile
source ~/.profile

# Add some aliases
add_alias

# Fetch TPM
echo " ####### Setting up TPM #######"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# --
