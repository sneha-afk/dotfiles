" ============================================================
" .VIMRC
" ============================================================
" Set g:have_plugins to 1 to enable vim-plug and the plugins defined
" If left at 0, a vanilla config is used (look at the keymaps!)
let g:have_plugins = 0

" =======================================
" General Settings
" =======================================
set encoding=utf-8               " Set encoding to UTF-8
set fileformats=unix,dos         " File format preference order
set shortmess+=I                 " Skip intro message
set scrolloff=5                  " Keep 5 lines of context above/below the cursor
set wrap                         " Wrap long lines
set linebreak                    " Do not break in the middle of words
set breakindent                  " Indent wrapped lines
set backspace=indent,eol,start   " Enable backspacing in INSERT mode
set clipboard+=unnamedplus       " Use the system clipboard
set signcolumn=yes               " Always show sign column
set autoread                     " Auto-reload when files externally changed
set spelllang=en_us
set foldmethod=manual
set foldlevel=99
set foldlevelstart=10
set foldnestmax=4
set belloff=all

let g:is_windows = has('win32') || has('win64')
let g:vim_home = g:is_windows ? expand('$HOME/vimfiles') : expand('~/.vim')

if has('persistent_undo')
    set undofile
    let &undodir = has('nvim') ? stdpath('data').'/undo' : expand(g:vim_home . '/undo')
    call mkdir(&undodir, 'p', 0700)
endif

" =======================================
" Windows-specific settings
" =======================================
if g:is_windows
    set shell=powershell.exe

    " Open CMD via commands (H/V mappings)
    command! TermCmd set shell=cmd | terminal
    command! VTermCmd set shell=cmd | vertical terminal

    nnoremap <leader>Ht :TermCmd<CR>
    nnoremap <leader>Vt :VTermCmd<CR>
endif

" =======================================
" Plugin Management
" =======================================
if g:have_plugins
    " Install vim-plug if not installed
    let s:autoload_dir = expand(g:vim_home . '/autoload')
    let s:plugged_dir = expand(g:vim_home . '/plugged')
    let s:plug_file = expand(s:autoload_dir . '/plug.vim')
    let s:url = 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

    " Bootstrap vim-plug if missing
    if empty(glob(s:plug_file))
        if g:is_windows
            let s:file = substitute(s:plug_file, '\\', '/', 'g')

            " Ensure UNIX endings when its downloaded
            silent execute '!powershell -Command "' .
                \ 'iwr -useb ' . s:url . ' -OutFile \"' . s:file . '\"; ' .
                \ '(gc \"' . s:file . '\" -Raw) -replace \"`r`n\",\"`n\" | sc \"' . s:file . '\" -NoNewline"'
        else
            silent execute '!curl -fLo ' . shellescape(s:plug_file) . ' --create-dirs ' . s:url
        endif

        echo 'vim-plug installed, please restart Vim.'
        finish
    endif

    call plug#begin(s:plugged_dir)
        Plug 'ghifarit53/tokyonight-vim', { 'as': 'tokyonight' }
        Plug 'itchyny/lightline.vim', { 'as': 'lightline' }
        Plug 'jiangmiao/auto-pairs'
        Plug 'tpope/vim-commentary'
        Plug 'preservim/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind', 'NERDTreeCWD'] }
    call plug#end()

    " Run PlugInstall if there are missing plugins
    autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
        \| PlugInstall --sync
        \| endif
endif

" Function to check if a plugin is available
function! IsPluginAvailable(plugin) abort
    return exists('g:plugs') && has_key(g:plugs, a:plugin)
endfunction

" =======================================
" Leader key mappings
" =======================================
let mapleader = ","      " Leader key set to comma

" SHORTCUTS
nnoremap <leader>q :q<CR>
nnoremap <leader>w :w<CR>
nnoremap <leader>x :wq<CR>
nnoremap <leader>Q :qa<CR>   " Quit all windows

" WINDOW MANAGEMENT
nnoremap <C-h> <C-w>h                        " Move to left window
nnoremap <C-j> <C-w>j                        " Move to below window
nnoremap <C-k> <C-w>k                        " Move to above window
nnoremap <C-l> <C-w>l                        " Move to right window
nnoremap <leader>vs :vsplit<CR>              " [V]ertical [S]plit
nnoremap <leader>hs :split<CR>               " [H]orizontal [S]plit

