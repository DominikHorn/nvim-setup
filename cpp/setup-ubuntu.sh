#!/bin/bash

# Helper variables
REL_SCRIPT_DIR="$(dirname "$0")"
NVIM_CONFIG="${HOME}/.config/nvim"

# Colored output
YELLOW='\033[1;33m'
NC='\033[0m'

# get absolute path for a given file
get_abs_path() {
  # $1 : relative filepath
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

# exit on error
set -e

# install dependencies
sudo apt-get update
sudo apt-get install -y cmake libtool-bin gettext curl clangd-9 clang-format-12 cppman python3-pip

# warning for user
echo -e "${YELLOW}[Warning] please setup an alias 'clang-format' to 'clang-format-12'${NC}"

# install neovim from source (apt version is to old)
NEOVIM_REPO=.neovim-repo
git clone https://github.com/neovim/neovim.git $NEOVIM_REPO
cd $NEOVIM_REPO
git checkout release-0.5
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
cd -
sudo rm -rf $NEOVIM_REPO

# link necessary files to nvim config file location
mkdir -p "$NVIM_CONFIG"
if [ -f "$NVIM_CONFIG/$INIT_VIM" ]; then
  init_vim_backup="$NVIM_CONFIG/init.vim.backup"
  i=1
  while [ -f "$init_vim_backup" ]; do
    INIT_VIM="$NVIM_CONFIG/init.vim.backup-$i"
    i=$(( $i + 1 ))
  done

  echo "Detected existing 'init.vim', backing it up to $init_vim_backup"
  mv "$NVIM_CONFIG/init.vim" "$init_vim_backup"
fi
ln -s $(get_abs_path "cpp/init.vim") "$NVIM_CONFIG"

# install vim-plug plugin manager
mkdir -p "$NVIM_CONFIG"
sh -c 'curl -fLo "${HOME}/.config/nvim/autoload/plug.vim" --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# configure clangd following official documentation:
# https://clangd.llvm.org/installation
sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-9 100

# install & configure vimspector dependencies for c++
pip3 install pynvim

# execute :PlugInstall & :VimspectorInstall once to finish setup
nvim -u "$REL_SCRIPT_DIR/plugs.vim" -c :PlugInstall -c :VimspectorInstall -c :qa

# optionally configure git to use neovim in the future
read -p "Do you want to use nvim as your git editor? [y/n]: " -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    git config --global core.editor nvim
fi
