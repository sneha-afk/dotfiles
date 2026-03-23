" ============================================================================
" .VIMRC
" vim: set tabstop=4 shiftwidth=4 softtabstop=4 expandtab:
" ============================================================================
let g:loaded_gzip = 1
let g:loaded_tarPlugin = 1
let g:loaded_zipPlugin = 1
let g:loaded_vimballPlugin = 1
let g:loaded_tohtml = 1
let g:loaded_getscriptPlugin = 1

" Set g:have_plugins to 1 to enable vim-plug and the plugins defined
" If left at 0, a vanilla config is used (look at the keymaps!)
let g:have_plugins = 0

let g:is_windows = has('win32') || has('win64')
let g:vim_home = g:is_windows ? expand('$HOME/vimfiles') : expand('~/.vim')
let s:is_nvim = has('nvim')

" ============================================================================
" CORE
" ============================================================================
set encoding=utf-8               " Default character encoding
set fileformats=unix,dos         " Preferred line ending formats
set backspace=indent,eol,start   " Allow backspace over everything in insert mode
set autoread                     " Auto-reload files changed outside Vim
set belloff=all                  " Disable all bells
set mouse=a                      " Enable mouse support in all modes
set virtualedit=block            " Allow cursor beyond end of line in visual block mode
set spelllang=en_us
set laststatus=2

if has('persistent_undo')
    set undofile
    let &undodir = s:is_nvim ? stdpath('data').'/undo' : expand(g:vim_home . '/undo')
    if !isdirectory(&undodir) | call mkdir(&undodir, 'p', 0700) | endif
endif

" Clipboard integration: use system clipboard for yank/paste
set clipboard=unnamed,unnamedplus