" BUFFER NAVIGATION
" Lists all buffers and prompts
nnoremap <leader>bl :ls<CR>:buffer<Space>
nnoremap ]b :bnext<CR>                          " Next buffer
nnoremap [b :bprevious<CR>                      " Previous buffer
nnoremap <leader>bd :bdelete<CR>                " Delete current buffer

" TAB OPERATIONS
nnoremap <leader>tn :tabnew<CR>              " [T]ab: [N]ew
nnoremap <leader>tc :tabclose<CR>            " [T]ab: [C]lose current
nnoremap <leader>to :tabonly<CR>             " [T]ab: close all [O]thers
nnoremap ]t :tabnext<CR>                     " Go to next tab
nnoremap [t :tabprevious<CR>                 " Go to previous tab
nnoremap <leader>tm :tabmove<CR>             " [T]ab: [M]ove current to last
nnoremap <leader>tl :tablast<CR>             " [T]ab: jump to [L]ast open

" Shortcut buffers and tabs
for i in range(1, 3)
  execute 'nnoremap <leader>b' . i . ' :' . i . 'b<CR>'
  execute 'nnoremap <leader>t' . i . ' ' . i . 'gt'
endfor

" TERMINAL OPERATIONS
tnoremap <Esc> <C-\><C-n>                    " Exit terminal mode
tnoremap <C-w>h <C-\><C-n><C-w>h             " Move left from terminal
tnoremap <C-w>j <C-\><C-n><C-w>j             " Move down from terminal
tnoremap <C-w>k <C-\><C-n><C-w>k             " Move up from terminal
tnoremap <C-w>l <C-\><C-n><C-w>l             " Move right from terminal
tnoremap <C-w>q <C-\><C-n>:bd!<CR>           " Close terminal
tnoremap <C-j> <C-\><C-n><C-d>               " Half page down
tnoremap <C-k> <C-\><C-n><C-u>               " Half page up
" Horizontal and vertical splits
nnoremap <leader>ht :terminal<CR>
nnoremap <leader>vt :vertical terminal<CR>

" FILE EXPLORER
if IsPluginAvailable('nerdtree')
    let g:loaded_netrw = 1
    let g:loaded_netrwPlugin = 1

    " Show hidden files by default (toggle with 'I')
    let NERDTreeShowHidden = 1
    let NERDTreeIgnore = ['\.pyc$', '\.swp$', '\.git$']
    let NERDTreeWinSize = 35

    nnoremap <leader>e :NERDTreeToggle<CR>  " Toggle file explorer
    nnoremap - :NERDTreeToggle<CR>
    nnoremap <leader>E :NERDTreeFind<CR>    " Reveal current file in explorer
    nnoremap <leader>. :NERDTreeCWD<CR>     " Go up to parent directory
else
    let g:netrw_winsize = 35                " Set width to 35 pixels
    let g:netrw_liststyle = 3               " Tree view
    let g:netrw_keepdir = 0                 " Keep current dir consistent

    nnoremap <leader>e :Lexplore<CR>        " Open file explorer
    nnoremap - :Lexplore<CR>
    nnoremap <leader>E :Lexplore %:p:h<CR>  " Open in current file's directory
    nnoremap <leader>. :Explore ..<CR>      " Go up to parent directory
endif

" COMMENTING
if IsPluginAvailable('vim-commentary')
    nnoremap <leader>cc :Commentary<CR>                  " Toggle current line
    nnoremap <leader>// :Commentary<CR>                  " Alternative mapping
    vnoremap <leader>c :Commentary<CR>                   " Visual mode
    nnoremap <leader>C :<C-u>Commentary<C-Left><C-Left>  " Range comment
else
    function! CommentToggle() range
        let comment_chars = {
            \ 'vim': '"',
            \ 'python': '#', 'sh': '#', 'bash': '#', 'ruby': '#', 'perl': '#',
            \ 'c': '//', 'cpp': '//', 'java': '//', 'javascript': '//', 'js': '//',
            \ 'go': '//', 'php': '//', 'typescript': '//',
            \ 'html': '<!--', 'xml': '<!--', 'css': '/*', 'scss': '/*', 'less': '/*'
            \ }

        let comment_ends = {
            \ 'html': '-->', 'xml': '-->',
            \ 'css': '*/', 'scss': '*/', 'less': '*/'
            \ }

        let ft = &filetype
        if !has_key(comment_chars, ft)
            echo "No comment syntax for filetype: " . ft
            return
        endif

        let [cstart, cend] = [comment_chars[ft], get(comment_ends, ft, '')]
        let escaped_cstart = escape(cstart, '/*')

        for lnum in range(a:firstline, a:lastline)
            let line = getline(lnum)
            let is_commented = 0

            " Check if line starts with comment marker (with optional space after)
            if line =~ '^\s*' . escaped_cstart . '\s\?'
                let is_commented = 1
                " For languages with end markers, check if they exist
                if cend != '' && line !~ escape(cend, '/*') . '\s*$'
                    let is_commented = 0
                endif
            endif

            if is_commented
                " Uncomment the line
                let line = substitute(line, '^\(\s*\)' . escaped_cstart . '\s\?', '\1', '')
                if cend != ''
                    let line = substitute(line, '\s\?' . escape(cend, '/*') . '\s*$', '', '')
                endif
            else
                " Comment the line
                let line = substitute(line, '^\(\s*\)', '\1' . cstart . ' ', '')
                if cend != ''
                    let line = substitute(line, '\s*$', ' ' . cend, '')
                endif
            endif

            call setline(lnum, line)
        endfor
    endfunction

    nnoremap <leader>cc :call CommentToggle()<CR>
    vnoremap <leader>cc :call CommentToggle()<CR>
    nnoremap <leader>// :call CommentToggle()<CR>
    vnoremap <leader>// :call CommentToggle()<CR>
endif

" =======================================
" Appearance and Colors
" =======================================
syntax on                        " Enable syntax highlighting
set number                       " Display line numbers
set t_Co=256                     " Use 256 colors
set background=dark              " Use dark mode
set cursorline                   " Highlight the current line
set showbreak=↳\                 " Wrapped line indicator
set colorcolumn=120

" Whitespace display
set list
set listchars=tab:▸\ ,trail:·,nbsp:␣
set fillchars=foldopen:▾,foldsep:│,foldclose:▸

set guifont=Geist_Mono:h10,Consolas:h10,Segoe_UI_Emoji:h10,Symbols_Nerd_Font_Mono:h10
set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50

" Set true color if available
if has('termguicolors') && ($COLORTERM ==# 'truecolor' || $COLORTERM ==# '24bit')
    set termguicolors
endif

" Color scheme
let s:schemes = ['tokyonight', 'sorbet', 'slate', 'default']
for s:scheme in s:schemes
    try
        if s:scheme ==# 'tokyonight'
            let g:tokyonight_style = 'night'
            let g:tokyonight_enable_italic = 1
        endif

        execute 'colorscheme ' . s:scheme
        break
    catch " continue to next
    endtry
endfor

" =======================================
" Window and Buffer Management
" =======================================
set splitright          " Default split rightwards
set splitbelow          " Default split downwards
set scrolloff=5         " Context lines when scrolling
set winwidth=30         " Minimum window width
set winminwidth=10      " Minimum inactive window width

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
set shiftround                   " Shift to the next round tab stop

" Soft line breaks
set breakindent                  " Enable soft line breaks
set breakindentopt=shift:4       " Indent wrapped lines by 4 spaces

" =======================================
" Search and Matching
" =======================================
set ignorecase          " Case-insensitive search
set smartcase           " Case-sensitive if uppercase
set hlsearch           " Highlight matches
set incsearch

" =======================================
" Completion and Command Line
" =======================================
set wildmenu            " Enhanced command completion
set wildmode=list:longest,full " Completion behavior
set completeopt=menu,menuone,noselect " Completion options

" =======================================
" Performance Optimizations
" =======================================
set lazyredraw          " Faster macro execution
set synmaxcol=300       " Limit syntax highlighting after some columns

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

    set statusline+=\ %{toupper(mode())}         " Mode initial
    set statusline+=\ │\                         " Separator bar
    set statusline+=\ %f                         " Filename (relative path)
    set statusline+=%r                           " [RO] if readonly
    set statusline+=%m                           " [+] if modified

    set statusline+=%=                           " Separator (right align)

    set statusline+=Ln\ %l/%L                    " Current line / Total lines
    set statusline+=,\ Col\ %c                   " Column
    set statusline+=\ │\ %p%%                    " Percent through file
    set statusline+=\ │\ %y                      " Filetype
endif

" =======================================
" File-type Specifics
" =======================================
augroup FileTypeSpecific
    autocmd!
    autocmd FileType c,h,cpp,hpp set autoindent cindent
    autocmd FileType make,go set noexpandtab
    autocmd FileType markdown,tex,text set spell wrap linebreak
    autocmd FileType lua,json,html,css set tabstop=2 shiftwidth=2 softtabstop=2
augroup END

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
" Auto Commands
" =======================================
augroup remove_whitespace
  autocmd!
  autocmd BufWritePre * if &buftype == '' && index(['diff','gitcommit'], &filetype) < 0 |
        \ let view = winsaveview() |
        \ silent! keeppatterns %s/\s\+$//e |
        \ silent! %s/\%(\n\+\%$\)//e |
        \ call winrestview(view) |
      \ endif
augroup END
