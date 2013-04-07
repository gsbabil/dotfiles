" This is vim, not vi
set nocompatible

" Vundle
source ~/.vundlerc

if &t_Co > 2 || has("gui_running")
    " Syntax highlighting
    syntax enable
    colorscheme molokai
endif

"set up man plugin
source /usr/share/vim/vim73/ftplugin/man.vim

"viminfo
set viminfo='50,\"100,:100,n~/.vim/.viminfo
set history=1000

set undofile
set undodir=~/.vimundo
set nobackup
set nowritebackup
set noswapfile

set ttyfast
set lazyredraw

set scrolloff=3

set hidden

set swb=useopen,usetab

" Delete ALL the things!
set backspace=indent,eol,start

" show statusline at all times
set laststatus=2
set statusline=%f%m%r%h%w\ [%n:%{&ff}/%Y]\ %{fugitive#statusline()}%=[0x\%04.4B][%03v][%03p%%\ %l/%L]

" show right margin at 80
set cc=80

" Enable line-numbers by default
set number

" Don't break words when breaking lines
set linebreak

" Force utf8 encoding
set enc=utf-8

" Set tabstop to 4 by default
set tabstop=4
set shiftwidth=4
set smarttab
set expandtab

" Enable autoindent
set autoindent
set smartindent

" Show unfinished commands
set showcmd

" Show pattern match halfway
set incsearch
set ignorecase
set smartcase

" Leave curser at the point where it was before editing (VimTip1142)
nmap . .`[

" Turn off terminal bell
set noerrorbells visualbell t_vb=

" enable showbreak and show the character in between lines
let &showbreak = '+++ '
set cpoptions+=n

" show full tag (together with ctags)
set sft

" rodent, begone!
set mouse=

" setting listchars
set listchars=eol:¬,tab:▸\ 

set wildmenu
set wildmode=list:longest
set wildignore+=*.class,*.o,*.hi
set wildignore+=*/.git/*,*/.hg/*

let g:haskell_conceal = 0

" autocmd settings
if has('autocmd')
    " terminal bell (again, for gui)
    autocmd GUIEnter * set visualbell t_vb=

    " Enable file type detection.
    filetype plugin indent on

    " mail-specific settings
    autocmd FileType mail set noautoindent
endif

" keybinds
" Split windows with vv or ss
nnoremap <silent> vv <C-w>v
nnoremap <silent> ss <C-w>s

map <leader>d :NERDTreeToggle<CR>
map <leader>u :GundoToggle<CR>
map <leader>p :CtrlP<CR>
map <leader>h :HLint<CR>

" We don't want that kind here
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>
vnoremap <up> <nop>
vnoremap <down> <nop>
vnoremap <left> <nop>
vnoremap <right> <nop>
