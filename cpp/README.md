# Usage
Use the appropriate setup script for your platform, or execute the following steps manually:

1. install external dependencies for this setup, namely:
  * neovim (modern vim implementation)
  * vim-plug (plugin manager)
  * llvm & clangd (lsp support & others for c/c++)
  * cppman (cpp references presented as man pages, sourced, e.g., from
    cppreference.com)
  * pynvim (python3 legacy support for neovim. Required for Vimspector, the
    debugging tool)
2. copying this directory's `init.vim` file to your nvim config folder, e.g.,
   `~/.config/nvim/`
3. launching `nvim` and running `:PlugInstall` and thereafter `:VimspectorInstall`:

## MacOS - setup.sh prerequisites
Make sure that you have homebrew installed on your system and a working python3
installation is in your path, i.e., `pip3` is accessible.
