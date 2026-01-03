" ============================================================================
" .VIMRC
" ============================================================================
" Set g:have_plugins to 1 to enable vim-plug and the plugins defined
" If left at 0, a vanilla config is used (look at the keymaps!)
let g:have_plugins = 0

let g:is_windows = has('win32') || has('win64')
let g:vim_home = g:is_windows ? expand('$HOME/vimfiles') : expand('~/.vim')

" ============================================================================
" EDITING BEHAVIOR
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
  set undofile                   " Save undo history to file
  let &undodir = has('nvim') ? stdpath('data').'/undo' : expand(g:vim_home . '/undo')
  call mkdir(&undodir, 'p', 0700)
endif

" Clipboard integration: use system clipboard for yank/paste
set clipboard+=unnamedplus

" ============================================================================
" UI & VISUAL FEEDBACK
" ============================================================================
set number                       " Show line numbers
set cursorline                   " Highlight current line
set showmode                     " Show current mode in command line
set colorcolumn=120              " Show column marker
set scrolloff=5                  " Keep n lines visible above/below cursor
set shortmess+=I                 " Don't show intro message on startup
" set signcolumn=yes

set wrap
set linebreak                    " Wrap at word boundaries, not mid-word
set showbreak=↳\                 " Character to show at start of wrapped lines
set breakindent                  " Indent wrapped lines to match start
set breakindentopt=shift:4       " Additional indent for wrapped lines

" Whitespace visualization
set list                         " Show invisible characters
set listchars=tab:▸\ ,trail:·,nbsp:␣ " Symbols for tab, trailing space, non-breaking space
set fillchars=foldopen:▾,foldsep:│,foldclose:▸ " Characters for fold display

set guifont=Geist_Mono:h10,Consolas:h10,Segoe_UI_Emoji:h10
set guicursor=n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50

" True color support (Vim 8.2+)
if has('termguicolors') && ($COLORTERM ==# 'truecolor' || $COLORTERM ==# '24bit')
    set termguicolors
endif

" ============================================================================
" WINDOWS & SPLITS
" ============================================================================
set splitright          " Default split rightwards
set splitbelow          " Default split downwards
set winwidth=30         " Minimum window width
set winminwidth=10      " Minimum inactive window width

" ============================================================================
" INDENTATION
" ============================================================================
filetype indent plugin on        " Enable filetype-specific indentation
set tabstop=4                    " Tab width: 4 spaces
set shiftwidth=4                 " Indentation width: 4 spaces
set softtabstop=4                " Soft tab width: 4 spaces
set expandtab                    " Convert tabs to spaces
set smarttab                     " Smart tabbing
set autoindent                   " Auto indentation
set smartindent                  " Smart indentation for C-like languages
set shiftround                   " Shift to the next round tab stop

" ============================================================================
" SEARCH
" ============================================================================
set ignorecase          " Case-insensitive search
set smartcase           " Case-sensitive if uppercase
set hlsearch            " Highlight matches
set incsearch           " Incremental search
set wrapscan            " Wrap around when searching

" Live substitution preview
if has('nvim') || has('inccommand')
  set inccommand=nosplit
endif

" ============================================================================
" FOLDING
" ============================================================================
set foldmethod=manual
set foldlevel=99
set foldlevelstart=10
set foldnestmax=4

" ============================================================================
" COMPLETION & COMMAND LINE
" ============================================================================
set wildmenu
set wildmode=list:longest,full
set completeopt=menu,menuone,noselect

" ============================================================================
" PERFORMANCE
" ============================================================================
set lazyredraw
set synmaxcol=300

" Faster CursorHold events
if has('updatetime')
  set updatetime=250
endif

" Faster keymap timeout
if has('timeoutlen')
  set timeoutlen=300
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
    Plug 'ghifarit53/tokyonight-vim', { 'as': 'tokyonight' }
    Plug 'itchyny/lightline.vim', { 'as': 'lightline' }
    Plug 'jiangmiao/auto-pairs'
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-surround'
    Plug 'preservim/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind', 'NERDTreeCWD'] }
  call plug#end()

    " Run PlugInstall if there are missing plugins
  autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
        \| PlugInstall --sync
        \| endif
endif

" ============================================================================
" COLOR SCHEME
" ============================================================================
syntax on                        " Enable syntax highlighting
set background=dark              " Use dark color scheme variant

let s:schemes = ['tokyonight', 'sorbet', 'slate', 'default']
for s:scheme in s:schemes
  try
    if s:scheme ==# 'tokyonight'
      let g:tokyonight_style = 'night'
      let g:tokyonight_enable_italic = 1
    endif
    execute 'colorscheme ' . s:scheme
    break
  catch
  endtry
endfor

" ============================================================================
" PLUGIN CONFIGURATION
" ============================================================================

" Lightline
if IsPluginAvailable('lightline')
  set noshowmode
  let g:lightline = {
        \ 'colorscheme': 'one',
        \ 'active': {
        \   'left': [ [ 'mode', 'paste' ],
        \             [ 'filename', 'readonly', 'modified' ] ],
        \   'right': [ [ 'lineinfo' ],
        \              [ 'percent' ],
        \              [ 'filetype' ] ]
        \ }
        \ }

  if exists('g:colors_name') && !empty(globpath(&rtp, 'autoload/lightline/colorscheme/' . tolower(g:colors_name) . '.vim'))
    let g:lightline.colorscheme = tolower(g:colors_name)
  endif
