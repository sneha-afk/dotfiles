" =======================================
" General Settings
" =======================================
set encoding=utf-8               " Set encoding to UTF-8
set fileencoding=utf-8
set ff=unix                      " Use Unix file format (LF endings)
set shortmess+=I                 " Skip intro message
set scrolloff=5                  " Keep 5 lines of context above/below the cursor
set splitright                   " Default vertical splits to the right side
set wrap                         " Wrap long lines
set linebreak                    " Do not break in the middle of words
set ttyfast                      " Optimize performance for fast terminals
set wildmenu                     " Enable enhanced command-line completion
set wildmode=list:longest,full   " Show possible matches like autocomplete
set completeopt=menu,menuone,noselect " Completion options for insert mode (Use Ctrl+n or Ctrl+p)
set backspace=indent,eol,start   " Enable backspacing in INSERT mode

" =======================================
" Plugin Management
" =======================================
" Set to 0 to disable having plugins
let g:have_plugins = 1
if g:have_plugins
    " Install vim-plug if not installed
    let s:vim_home = has('win32') || has('win64') ? expand('$HOME/vimfiles') : expand('~/.vim')
    let s:autoload_dir = expand(s:vim_home . '/autoload')
    let s:plugged_dir = expand(s:vim_home . '/plugged')
    let s:plug_file = expand(s:autoload_dir . '/plug.vim')

    if empty(glob(s:plug_file))
        execute 'silent !curl -fLo ' . shellescape(s:plug_file) . ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
    endif

    " Initialize plugin system
    call plug#begin(s:plugged_dir)
    Plug 'itchyny/lightline.vim', { 'as': 'lightline' }
    Plug 'jiangmiao/auto-pairs'     " Auto-pair brackets, quotes, etc.
    Plug 'cocopon/iceberg.vim', { 'as': 'iceberg'}
    call plug#end()

    " Run PlugInstall if there are missing plugins
    autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
        \| PlugInstall --sync | source $MYVIMRC
        \| endif
endif

" Function to check if a plugin is available
function! IsPluginAvailable(plugin)
    return has_key(get(g:, 'plugs', {}), a:plugin)
endfunction

" =======================================
" Appearance and Colors
" =======================================
syntax on                        " Enable syntax highlighting
set number                       " Display line numbers
set t_Co=256                     " Use 256 colors
set background=dark              " Use dark mode
set cursorline                   " Highlight the current line

" Set true color if available
if has("termguicolors")
    set termguicolors
endif

" Color scheme
if IsPluginAvailable('iceberg')
    colorscheme iceberg
else
    colorscheme slate
endif

" =======================================
" Indentation and Tabs
" =======================================
filetype indent plugin on        " Enable filetype-specific indentation
set tabstop=4                    " Tab width: 4 spaces
set shiftwidth=4                 " Indentation width: 4 spaces
set softtabstop=4                " Soft tab width: 4 spaces
set expandtab                    " Convert tabs to spaces
set smarttab                     " Smart tabbing
set autoindent                   " Auto indentation
set smartindent                  " Smart indentation for C-like languages

" =======================================
" File-type Specifics
" =======================================
autocmd FileType c set autoindent cindent
autocmd FileType make,go set noexpandtab
autocmd FileType markdown,tex set spell wrap linebreak
autocmd FileType tex set nospell

" =======================================
" Soft Line Breaks
" =======================================
set breakindent                  " Enable soft line breaks
set breakindentopt=shift:4       " Indent wrapped lines by 4 spaces

" =======================================
" Whitespace Display
" =======================================
set list                         " Show whitespace characters
set listchars=tab:▸\ ,trail:·    " Customize whitespace display

" =======================================
" Search Settings
" =======================================
set ignorecase                   " Ignore case in search
set smartcase                    " Case-sensitive search when uppercase is used
set hlsearch                     " Highlight all search results

" =======================================
" Status Line Configuration
" =======================================
set laststatus=2                 " Always show the status line

if IsPluginAvailable('lightline')
    set noshowmode      " Remove the extra mode at the bottom
    let g:lightline = {
                \ 'colorscheme': 'one',
                \ 'active': {
                \   'left': [ [ 'mode', 'paste' ],
                \             [ 'filename', 'readonly', 'modified' ]
                \           ],
                \   'right': [ [ 'lineinfo' ],
                \              [ 'percent' ],
                \              [ 'filetype' ]
                \            ]
                \ },
                \ }

    " If the global colorscheme has support for lightline, use it, else defaults to what is set above
    if exists('g:colors_name') && !empty(globpath(&rtp, 'autoload/lightline/colorscheme/' . tolower(g:colors_name) . '.vim'))
        let g:lightline.colorscheme = tolower(g:colors_name)
    endif
else
    " Fallback statusline
    set statusline=
    set statusline+=[Ln\ %3l,\ Col\ %3c]      " Line:Column
    set statusline+=\ %{&modified?'[+]':''}   " Modified flag ([+] if modified)
    set statusline+=\ %{&readonly?'[RO]':''}  " Read-only flag ([RO] if read-only)
    set statusline+=%=                        " Right-align the rest
    set statusline+=\ (%3p%%)                 " Percent
    set statusline+=\ %t                      " Shorter filename
    set statusline+=\ [%{&filetype}]          " Filetype
endif

" =======================================
" Auto-Completion for Brackets
" =======================================
if !IsPluginAvailable('auto-pairs')
    inoremap { {}<Esc>ha
    inoremap ( ()<Esc>ha
    inoremap [ []<Esc>ha
    inoremap " ""<Esc>ha
    inoremap ' ''<Esc>ha
    inoremap ` ``<Esc>ha
endif

" =======================================
" Windows: custom command for Powershell
" Debug: if you need admin access, can do it one time with :!Start-Process powershell -Verb runAs
" =======================================
if has('win32') || has('win64')
    " Default shell settings for normal operations
    let g:default_shell = &shell
    let g:default_shellcmdflag = &shellcmdflag
    let g:default_shellquote = &shellquote
    let g:default_shellxquote = &shellxquote
    let g:default_shellpipe = &shellpipe
    let g:default_shellredir = &shellredir

    " Function to set to Vim's default desired shell
    function! SetDefaultShell()
        let &shell = g:default_shell
        let &shellcmdflag = g:default_shellcmdflag
        let &shellquote = g:default_shellquote
        let &shellxquote = g:default_shellxquote
        let &shellpipe = g:default_shellpipe
        let &shellredir = g:default_shellredir
    endfunction

    " Function to use PowerShell
    function! SetPowerShell()
        set shell=powershell
        set shellcmdflag=-NoLogo\ -NoProfile\ -ExecutionPolicy\ RemoteSigned\ -Command
        set shellquote=\"
        set shellxquote=
        set shellpipe=|
        set shellredir=>
    endfunction

    " Use :Term to open Powershell
    command! Term call SetPowerShell() | term
    command! VTerm call SetPowerShell() | vertical terminal
endif
