" general settings
set ruler
set number
set relativenumber

set incsearch

set textwidth=0
set colorcolumn=120
highlight ColorColumn ctermbg=darkgray

set signcolumn=yes

" tab/indentation style
set tabstop=2
set shiftwidth=2
set softtabstop=0
set expandtab

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

" ==== configure lsp integration ====
lua << EOF
  -- connect to clangd
  require'lspconfig'.clangd.setup{}

  -- don't show error messages at the end of the line
  vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
      virtual_text = false,
      underline = true,
      signs = true,
    }
  )

  -- mimicking code https://github.com/neovim/nvim-lspconfig#keybindings-and-completion
  local nvim_lsp = require('lspconfig')
  local on_clangd_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
    local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

    -- see `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { noremap=true, silent=true }
    buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    buf_set_keymap('n', '<leader>e', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
    buf_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    buf_set_keymap("n", "<leader>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
    buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
    buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  end

  -- TODO: add cmake lsp etc
  nvim_lsp["clangd"].setup {
    on_attach = on_clangd_attach,
    flags = {
      debounce_text_changes = 150,
    }
  }
EOF

" show line diagnostics on hover (250 ms delay) in a box
set updatetime=250
autocmd CursorHold,CursorHoldI * lua vim.lsp.diagnostic.show_line_diagnostics({focusable=false})

" ==== autoformat on save ====
autocmd FileType c,cpp :ClangFormatAutoEnable

" ==== setup nvim-compe ====
lua << EOF
  require'compe'.setup {
    enabled = true;
    autocomplete = true;
    debug = false;
    min_length = 1;
    preselect = 'enable';
    throttle_time = 80;
    source_timeout = 200;
    incomplete_delay = 400;
    max_abbr_width = 100;
    max_kind_width = 100;
    max_menu_width = 100;
    documentation = true;

    source = {
      path = true;
      nvim_lsp = true;
    };
  }

  local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
  end

  local check_back_space = function()
      local col = vim.fn.col('.') - 1
      if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
          return true
      else
          return false
      end
  end

  -- Use (s-)tab to:
  --- move to prev/next item in completion menuone
  --- jump to prev/next snippet's placeholder
  _G.tab_complete = function()
    if vim.fn.pumvisible() == 1 then
      return t "<C-n>"
    elseif check_back_space() then
      return t "<Tab>"
    else
      return vim.fn['compe#complete']()
    end
  end
  _G.s_tab_complete = function()
    if vim.fn.pumvisible() == 1 then
      return t "<C-p>"
    else
      return t "<S-Tab>"
    end
  end

  vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
  vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
  vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
  vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})

  --This line is important for auto-import
  vim.api.nvim_set_keymap('i', '<cr>', 'compe#confirm("<cr>")', { expr = true })
  vim.api.nvim_set_keymap('i', '<c-space>', 'compe#complete()', { expr = true })
EOF

" ==== Vimspector configuration ====
" vimspector keyboard mappings, emulate CLion as good as possible
nmap <F1>         <Plug>VimspectorToggleBreakpoint
nmap <leader><F1> <Plug>VimspectorToggleConditionalBreakpoint
nmap <F2>         <Plug>VimspectorAddFunctionBreakpoint

nmap <F3>         :VimspectorReset<CR>
nmap <leader><F3> <Plug>VimspectorStop
nmap <F4>         <Plug>VimspectorRestart
nmap <F5>         <Plug>VimspectorContinue
nmap <leader><F5> <Plug>VimspectorLaunch
nmap <F6>         <Plug>VimspectorPause

nmap <F7>         <Plug>VimspectorStepInto
nmap <F8>         <Plug>VimspectorStepOver
nmap <leader><F8> <Plug>VimspectorStepOut
nmap <F9>         <Plug>VimspectorRunToCursor

" install CodeLLDB as c/c++ debugging plugin support
let g:vimspector_install_gadgets = [ 'CodeLLDB' ]
" enable debug inspect popup for nvim via custom shortcut
nmap <Leader>di <Plug>VimspectorBalloonEval
xmap <Leader>di <Plug>VimspectorBalloonEval

" highlight trailing white spaces in all files
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
au BufWinEnter * match ExtraWhitespace /\s\+$/
au InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
au InsertLeave * match ExtraWhitespace /\s\+$/
au BufWinLeave * call clearmatches()

" ==== custom key bindings ====
" change directory to the currently open buffer's file location
nnoremap <silent> <leader>cd :lcd %:h<CR>
" remove trailing white spaces
nnoremap <silent> <leader>rs :let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <CR>
" convenience commands for wrapping the word under cursor in quotes
nnoremap <leader>" ciw""<Esc>P
nnoremap <leader>' ciw''<Esc>P
" fuzzy search in file using vimgrep
nnoremap <expr> <leader>t ":vimgrep /" . input("search string: ") . "/gj **/*." . input("file extension: ") . "<CR>:cw<CR>"
" debug build and launch vimspector
nnoremap <leader>d :!./build-debug.sh<CR>:call vimspector#Launch()<CR>

" ==== custom theming ====
highlight NormalFloat ctermbg=black guibg=black ctermfg=cyan guifg=cyan
highlight Pmenu ctermbg=gray guibg=gray ctermfg=black guifg=black
highlight PmenuSel ctermbg=cyan guibg=cyan ctermfg=black guifg=black
