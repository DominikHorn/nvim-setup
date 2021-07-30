" plugins
call plug#begin('~/.config/nvim/plugged')
  " easier language server configuration, following the official
  " ':help lsp' guide
  Plug 'neovim/nvim-lspconfig'

  " autocomplete plugin, utilizing lsp
  Plug 'hrsh7th/nvim-compe'

  " cppman support in vim, i.e., press 'K' in cpp file to
  " open corresponding cpp reference for that symbol
  Plug 'DominikHorn/vim-cppman', { 'on': 'Cppman' }

  " fuzzy file search support. Can't lazy load since ctrl+p shortcut won't be
  " enabled then :(
  Plug 'ctrlpvim/ctrlp.vim'

  " autoformat on save
  Plug 'rhysd/vim-clang-format'

  " in editor professional debugging using vimspector
  Plug 'puremourning/vimspector' ", { 'do': './install_gadget.py --enable-c --enable-cpp --enable-rust' }
call plug#end()
