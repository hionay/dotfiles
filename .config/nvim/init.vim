call plug#begin(stdpath('data') . '/plugged')

Plug 'airblade/vim-gitgutter'
Plug 'arthurxavierx/vim-caser'
Plug 'christoomey/vim-tmux-navigator'
Plug 'editorconfig/editorconfig-vim'
Plug 'edkolev/tmuxline.vim'
Plug 'ekalinin/Dockerfile.vim'
Plug 'elzr/vim-json'
Plug 'ervandew/supertab'
Plug 'fatih/vim-go'
Plug 'godlygeek/tabular'
Plug 'honza/vim-snippets'
Plug 'itchyny/lightline.vim'
Plug 'jiangmiao/auto-pairs'
Plug 'junegunn/gv.vim'
Plug 'jwalton512/vim-blade'
Plug 'ludovicchabant/vim-gutentags'
Plug 'luochen1990/rainbow'
Plug 'majutsushi/tagbar'
Plug 'mhinz/vim-startify'
Plug 'milch/vim-fastlane'
Plug 'mileszs/ack.vim'
Plug 'mustache/vim-mustache-handlebars'
Plug 'plasticboy/vim-markdown'
Plug 'rhysd/vim-go-impl'
Plug 'roxma/vim-tmux-clipboard'
Plug 'rust-lang/rust.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'sainnhe/gruvbox-material'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree'
Plug 'scrooloose/syntastic'
Plug 'shawncplus/phpcomplete.vim'
Plug 'sheerun/vim-polyglot'
Plug 'SirVer/ultisnips'
Plug 'StanAngeloff/php.vim'
Plug 'stephpy/vim-php-cs-fixer'
Plug 'stephpy/vim-yaml'
Plug 'tmux-plugins/vim-tmux', {'for': 'tmux'}
Plug 'tmux-plugins/vim-tmux-focus-events'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-obsession'
Plug 'tyru/open-browser-github.vim'
Plug 'tyru/open-browser.vim'
Plug 'uarun/vim-protobuf'
Plug 'wakatime/vim-wakatime'
Plug 'Xuyuanp/nerdtree-git-plugin'

if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif

call plug#end()

set nocompatible      " We're running Vim, not Vi!
set ttyfast
syntax on             " Enable syntax highlighting
filetype on           " Enable filetype detection
filetype indent on    " Enable filetype-specific indenting
filetype plugin on    " Enable filetype-specific plugins

set encoding=utf-8              " Set default encoding to UTF-8
set autoread                    " Automatically reread changed files without asking me anything
set autoindent
set backspace=indent,eol,start  " Makes backspace key more powerful.
set incsearch                   " Shows the match while typing
set hlsearch                    " Highlight found searches

set linespace=12
set tabstop=4
set smarttab
set tags=tags
set softtabstop=4
set expandtab
set shiftwidth=4
set shiftround
set number
set mouse=a
set noerrorbells             " No beeps
set ruler                    " Show cursor position
set clipboard^=unnamed
set clipboard^=unnamedplus
set showcmd                  " Show me what I'm typing
set noswapfile               " Don't use swapfile
set nobackup                 " Don't create annoying backup files
set splitright               " Split vertical windows right to the current windows
set splitbelow               " Split horizontal windows below to the current windows
set autowrite                " Automatically save before :next, :make etc.
set hidden
set fileformats=unix,dos,mac " Prefer Unix over Windows over OS 9 formats
set noshowmatch              " Do not show matching brackets by flickering
set noshowmode               " We show the mode with airline or lightline
set ignorecase               " Search case insensitive...
set smartcase                " ... but not it begins with upper case
set completeopt=menu,menuone
set nocursorcolumn           " speed up syntax highlighting
set nocursorline
set updatetime=300
set pumheight=10             " Completion window max size
set conceallevel=2           " Concealed text is completely hidden

set shortmess+=c   " Shut off completion messages
set belloff+=ctrlg " If Vim beeps during completion

