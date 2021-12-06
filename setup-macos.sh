#!/bin/bash

REL_SCRIPT_DIR="$(dirname "$0")"
NVIM_CONFIG="${HOME}/.config/nvim"
INIT_VIM="init.vim"

# get absolute path for a given file
get_abs_path() {
  # $1 : relative filepath
  echo "$(cd "$(dirname "$1")" && pwd)/$(basename "$1")"
}

# exit on error
set -e

# install neovim
brew install neovim llvm

# configure clangd following official documentation: https://clangd.llvm.org/installation
cat <<EOT >> ~/.customrc

# overwrite system clang if we're in a rosetta terminal
if [ "\$(uname -m)" = "x86_64" ]; then
  export PATH="/usr/local/opt/llvm/bin:\$PATH"
  export CC="/usr/local/opt/llvm/bin/clang"
  export CXX="\${CC}++"
  export LDFLAGS="-L/usr/local/opt/llvm/lib -Wl,-rpath,/usr/local/opt/llvm/lib"
  export CPPFLAGS="-I/usr/local/opt/llvm/include -I/usr/local/opt/llvm/include/c++/v1/"
fi
EOT

# install & configure vimspector dependencies
pip3 install pynvim

# execute :PlugInstall & :VimspectorInstall once to finish setup
nvim -u "$REL_SCRIPT_DIR/plugs.vim" -c :PlugInstall -c :VimspectorInstall -c :qa

# optionally configure git to use neovim in the future
read -p "Do you want to use nvim as your git editor? [y/n]: " -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
    git config --global core.editor nvim
fi