set wildmenu
set wildmode=list:longest,full
set wildignore+=**/node_modules/**,**/.git/**,**/dist/**,**/build/**
set wildignore+=*.pyc,*.o,*.obj,*.swp,*.class
set path+=**
set completeopt=menu,menuone,noselect

set foldmethod=manual
set foldlevel=99
set foldlevelstart=10
set foldnestmax=4

" ============================================================================
" UI
" ============================================================================
set number                       " Show line numbers
set cursorline                   " Highlight current line
set showmode                     " Show current mode in command line
set colorcolumn=120              " Show column marker
set scrolloff=5                  " Keep n lines visible above/below cursor
" set signcolumn=yes

set wrap
set linebreak                    " Wrap at word boundaries, not mid-word
set showbreak=↳\                 " Character to show at start of wrapped lines
set breakindent                  " Indent wrapped lines to match start
set breakindentopt=shift:4       " Additional indent for wrapped lines

" Whitespace visualization
set list
set listchars=tab:▸\ ,trail:·,nbsp:␣
set fillchars=foldopen:▾,foldsep:│,foldclose:▸

if has('gui_running')
    set guifont=Geist_Mono:h10,Consolas:h10,Segoe_UI_Emoji:h10
    set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr-o:hor20
endif

set splitright          " Default split rightwards
set splitbelow          " Default split downwards
set winwidth=30         " Minimum window width
set winminwidth=10      " Minimum inactive window width

filetype indent plugin on        " Enable filetype-specific indentation
set tabstop=4                    " Tab width: 4 spaces
set shiftwidth=4                 " Indentation width: 4 spaces
set softtabstop=4                " Soft tab width: 4 spaces
set expandtab                    " Convert tabs to spaces
set smarttab                     " Smart tabbing
set autoindent                   " Auto indentation
set smartindent                  " Smart indentation for C-like languages
set shiftround                   " Shift to the next round tab stop

set noshowmode
let &statusline =
            \ ' %{toupper(mode())} ' .
            \ '│ %<%f%r%m ' .
            \ '%{exists("*FugitiveHead") && FugitiveHead() != "" ? "│ ".FugitiveHead()." " : ""}' .
            \ '%=' .
            \ '%y │ ' .
            \ '%{&ff=="unix"?"LF":&ff=="dos"?"CRLF":"CR"} │ ' .
            \ '%3p%% │ ' .
            \ '%4l:%-3c '

syntax enable
set background=dark

if $TERM_PROGRAM ==# 'WezTerm'  " See https://github.com/wezterm/wezterm/issues/6634#issuecomment-2652077850
    set notermguicolors
    set nocursorline
elseif exists('+termguicolors')
    set termguicolors
endif

let s:colorschemes = ['catppuccin', 'sorbet', 'slate']
for scheme in s:colorschemes
    try | execute 'colorscheme ' . scheme | break | catch | endtry
endfor

" ============================================================================
" SEARCH
" ============================================================================
set smartcase           " Case-sensitive if uppercase
set hlsearch            " Highlight matches
set incsearch           " Incremental search
set wrapscan            " Wrap around when searching

" Live substitution preview
if has('inccommand') || s:is_nvim
    set inccommand=nosplit
endif

" ============================================================================
" PERFORMANCE
" ============================================================================
set synmaxcol=180
set ttyfast

" Faster CursorHold events
if has('updatetime')
    set updatetime=250
endif

" Faster keymap timeout
if has('timeoutlen')
    set timeoutlen=200
endif

" ============================================================================
" PLUGIN MANAGEMENT: https://github.com/junegunn/vim-plug
" ============================================================================
function! IsPluginAvailable(plugin) abort
    return exists('g:plugs') && has_key(g:plugs, a:plugin)
endfunction

if g:have_plugins
    let s:autoload_dir = expand(g:vim_home . '/autoload')
    let s:plugged_dir = expand(g:vim_home . '/plugged')
    let s:plug_file = expand(s:autoload_dir . '/plug.vim')

    " Bootstrap vim-plug if missing
    if empty(glob(s:plug_file))
        call mkdir(s:autoload_dir, 'p')

        if g:is_windows
            silent execute '!powershell -Command "'
                        \ . 'iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim '
                        \ . '-OutFile ' . shellescape(s:plug_file)
                        \ . '"'
        else
            silent execute '!curl -fLo ' . shellescape(s:plug_file)
                        \ . ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim '
        endif

        echo 'vim-plug installed — restart Vim'
        finish
    endif

    call plug#begin(s:plugged_dir)
    Plug 'jiangmiao/auto-pairs'
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-surround'
    Plug 'preservim/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind', 'NERDTreeCWD'] }
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
    call plug#end()

    " Run PlugInstall if there are missing plugins
    augroup PlugBootstrap
        autocmd!
        autocmd VimEnter *
                    \ if len(filter(values(g:plugs), '!isdirectory(v:val.dir)')) |
                    \ PlugInstall --sync |
                    \ endif
    augroup END
endif


" ============================================================================
" PLUGIN CONFIGURATION
" ============================================================================

if IsPluginAvailable('nerdtree')
    let g:loaded_netrw = 1
    let g:loaded_netrwPlugin = 1
    let NERDTreeShowHidden = 1
    let NERDTreeIgnore = ['\.pyc$', '\.swp$', '\.git$']
    let NERDTreeWinSize = 35
else
    let g:netrw_winsize = 35
    let g:netrw_liststyle = 3
    let g:netrw_keepdir = 0
endif

if IsPluginAvailable('fzf.vim')
    let g:fzf_action = { 'ctrl-t': 'tab split', 'ctrl-x': 'split', 'ctrl-v': 'vsplit' }
endif

" ============================================================================
" KEYMAPS
" ============================================================================
let mapleader = ","

" File operations
nnoremap <leader>w :update<CR>   " Save file
nnoremap <leader>q :q<CR>        " Quit window
nnoremap <leader>x :x<CR>        " Save and quit
nnoremap <leader>Q :qa<CR>       " Quit all windows

command! Reindent normal! gg=G
nnoremap <leader>= :Reindent<CR>

nnoremap <leader>cs :nohl<CR>    " Clear search highlighting

" Window navigation
nnoremap <C-h> <C-w>h            " Move to left window
nnoremap <C-j> <C-w>j            " Move to window below
nnoremap <C-k> <C-w>k            " Move to window above
nnoremap <C-l> <C-w>l            " Move to right window
nnoremap <leader>vs :vsplit<CR>  " Vertical split
nnoremap <leader>hs :split<CR>   " Horizontal split

" Window resizing (Vim 8.2+)
if s:is_nvim || has('patch-8.2.0000')
    nnoremap <C-Up> :resize +2<CR>
    nnoremap <C-Down> :resize -2<CR>
    nnoremap <C-Left> :vertical resize -2<CR>
    nnoremap <C-Right> :vertical resize +2<CR>
endif

" Buffer operations
nnoremap ]b :bnext<CR>                     " Next buffer
nnoremap [b :bprevious<CR>                 " Previous buffer
nnoremap <leader>bd :bdelete<CR>           " Delete current buffer

" Tab operations
nnoremap <leader>tn :tabnew<CR>      " New tab
nnoremap <leader>tc :tabclose<CR>    " Close current tab
nnoremap <leader>to :tabonly<CR>     " Close all other tabs
nnoremap ]t :tabnext<CR>             " Next tab
nnoremap [t :tabprevious<CR>         " Previous tab
nnoremap <leader>tm :tabmove<CR>     " Move tab to end
nnoremap <leader>tl :tablast<CR>     " Go to last tab

" Quick access to buffers/tabs 1-3
for i in range(1, 3)
    execute 'nnoremap <leader>b' . i . ' :' . i . 'b<CR>'
    execute 'nnoremap <leader>t' . i . ' ' . i . 'gt'
endfor

" Terminal
nnoremap <leader>ht :terminal<CR>
nnoremap <leader>vt :vertical terminal<CR>
if s:is_nvim
    tnoremap <Esc> <C-\><C-n>                 " Exit terminal mode to normal
    tnoremap <C-w>h <C-\><C-n><C-w>h          " Move left from terminal
    tnoremap <C-w>j <C-\><C-n><C-w>j          " Move down from terminal
    tnoremap <C-w>k <C-\><C-n><C-w>k          " Move up from terminal
    tnoremap <C-w>l <C-\><C-n><C-w>l          " Move right from terminal
    tnoremap <C-w>q <C-\><C-n>:bd!<CR>        " Close terminal buffer
    tnoremap <C-j> <C-\><C-n><C-d>            " Scroll down half page
    tnoremap <C-k> <C-\><C-n><C-u>            " Scroll up half page
endif

" File explorer
if IsPluginAvailable('nerdtree')
    nnoremap <leader>fe :NERDTreeToggle<CR>
    nnoremap <leader>fE :NERDTreeFind<CR>
    nnoremap - :NERDTreeToggle<CR>
    nnoremap <leader>. :NERDTreeCWD<CR>
else
    nnoremap <leader>fe :Lexplore<CR>
    nnoremap <leader>fE :Lexplore %:p:h<CR>
endif

" Finders
if IsPluginAvailable('fzf.vim')
    nnoremap <leader>ff :Files<CR>
    nnoremap <leader>fb :Buffers<CR>
    nnoremap <leader>fr :History<CR>
    nnoremap <leader>fg :Rg<Space>
    nnoremap <leader>fl :Lines<CR>
    nnoremap <leader>fh :Helptags<CR>
    autocmd! FileType fzf tnoremap <buffer> <Esc> <C-c>
elseif executable('rg') || executable('fd')
    if executable('rg')
        set grepprg=rg\ --vimgrep\ --smart-case\ --hidden
        set grepformat=%f:%l:%c:%m
        command! -nargs=+ Rg execute 'silent grep! <args>' | copen
        nnoremap <leader>fg :Rg<Space>
    endif

    if executable('fd')
        command! -nargs=+ Fd call s:fd_to_qf(<q-args>)
        function! s:fd_to_qf(pattern)
            let results = systemlist('fd --type f --hidden --follow --exclude .git ' . shellescape(a:pattern))
            if empty(results)
                echo 'No matches found'
                return
            endif
            call setqflist([], 'r', {'title': 'fd: ' . a:pattern, 'items': map(results, '{"filename": v:val}')})
            copen
        endfunction
        nnoremap <leader>ff :Fd<Space>
    endif
else
    nnoremap <leader>ff :find **/*
    nnoremap <leader>fb :ls<CR>:buffer<Space>
    nnoremap <leader>fr :browse oldfiles<CR>
