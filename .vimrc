" ---------------------------------------
" General Settings
" ---------------------------------------
:set encoding=utf8           " Set text encoding to UTF-8
:set wrap                    " Wrap overflowing lines

" ---------------------------------------
" Appearance and Colors
" ---------------------------------------
:set background=dark         " Set background to dark
:set number                  " Display line numbers
:set t_Co=256                " Use 256 colors
:colorscheme slate           " Set color scheme to slate
:syntax on                   " Enable syntax highlighting
:set showmatch               " Highlight matching brackets
:set hlsearch                " Highlight all search results

" Highlight the current line with a gray background
:set cursorline              " Highlight the current line
:highlight CursorLine cterm=NONE ctermbg=238

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
:set ff=unix                      " Use Unix file format

" Indentation rules for specific file types
:autocmd FileType c set autoindent cindent       " C files: autoindent and C-specific rules
:autocmd FileType make,go set noexpandtab        " Use hard tabs for Make and Go files

" ---------------------------------------
" Whitespace Display
" ---------------------------------------
:set list                        " Show whitespace characters
:set listchars=tab:>·,trail:·    " Customize whitespace display
:set scrolloff=5                 " Keep 5 lines of context above/below the cursor

" ---------------------------------------
" Search Settings
" ---------------------------------------
:set ignorecase                 " Ignore case in search
:set smartcase                  " Case-sensitive search when uppercase is used

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
" Status Line Configuration
"
" Show the current file, line and column numbers, modification flag, percent through file, and file type
" ---------------------------------------
:set laststatus=2               " Always show the status line
:set statusline=[LN\ %l,\ COL\ %c]\ \ \[%m]\ %=%f\ \ \ \%P,\ %Y


" ---------------------------------------
" Additional Optional Features
" ---------------------------------------
" Disable message prompts during file opening
:set shortmess+=I               " Skip intro message
