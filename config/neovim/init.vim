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

call plug#begin('~/.vim/plugged')
Plug 'itchyny/lightline.vim'
Plug 'scrooloose/nerdcommenter'
call plug#end()
