" Enable syntax highlighting and filetype plugins
syntax on
filetype plugin indent on

" Display absolute and relative line numbers
set number
set relativenumber

" Highlight matching brackets/parentheses
set showmatch

" Search settings: incremental search and highlighted matches
set incsearch
set hlsearch
" Use case-insensitive search unless uppercase is used
set ignorecase
set smartcase

" Indentation settings for coding (adjust to your preference)
set tabstop=4       " A tab is 4 spaces
set shiftwidth=4    " Indent by 4 spaces when auto-indenting
set expandtab       " Convert tabs to spaces
set autoindent      " Copy indent from current line
set smartindent     " Smart auto-indenting when starting a new line

" Highlight the current cursor line
set cursorline

" Enhanced command-line completion
set wildmenu

" Persistent undo (requires creating an undo directory)
if has("persistent_undo")
    set undofile
    set undodir=~/.vim/undodir
endif

" A basic colorscheme that works in many terminal setups
colorscheme desert

" Enable mouse support (if your terminal supports it)
set mouse=a

" Do not wrap lines (helpful when editing code)
set nowrap

" Display a vertical column at 80 characters (optional code style guide)
set colorcolumn=80
