#!/bin/bash

REL_SCRIPT_DIR="$(dirname "$0")"
NVIM_CONFIG="${HOME}/.config/nvim"

# get absolute path for a given file
get_abs_path() {
  # $1 : relative filepath
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

# install neovim
brew install neovim

# link necessary files to nvim config file location
mkdir -p "$NVIM_CONFIG"
if [ -f "$NVIM_CONFIG/$INIT_VIM"]; then
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
sh -c 'curl -fLo "${HOME}/.config/nvim/autoload/plug.vim" --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

# install & configure clangd following official documentation:
# https://clangd.llvm.org/installation
brew install llvm

# install & configure cppman (e.g., download all relevant man pages)
brew install cppman
cppman --pager nvim
cppman -c

# install & configure vimspector dependencies for c++
pip3 install pynvim

# execute :PlugInstall & :VimspectorInstall once to finish setup
nvim -c :PlugInstall -c :VimspectorInstall -c :qa

# optionally configure git to use neovim in the future
read -p "Do you want to use nvim as your git editor? [y/n]: " -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    git config --global core.editor nvim
fi
