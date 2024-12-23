" ---------------------------------------
" General Settings
" ---------------------------------------
:set encoding=utf8           " Set text encoding as UTF-8
:set wrap                    " Wrap overflowing lines

" ---------------------------------------
" Indentation and Tabs
" ---------------------------------------
:set backspace=indent,eol,start   " Set backspace in INSERT mode permanently
:set tabstop=4                    " Set tab to 4 spaces
:set shiftwidth=4                 " Set indentation to 4 spaces
:set softtabstop=0                " Ensure consistent indentation
:set expandtab                   " Convert tabs to spaces
:set smarttab                    " Use smart tabbing for indentation
:filetype indent plugin on       " Enable filetype-specific indentation
:set autoindent                  " Auto indentation
:set smartindent                 " Smart indentation for C-like languages
:set ff=unix                     " Use Unix file format

" Indentation rules for specific file types
:autocmd FileType c set autoindent cindent    " C files autoindent and C-specific indentation
:autocmd FileType make,go set noexpandtab     " Use hard tabs for Make, Go

" ---------------------------------------
" Whitespace Display
" ---------------------------------------
:set list                       " Show whitespace characters
:set listchars=tab:🡢\ ,trail:·  " Customize whitespace characters
:set scrolloff=3                " Keep some context above/below cursor

" ---------------------------------------
" Search Settings
" ---------------------------------------
:set ignorecase                " Ignore case in search
:set smartcase                 " Use case-sensitive search when uppercase is used

" ---------------------------------------
" Line Numbers
" ---------------------------------------
:set number                    " Display line numbers

" ---------------------------------------
" Soft Line Breaks
" ---------------------------------------
:set breakindent                " Enable soft line breaks
:set breakindentopt=shift:4     " Shift wrapped lines by 4 spaces

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
" Key Mappings
" Save with Ctrl+S
" Quit with Ctrl+Q
" Save and quit with Ctrl+W
" ---------------------------------------
:nnoremap <C-s> :w<CR>         " Save with Ctrl+S
:nnoremap <C-q> :q<CR>         " Quit with Ctrl+Q
:nnoremap <C-w> :wq<CR>        " Save and quit with Ctrl+W

" ---------------------------------------
" Appearance and Colors
" ---------------------------------------
:set t_Co=256                  " Use 256 colors
:colorscheme slate             " Set color scheme to slate
:syntax on                     " Enable syntax highlighting
:set cursorline                " Highlight the current line
:hi clear CursorLine           " Clear CursorLine highlight
:highlight CursorColumn cterm=NONE ctermbg=238  " Customize CursorColumn style
:hi link CursorLine CursorColumn  " Link CursorLine and CursorColumn

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

" ---------------------------------------
" Miscellaneous Settings
" ---------------------------------------
:set smartcase                 " Automatically switch to case-sensitive search if capital letters are used

" >_ Customizations for the vim editor. Read more at https://github.com/dawsbot/vimrc-builder "