set laststatus=2
set lazyredraw

" increase max memory to show syntax highlighting for large files
set maxmempattern=20000

set timeout " Do time out on mappings and others
set timeoutlen=2000 " Wait {num} ms before timing out a mapping

" When you’re pressing Escape to leave insert mode in the terminal, it will by
" default take a second or another keystroke to leave insert mode completely
" and update the statusline. This fixes that. I got this from:
" https://powerline.readthedocs.org/en/latest/tipstricks.html#vim
if !has('gui_running')
    set ttimeoutlen=10
    augroup FastEscape
        autocmd!
        au InsertEnter * set timeoutlen=0
        au InsertLeave * set timeoutlen=1000
    augroup END
endif

syntax enable

" color
if exists('+termguicolors')
  let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

set background=dark
let g:gruvbox_material_background = 'hard'
let g:gruvbox_material_transparent_background = 0
let g:gruvbox_material_diagnostic_line_highlight = 1
colorscheme gruvbox-material

" lightline
let g:lightline = {
      \ 'colorscheme': 'gruvbox_material',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'readonly': 'LightlineReadonly',
      \   'modified': 'LightlineModified',
      \   'gitbranch': 'LightlineFugitive'
      \ },
      \ 'separator': { 'left': '', 'right': '' },
      \ 'subseparator': { 'left': '', 'right': '' }
      \ }

function! LightlineReadonly()
    return &readonly ? '' : ''
endfunction
function! LightlineModified()
	return &modifiable && &modified ? '+' : ''
endfunction
function! LightlineFugitive()
    if exists('*FugitiveHead')
        let branch = FugitiveHead()
        return branch !=# '' ? ' '.branch : ''
    endif
    return ''
endfunction

let mapleader = ","
let g:mapleader = ","
let g:EasyMotion_leader_key = '<Leader>'

" Mappings
nmap vs :vsplit<cr>
nmap sp :split<cr>
nmap <C-n> :NERDTreeToggle<cr>
nmap <leader>w :w!<cr>
nmap <leader>q :q<cr>
nmap <leader>qa :qa<cr>
nmap <leader>q! :q!<cr>
nmap <leader>gca :Gcommit -a -S<cr>
nmap <leader>gp :Gpush<cr>
nmap <leader>gl :Gpull<cr>
nmap <leader>gst :Gstatus<cr>
nmap <leader>c :!composer install <cr>
nmap cn :cn<cr>

nnoremap j gj
nnoremap k gk
imap jj <esc>

" Auto change directory to match current file ,cd
nnoremap ,cd :cd %:p:h<CR>:pwd<CR>

" Remove search highlight
" nnoremap <leader><space> :nohlsearch<CR>
function! s:clear_highlight()
      let @/ = ""
        call go#guru#ClearSameIds()
endfunction
nnoremap <silent> <leader><space> :<C-u>call <SID>clear_highlight()<CR>

" do not continue comments
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" NERDTree
let NERDTreeShowHidden=1

" Tagbar
nmap <F8> :TagbarToggle<CR>
let g:tagbar_type_php  = {
            \ 'ctagstype' : 'php',
            \ 'kinds'     : [
            \ 'i:interfaces',
            \ 'c:classes',
            \ 'd:constant definitions',
            \ 'f:functions',
            \ 'j:javascript functions:1'
            \ ]
            \ }

" Gitgutter
let g:gitgutter_max_signs = 2000
let g:ragtag_global_maps = 1

" Syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 2
let g:syntastic_check_on_wq = 0
let g:syntastic_html_checkers=['']
let g:syntastic_aggregate_errors = 1
let g:syntastic_javascript_checkers = ['eslint']
let g:syntastic_javascript_eslint_exec = './node_modules/.bin/eslint'

" ==================== vim-go ====================
let g:go_fmt_fail_silently = 1
let g:go_fmt_command = "goimports"
let g:go_debug_windows = {
      \ 'vars':  'leftabove 35vnew',
      \ 'stack': 'botright 10new',
\ }

