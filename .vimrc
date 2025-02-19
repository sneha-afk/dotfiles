" ---------------------------------------
" General Settings
" ---------------------------------------
:set encoding=utf-8               " Set encoding to UTF-8
:set fileencoding=utf-8
:set ff=unix                      " Use Unix file format (LF endings)
:set shortmess+=I                 " Skip intro message
:set scrolloff=5                  " Keep 5 lines of context above/below the cursor
:set splitright                   " Default vertical splits to the right side
:set wrap                         " Wrap long lines
:set linebreak                    " Do not break in the middle of words
:set ttyfast                      " Optimize performance for fast terminals
:set wildmenu                     " Enable enhanced command-line completion
:set wildmode=list:longest,full   " Show possible matches like autocomplete
:set completeopt=menu,menuone,noselect " Completion options for insert mode (Use Ctrl+n or Ctrl+p)

" ---------------------------------------
" Plugins
" ---------------------------------------

" Determine the plugin directory based on the operating system
if has('win32') || has('win64')
    let s:plugin_dir = expand('~/vimfiles/autoload')
    let s:plugged_dir = expand('~/vimfiles/plugged')
else
    let s:plugin_dir = expand('~/.vim/autoload')
    let s:plugged_dir = expand('~/.vim/plugged')
endif

" Automatically install vim-plug if not found
if empty(glob(s:plugin_dir . '/plug.vim'))
    if has('win32') || has('win64')
        silent execute '!powershell -Command "Invoke-WebRequest -Uri https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim -OutFile ' . shellescape(s:plugin_dir . '/plug.vim') . '"'
    else
        silent execute '!curl -fLo ' . shellescape(s:plugin_dir . '/plug.vim') . ' --create-dirs '
            \ . 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    endif
    :autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Initialize plugin system with the correct directory
call plug#begin(s:plugged_dir)
    Plug 'cocopon/iceberg.vim', { 'as': 'icebergtheme' }  " Iceberg color scheme
call plug#end()

" Function to check if a plugin is available
function! IsPluginAvailable(plugin)
    return has_key(get(g:, 'plugs', {}), a:plugin)
endfunction

" ---------------------------------------
" Appearance and Colors
" ---------------------------------------
:syntax on                        " Enable syntax highlighting
:set number                       " Display line numbers
:set t_Co=256                     " Use 256 colors
:set background=dark              " Use dark mode
:set cursorline                   " Highlight the current line

" Set true color if available
if has("termguicolors")
    :set termguicolors
endif

" Color scheme
if IsPluginAvailable('icebergtheme')
    :colorscheme iceberg          " Use iceberg theme if available
else
    :colorscheme slate            " Fallback to slate theme
endif

" ---------------------------------------
" Indentation and Tabs
" ---------------------------------------
:set tabstop=4                    " Tab width: 4 spaces
:set shiftwidth=4                 " Indentation width: 4 spaces
:set softtabstop=4                " Soft tab width: 4 spaces
:set expandtab                    " Convert tabs to spaces
:set smarttab                     " Smart tabbing
:set autoindent                   " Auto indentation
:set smartindent                  " Smart indentation for C-like languages
:filetype indent plugin on        " Enable filetype-specific indentation

" ---------------------------------------
" Whitespace Display
" ---------------------------------------
:set list                         " Show whitespace characters
:set listchars=tab:>·,trail:·     " Customize whitespace display

" ---------------------------------------
" Search Settings
" ---------------------------------------
:set ignorecase                   " Ignore case in search
:set smartcase                    " Case-sensitive search when uppercase is used
:set hlsearch                     " Highlight all search results

" ---------------------------------------
" Status Line Configuration
" ---------------------------------------
:set laststatus=2                 " Always show the status line

" Status Line Format:
" - [Ln %l, Col %c]: Current line and column numbers.
" - %m: Modification flag (shows [+] if the file is modified).
" - %P: Percentage through the file.
" - %f: Short filename.
" - %y: File type.
:set statusline=[Ln\ %l,\ Col\ %c]\ \ \%m\ \ \ %=%P\ \ \ \ %f\ %y

" ---------------------------------------
" File-type Specifics
" ---------------------------------------
" - C files: Enable autoindent and C-specific indentation rules.
" - Make and Go files: Use hard tabs (noexpandtab).
" - Markdown and TeX: Enable spell check, soft wrapping, and line breaks.
" - TeX: Disable spell check.
:autocmd FileType c set autoindent cindent
:autocmd FileType make,go set noexpandtab
:autocmd FileType markdown,tex set spell wrap linebreak
:autocmd FileType tex set nospell

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
" Soft Line Breaks
" ---------------------------------------
:set breakindent                  " Enable soft line breaks
:set breakindentopt=shift:4       " Indent wrapped lines by 4 spaces

" ---------------------------------------
" Backspace Behavior
" ---------------------------------------
:set backspace=indent,eol,start   " Enable backspacing in INSERT mode