" ===========================
" General Settings
" ===========================

" Set backspace in INSERT mode permanently
:set backspace=indent,eol,start

" Make a tab 4 spaces, show a dot for spaces
:set tabstop=4
:set shiftwidth=4
:set softtabstop=0
:set expandtab
:set smarttab
:set matchpairs+=<:>
:set scrolloff=3

" Show all whitespace characters
:set list
:set listchars=tab:\\·,trail:·
:match ErrorMsg '\s\+$'       " Highlight trailing whitespace in red

" Case-insensitive search, unless capital letters are used
:set ignorecase
:set smartcase

" Show line numbers
:set number

" ===========================
" Status Line Configuration
" ===========================
" Left-aligned:
" Ln {line number}, Col {column number}, {modification flag if file is modified}
"
" Right-aligned:
" {percentage through file}, {file type}
"
" ===========================
:set laststatus=2             " Always show status line
:set statusline=Ln\ %l,\ Col\ %v\ %m\ %=%P,\ %Y


" ===========================
" Indentation Settings
" ===========================

" Enable file type-specific indentation and plugin support
:filetype indent plugin on
:set autoindent
:set smartindent
:set ff=unix

" Indentation rules for specific file types
:autocmd FileType python set autoindent expandtab shiftwidth=4 tabstop=4
:autocmd FileType c,cpp set autoindent cindent shiftwidth=4 tabstop=4 expandtab
:autocmd FileType make,go set noexpandtab shiftwidth=4 tabstop=4

" ===========================
" Line Wrapping
" ===========================

" Soft line breaks with wrapped lines
:set breakindent
:set breakindentopt=shift:4
:set wrap			" Wrap overflowing lines

" ===========================
" Text Encoding
" ===========================

" Set text encoding as UTF-8
:set encoding=utf8

" ===========================
" Colors & Syntax Highlighting
" ===========================

" Enable 256 colors and syntax highlighting
:set t_Co=256
:syntax enable
:colorscheme slate

:set colorcolumn=80           " Show a vertical line at column 80
:hi ColorColumn ctermbg=234

" Highlight the current cursor line
:set cursorline
:hi clear CursorLine
:hi link CursorLine CursorColumn " Link the two styles

" ===========================
" Autocompletion Settings
" ===========================

" Autocomplete brackets
:set showmatch                   " Highlight matching parenthesis
inoremap { {}<Esc>ha
inoremap ( ()<Esc>ha
inoremap [ []<Esc>ha
inoremap " ""<Esc>ha
inoremap ' ''<Esc>ha
inoremap ` ``<Esc>ha

" ===========================
" Search Settings
" ===========================

" Enable incremental search
:set incsearch                   " Show matches while typing search
:set hlsearch                    " Highlight search matches

" ===========================
" Extra
" ===========================

" >_ Customizations for the vim editor. Read more at https://github.com/dawsbot/vimrc-builder