let g:go_test_prepend_name = 1
let g:go_list_type = "quickfix"
let g:go_auto_type_info = 0
let g:go_auto_sameids = 0

let g:go_null_module_warning = 0
let g:go_echo_command_info = 1

let g:go_autodetect_gopath = 1
let g:go_metalinter_autosave_enabled = ['vet', 'golint']
let g:go_metalinter_enabled = ['vet', 'golint']

let g:go_info_mode = 'gopls'
let g:go_rename_command='gopls'
let g:go_gopls_complete_unimported = 1
let g:go_implements_mode='gopls'
let g:go_diagnostics_enabled = 1
let g:go_doc_popup_window = 1

let g:go_highlight_space_tab_error = 0
let g:go_highlight_array_whitespace_error = 0
let g:go_highlight_trailing_whitespace_error = 0
let g:go_highlight_extra_types = 0
let g:go_highlight_build_constraints = 1
let g:go_highlight_types = 0
let g:go_highlight_operators = 1
let g:go_highlight_format_strings = 0
let g:go_highlight_function_calls = 0
let g:go_gocode_propose_source = 1

let g:go_modifytags_transform = 'camelcase'
let g:go_fold_enable = []

nmap <C-g> :GoDecls<cr>
imap <C-g> <esc>:<C-u>GoDecls<cr>


" run :GoBuild or :GoTestCompile based on the go file
function! s:build_go_files()
  let l:file = expand('%')
  if l:file =~# '^\f\+_test\.go$'
    call go#test#Test(0, 1)
  elseif l:file =~# '^\f\+\.go$'
    call go#cmd#Build(0)
  endif
endfunction

augroup go
  autocmd!

  autocmd FileType go nmap <silent> <Leader>v <Plug>(go-def-vertical)
  autocmd FileType go nmap <silent> <Leader>s <Plug>(go-def-split)
  autocmd FileType go nmap <silent> <Leader>d <Plug>(go-def-tab)

  autocmd FileType go nmap <silent> <Leader>x <Plug>(go-doc-vertical)

  autocmd FileType go nmap <silent> <Leader>i <Plug>(go-info)
  autocmd FileType go nmap <silent> <Leader>l <Plug>(go-metalinter)

  autocmd FileType go nmap <silent> <leader>b :<C-u>call <SID>build_go_files()<CR>
  autocmd FileType go nmap <silent> <leader>t  <Plug>(go-test)
  autocmd FileType go nmap <silent> <leader>r  <Plug>(go-run)
  autocmd FileType go nmap <silent> <leader>e  <Plug>(go-install)

  autocmd FileType go nmap <silent> <Leader>c <Plug>(go-coverage-toggle)

  " I like these more!
  autocmd Filetype go command! -bang A call go#alternate#Switch(<bang>0, 'edit')
  autocmd Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
  autocmd Filetype go command! -bang AS call go#alternate#Switch(<bang>0, 'split')
  autocmd Filetype go command! -bang AT call go#alternate#Switch(<bang>0, 'tabe')
augroup END

" Vim-Blade
autocmd BufNewFile,BufRead *.blade.php set ft=html | set ft=phtml | set ft=blade " Fix blade auto-indent"

" Vim-Markdown
let g:vim_markdown_folding_disabled = 1 "markdown folding

"php-cs-fixer
let g:php_cs_fixer_php_path = 'php'
let g:php_cs_fixer_rules = "@PSR2,no_unused_imports"          " options: --rules (default:@PSR2)
autocmd BufWritePost *.php call PhpCsFixerFixFile()

" Deoplete
let g:deoplete#enable_at_startup = 1
call deoplete#custom#option('omni_patterns', { 'go': '[^. *\t]\.\w*' })

" add yaml stuffs
"au! BufNewFile,BufReadPost *.{yaml,yml} set filetype=yaml foldmethod=indent
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" rust
let g:rustfmt_autosave = 1

" rainbow
let g:rainbow_active = 1
