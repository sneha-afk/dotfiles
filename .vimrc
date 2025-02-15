" ---------------------------------------
" General Settings
" ---------------------------------------
:set encoding=utf8           " Set text encoding to UTF-8
:set wrap                    " Wrap overflowing lines
:set mouse=a                 " Mouse support: visual mode, resizing splits

" ---------------------------------------
" Appearance and Colors
" ---------------------------------------
:syntax on                   " Enable syntax highlighting
:set number                  " Display line numbers
:set t_Co=256                " Use 256 colors

" Color scheme
:colorscheme slate

" Highlight the current line with a gray background
:set cursorline
:highlight CursorLine cterm=NONE ctermbg=238

" ---------------------------------------
" File-type Specifics
"   C files: autoindent and C-specific rules
"   Use hard tabs for Make and Go files
" ---------------------------------------
:autocmd FileType c set autoindent cindent
:autocmd FileType make,go set noexpandtab
:autocmd FileType markdown,tex set spell wrap linebreak
:autocmd FileType tex set nospell

" ---------------------------------------
" Indentation and Tabs
" ---------------------------------------
:set backspace=indent,eol,start   " Enable backspacing in INSERT mode
:set tabstop=4                    " Tab width: 4 spaces
:set shiftwidth=4                 " Indentation width: 4 spaces
:set softtabstop=4                " Soft tab width: 4 spaces
:set expandtab                    " Convert tabs to spaces
:set smarttab                     " Smart tabbing
:filetype indent plugin on        " Enable filetype-specific indentation
:set autoindent                   " Auto indentation
:set smartindent                  " Smart indentation for C-like languages
:set ff=unix                      " Use Unix file format (LF endings)

" ---------------------------------------
" Status Line Configuration
"
" Show the current file, line and column numbers, modification flag, percent through file, and file type
" ---------------------------------------
:set laststatus=2               " Always show the status line
:set statusline=[Ln\ %l,\ Col\ %c]\ \ \%m\ %=%P\ \ \ \ %f\ %y


" ---------------------------------------
" Whitespace Display
" ---------------------------------------
:set list                        " Show whitespace characters
:set listchars=tab:>·,trail:·    " Customize whitespace display
:set scrolloff=5                 " Keep a number of lines of context above/below the cursor

" ---------------------------------------
" Search Settings
" ---------------------------------------
:set ignorecase                 " Ignore case in search
:set smartcase                  " Case-sensitive search when uppercase is used
:set hlsearch                   " Highlight all search results

" ---------------------------------------
" Soft Line Breaks
" ---------------------------------------
:set breakindent                " Enable soft line breaks
:set breakindentopt=shift:4     " Indent wrapped lines by 4 spaces

" ---------------------------------------
" Auto-Completion for Brackets
" ---------------------------------------
:inoremap { {}<Esc>ha
:inoremap ( ()<Esc>ha
:inoremap [ []<Esc>ha
:inoremap " ""<Esc>ha
:inoremap ' ''<Esc>ha
:inoremap ` ``<Esc>ha

" ---------------------------------------
" Additional Optional Features
" Disable message prompts during file opening
" ---------------------------------------
:set shortmess+=I               " Skip intro message
