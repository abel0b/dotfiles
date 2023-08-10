filetype plugin on

set number

set laststatus=2

set encoding=utf-8
set fileencoding=utf-8

syntax on

filetype plugin indent on
set tabstop=4
set shiftwidth=4
set expandtab

nnoremap <S-Up> :m-2<CR>
nnoremap <S-Down> :m+<CR>
inoremap <S-Up> <Esc>:m-2<CR>
inoremap <S-Down> <Esc>:m+<CR>

" delete line without copying
nnoremap <leader>d "_d
xnoremap <leader>d "_d
xnoremap <leader>p "_dP"

if has('nvim')
    tnoremap <Esc> <C-\><C-n>
endif

" save a file requiring root privileges
if has('nvim')
    " TODO: see https://github.com/neovim/neovim/issues/1496
else
    cmap w!! w !sudo tee % >/dev/null
endif

if has('nvim')
    call plug#begin('~/.config/nvim/plugged')
else
    call plug#begin('~/.vim/plugged')
endif
Plug 'github/copilot.vim'
Plug 'honza/vim-snippets'
Plug 'itchyny/lightline.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/fzf', {'do': {-> fzf#install()}}
Plug 'junegunn/fzf.vim'
Plug 'nanotech/jellybeans.vim'
Plug 'editorconfig/editorconfig-vim'
Plug 'tpope/vim-surround'
Plug 'mbbill/undotree'
Plug 'yggdroot/indentline'
Plug 'tpope/vim-fugitive'
call plug#end()

" configure colorscheme
colorscheme jellybeans

" configure lightline colorscheme
let g:lightline = {
      \ 'colorscheme': 'jellybeans',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead'
      \ },
      \ }