endif

" Commenting
if IsPluginAvailable('vim-commentary')
    nnoremap <leader>cc :Commentary<CR>
    vnoremap <leader>c :Commentary<CR>
    nnoremap <leader>C :<C-u>Commentary<C-Left><C-Left>
else
    " Fallback comment function
    function! CommentToggle() range
        let comment_chars = {
                    \ 'vim': '"',
                    \ 'python': '#', 'sh': '#', 'bash': '#', 'ruby': '#', 'perl': '#',
                    \ 'c': '//', 'cpp': '//', 'java': '//', 'javascript': '//', 'js': '//',
                    \ 'go': '//', 'php': '//', 'typescript': '//', 'rust': '//',
                    \ 'html': '<!--', 'xml': '<!--', 'css': '/*', 'scss': '/*', 'less': '/*',
                    \ 'lua': '--'
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

            if line =~ '^\s*' . escaped_cstart . '\s\?'
                let is_commented = 1
                if cend != '' && line !~ escape(cend, '/*') . '\s*$'
                    let is_commented = 0
                endif
            endif

            if is_commented
                let line = substitute(line, '^\(\s*\)' . escaped_cstart . '\s\?', '\1', '')
                if cend != ''
                    let line = substitute(line, '\s\?' . escape(cend, '/*') . '\s*$', '', '')
                endif
            else
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
endif

vnoremap < <gv
vnoremap > >gv

" Line movement (Alt key - Vim 8.2+)
nnoremap <A-j> :move .+1<CR>==
nnoremap <A-k> :move .-2<CR>==
inoremap <A-j> <Esc>:move .+1<CR>==gi
inoremap <A-k> <Esc>:move .-2<CR>==gi
vnoremap <A-j> :move '>+1<CR>gv=gv
vnoremap <A-k> :move '<-2<CR>gv=gv

nnoremap <leader>hm :messages<CR>

if !IsPluginAvailable('auto-pairs')
    inoremap { {}<Esc>ha
    inoremap ( ()<Esc>ha
    inoremap [ []<Esc>ha
    inoremap " ""<Esc>ha
    inoremap ' ''<Esc>ha
    inoremap ` ``<Esc>ha
endif

" ============================================================================
" AUTOCOMMANDS
" ============================================================================
augroup FileTypeSpecific
    autocmd!
    autocmd FileType c,h,cpp,hpp setlocal cindent
    autocmd FileType make,go setlocal noexpandtab
    autocmd FileType markdown,tex,text,plaintex setlocal spell wrap linebreak
    autocmd FileType lua,json,html,css,javascript,typescript setlocal tabstop=2 shiftwidth=2 softtabstop=2
    autocmd FileType python setlocal tabstop=4 shiftwidth=4
augroup END

augroup VimrcMisc
    autocmd!

    " Remove trailing whitespace on save
    autocmd BufWritePre * if &bt == '' && &ft !~# 'diff\|git\|markdown' |
                \ keepp %s/\s\+$//e | keepp %s/\n\+\%$//e | endif

    " Restore cursor position
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") |
                \ execute "normal! g`\"zz" | endif
augroup END
