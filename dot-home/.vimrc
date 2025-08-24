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
set undofile                     " Persistent undo history across sessions
set undodir=~/.local/share/nvim/undo

" =======================================
" Plugin Management
" =======================================
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
    " Status line
    Plug 'itchyny/lightline.vim', { 'as': 'lightline' }

    " Editor enhancements
    Plug 'jiangmiao/auto-pairs'     " Auto-pair brackets, quotes, etc.
    Plug 'tpope/vim-commentary'     " Comment code easily
    Plug 'preservim/nerdtree'       " File explorer

    " Color scheme
    Plug 'ghifarit53/tokyonight-vim', { 'as': 'tokyonight' }
    call plug#end()

    " Run PlugInstall if there are missing plugins
    autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
        \| PlugInstall --sync | source $MYVIMRC
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
nnoremap <leader> :echoerr "Unmapped leader key"<CR>

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
nnoremap <leader>ba :ball<CR>                   " Open all buffers in splits

" Quick jump to buffer by number (1-9)
for i in range(1, 9)
  execute 'nnoremap <leader>' . i . ' :' . i . 'buffer<CR>'
endfor

" TAB OPERATIONS
nnoremap <leader>tn :tabnew<CR>              " [T]ab: [N]ew
nnoremap <leader>tc :tabclose<CR>            " [T]ab: [C]lose current
nnoremap <leader>to :tabonly<CR>             " [T]ab: close all [O]thers
nnoremap ]t :tabnext<CR>                     " Go to next tab
nnoremap [t :tabprevious<CR>                 " Go to previous tab
nnoremap <leader>tm :tabmove<CR>             " [T]ab: [M]ove current to last
nnoremap <leader>tl :tablast<CR>             " [T]ab: jump to [L]ast open
nnoremap <leader>t1 1gt                      " [T]ab: go to [1]
nnoremap <leader>t2 2gt                      " [T]ab: go to [2]
nnoremap <leader>t3 3gt                      " [T]ab: go to [3]
nnoremap <leader>t4 4gt                      " [T]ab: go to [4]

" TERMINAL OPERATIONS
tnoremap <Esc> <C-\><C-n>                    " Exit terminal mode
tnoremap <C-w>h <C-\><C-n><C-w>h             " Move left from terminal
tnoremap <C-w>j <C-\><C-n><C-w>j             " Move down from terminal
tnoremap <C-w>k <C-\><C-n><C-w>k             " Move up from terminal
tnoremap <C-w>l <C-\><C-n><C-w>l             " Move right from terminal
tnoremap <C-w>q <C-\><C-n>:q<CR>             " Close terminal
tnoremap <C-j> <C-\><C-n><C-d>               " Half page down
tnoremap <C-k> <C-\><C-n><C-u>               " Half page up
" Horizontal and vertical splits
nnoremap <leader>ht :terminal<CR>
nnoremap <leader>vt :terminal<Esc><C-w>L

" FILE EXPLORER
if IsPluginAvailable('nerdtree')
    let g:loaded_netrw = 1
    let g:loaded_netrwPlugin = 1

    " Show hidden files by default (toggle with 'I')
    let NERDTreeShowHidden = 1
    let NERDTreeIgnore = ['\.pyc$', '\.swp$', '\.git$']
    let NERDTreeWinSize = 35

    nnoremap <leader>n :NERDTreeToggle<CR>  " Toggle file explorer
    nnoremap - :NERDTreeToggle<CR>
    nnoremap <leader>N :NERDTreeFind<CR>    " Reveal current file in explorer
    nnoremap <leader>. :NERDTreeCWD<CR>     " Go up to parent directory
else
    let g:netrw_winsize = 35                " Set width to 35 pixels
    let g:netrw_liststyle = 3               " Tree view
    let g:netrw_keepdir = 0                 " Keep current dir consistent

    nnoremap <leader>n :Lexplore<CR>        " Open file explorer
    nnoremap - :Lexplore<CR>
    nnoremap <leader>N :Lexplore %:p:h<CR>  " Open in current file's directory
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

set guifont=Geist_Mono,Consolas,Segoe_UI_Emoji,Symbols_Nerd_Font_Mono:h10

" Set true color if available
if has("termguicolors")
    set termguicolors
endif

" Color scheme
if IsPluginAvailable('tokyonight')
    let g:tokyonight_style = 'night' " available: night, storm
    let g:tokyonight_enable_italic = 1
    colorscheme tokyonight
else
    colorscheme sorbet
endif

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

" =======================================
" Completion and Command Line
" =======================================
set wildmenu            " Enhanced command completion
set wildmode=list:longest,full " Completion behavior
set completeopt=menu,menuone,noselect " Completion options

" =======================================
" Performance Optimizations
" =======================================
set ttyfast             " Optimize performance for fast terminals
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

" =======================================
" Windows-specific settings
" =======================================
if has('win32') || has('win64')
    let g:default_shell = &shell
    let g:default_shellcmdflag = &shellcmdflag
    let g:default_shellquote = &shellquote
    let g:default_shellxquote = &shellxquote
    let g:default_shellpipe = &shellpipe
    let g:default_shellredir = &shellredir

    function! SetDefaultShell()
        let &shell = g:default_shell
        let &shellcmdflag = g:default_shellcmdflag
        let &shellquote = g:default_shellquote
        let &shellxquote = g:default_shellxquote
        let &shellpipe = g:default_shellpipe
        let &shellredir = g:default_shellredir
    endfunction

    function! SetPowerShell()
        set shell=powershell
        set shellcmdflag=-NoLogo\ -NoProfile\ -ExecutionPolicy\ RemoteSigned\ -Command
        set shellquote=\"
        set shellxquote=
        set shellpipe=|
        set shellredir=>
    endfunction

    " Windows Terminal cursor shaping
    if exists('$WT_SESSION')
        let &t_SI = "\<Esc>[6 q"  " Vertical bar in Insert mode
        let &t_EI = "\<Esc>[2 q"  " Block in Normal mode
    endif

    command! Term call SetPowerShell() | term
    command! VTerm call SetPowerShell() | vertical terminal

    nnoremap <leader>Ht :Term<CR>
    nnoremap <leader>Vt :VTerm<CR>
endif