else
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

" NERDTree
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

" ============================================================================
" KEYMAPS
" ============================================================================
let mapleader = ","

" File operations
nnoremap <leader>w :w<CR>        " Save file
nnoremap <leader>q :q<CR>        " Quit window
nnoremap <leader>x :wq<CR>       " Save and quit
nnoremap <leader>Q :qa<CR>       " Quit all windows

nnoremap <leader>cs :nohl<CR>    " Clear search highlighting

" Window navigation
nnoremap <C-h> <C-w>h            " Move to left window
nnoremap <C-j> <C-w>j            " Move to window below
nnoremap <C-k> <C-w>k            " Move to window above
nnoremap <C-l> <C-w>l            " Move to right window
nnoremap <leader>vs :vsplit<CR>  " Vertical split
nnoremap <leader>hs :split<CR>   " Horizontal split

" Window resizing (Vim 8.2+)
if has('nvim') || has('patch-8.2.0000')
  nnoremap <C-Up> :resize +2<CR>            " Increase height
  nnoremap <C-Down> :resize -2<CR>          " Decrease height
  nnoremap <C-Left> :vertical resize -2<CR> " Decrease width
  nnoremap <C-Right> :vertical resize +2<CR>" Increase width
endif

" Buffer operations
nnoremap <leader>bl :ls<CR>:buffer<Space> " List and select buffer
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

nnoremap <leader>ht :terminal<CR>
nnoremap <leader>vt :vertical terminal<CR>

tnoremap <Esc> <C-\><C-n>                 " Exit terminal mode to normal
tnoremap <C-w>h <C-\><C-n><C-w>h          " Move left from terminal
tnoremap <C-w>j <C-\><C-n><C-w>j          " Move down from terminal
tnoremap <C-w>k <C-\><C-n><C-w>k          " Move up from terminal
tnoremap <C-w>l <C-\><C-n><C-w>l          " Move right from terminal
tnoremap <C-w>q <C-\><C-n>:bd!<CR>        " Close terminal buffer
tnoremap <C-j> <C-\><C-n><C-d>            " Scroll down half page
tnoremap <C-k> <C-\><C-n><C-u>            " Scroll up half page

" File explorer
if IsPluginAvailable('nerdtree')
  nnoremap <leader>e :NERDTreeToggle<CR>
  nnoremap - :NERDTreeToggle<CR>
  nnoremap <leader>E :NERDTreeFind<CR>
  nnoremap <leader>. :NERDTreeCWD<CR>
else
  nnoremap <leader>e :Lexplore<CR>
  nnoremap - :Lexplore<CR>
  nnoremap <leader>E :Lexplore %:p:h<CR>
  nnoremap <leader>. :Explore ..<CR>
endif

" Commenting
if IsPluginAvailable('vim-commentary')
  nnoremap <leader>cc :Commentary<CR>
  nnoremap <leader>// :Commentary<CR>
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
  nnoremap <leader>// :call CommentToggle()<CR>
  vnoremap <leader>// :call CommentToggle()<CR>
endif

" Visual mode enhancements
vnoremap < <gv
vnoremap > >gv

" Line movement (Alt key - Vim 8.2+)
nnoremap <A-j> :move .+1<CR>==
nnoremap <A-k> :move .-2<CR>==
inoremap <A-j> <Esc>:move .+1<CR>==gi
inoremap <A-k> <Esc>:move .-2<CR>==gi
vnoremap <A-j> :move '>+1<CR>gv=gv
vnoremap <A-k> :move '<-2<CR>gv=gv

function! ShowMessages()
  let l:view = winsaveview()  " Save current view
  silent! redraw!             " Clear screen so messages are readable
  messages
  call winrestview(l:view)
endfunction
nnoremap <leader>sm :call ShowMessages()<CR>

" ============================================================================
" AUTO-COMPLETION (Fallback)
" ============================================================================
if !IsPluginAvailable('auto-pairs')
  inoremap { {}<Esc>ha
  inoremap ( ()<Esc>ha
  inoremap [ []<Esc>ha
  inoremap " ""<Esc>ha
  inoremap ' ''<Esc>ha
  inoremap ` ``<Esc>ha
endif

" ============================================================================
" FILETYPE SPECIFIC SETTINGS
" ============================================================================
augroup FileTypeSpecific
  autocmd!
  autocmd FileType c,h,cpp,hpp setlocal cindent
  autocmd FileType make,go setlocal noexpandtab
  autocmd FileType markdown,tex,text,plaintex setlocal spell wrap linebreak
  autocmd FileType lua,json,html,css,javascript,typescript setlocal tabstop=2 shiftwidth=2 softtabstop=2
  autocmd FileType python setlocal tabstop=4 shiftwidth=4
augroup END

" ============================================================================
" AUTOCOMMANDS
" ============================================================================

" Remove trailing whitespace on save
augroup remove_whitespace
  autocmd!
  autocmd BufWritePre * if &buftype == '' && index(['diff','gitcommit','markdown','text'], &filetype) < 0 |
        \ let view = winsaveview() |
        \ silent! keeppatterns %s/\s\+$//e |
        \ silent! %s/\%(\n\+\%$\)//e |
        \ call winrestview(view) |
        \ endif
augroup END

" Restore cursor position
augroup restore_cursor
  autocmd!
  autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") |
        \ execute "normal! g`\"zz" |
        \ endif
augroup END
