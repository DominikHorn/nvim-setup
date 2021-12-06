" ==== vim-lsp-cxx-highlight config ====
let g:cpp_class_scope_highlight = 1
let g:cpp_member_variable_highlight = 1
let g:cpp_class_decl_highlight = 1

" ==== vim-clang-format config ====
" autoformat on save
autocmd FileType c,cpp :ClangFormatAutoEnable
nnoremap <Leader>f :<C-u>ClangFormat<CR>
