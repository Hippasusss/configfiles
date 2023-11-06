call plug#begin()
Plug 'tpope/vim-fugitive' "Git Integration
Plug 'tpope/vim-dispatch' "DEP asynch
Plug 'tpope/vim-rhubarb' "DEP github 

Plug 'vim-airline/vim-airline' "Status Bar
Plug 'vim-airline/vim-airline-themes' "Status Bar
Plug 'enricobacis/vim-airline-clock' "Status Bar Clock

Plug 'easymotion/vim-easymotion' "Search For Characters/Patterns
Plug 'Yggdroot/indentLine' "Indent Markers
Plug 'sheerun/vim-polyglot' "language packs
Plug 'vim-scripts/a.vim' "Switch between .h and .cpp
Plug 'tenfyzhong/vim-gencode-cpp' "Generate cpp function definitions

Plug 'jacquesbh/vim-showmarks' "Show marks in Gutter 
Plug 'airblade/vim-gitgutter' "Git In The Gutter

Plug 'tpope/vim-commentary' "Comment Things Out with gc
Plug 'tpope/vim-surround' "Surround things
Plug 'godlygeek/tabular' "aligning :Tabularize
Plug 'ReekenX/vim-rename2' "allow renaming of current file with :Rename

Plug 'mhinz/vim-startify' "start screen
Plug 'neoclide/coc.nvim', {'branch': 'release', 'do' : 'winget install -h --accept-source-agreements --accept-package-agreements --disable-interactivity  nodejs; yarn install'} 
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } } "search for files faster
Plug 'junegunn/fzf.vim'
call plug#end()

filetype plugin indent on
filetype plugin on

let mapleader = ","
set runtimepath+=$HOME\vimfiles\colors\
colorscheme Tomorrow-Night 
syntax on

"-----------------------------------------------------------------------------------------------------"
"-------------------------------------------------AUTO------------------------------------------------"
"-----------------------------------------------------------------------------------------------------"

augroup ClearHighlight
    autocmd!
    autocmd BufWrite,InsertEnter,WinLeave * let @/=""
augroup END

augroup PreviewWindow
    autocmd!
    autocmd BufCreate * if &previewwindow && (!bufexists(bufname('')) || expand('%:e')==#'tmp') | call FormatPreviewWindowDocs()|endif
    autocmd BufWrite * pclose | setlocal laststatus=2
    autocmd BufWinLeave * setlocal laststatus=2
augroup END

augroup RememberLineNrWhenReopeningFile
    autocmd!
    autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")| exe "normal! g'\"" | endif
augroup END

augroup UpdateGitGutter
    autocmd!
    autocmd BufEnter,BufWritePost * GitGutter
augroup END

"-----------------------------------------------------------------------------------------------------"
"-------------------------------------------------FUNC------------------------------------------------"
"-----------------------------------------------------------------------------------------------------"

" use <tab> to trigger completion and navigate to the next complete item for
" coc
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <Tab>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()


" Use K to show documentation in preview window
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

"Toggle linenumbers onoff
function! ToggleLines()
    if &number
        set nonumber
    else
        set number
    endif
endfunction

"Makes the preview window look nicer
function! FormatPreviewWindowDocs()
    let lastBufFiletype = getbufvar('#', '&filetype')
    setlocal laststatus=0
    setlocal nomodifiable
    wincmd J
    setlocal wrap
    call setbufvar('%', '&filetype', lastBufFiletype)
    call AutoResizeWindow(0)
endfunction

"Toggles marks in the gutter onoff
function! ShowMarksToggle()
    if g:showmarks_marks_are_showing
        call showmarks#ShowMarks('global')
        let g:showmarks_marks_are_showing=0
    else
        call showmarks#ShowMarks('global, enable')
        let g:showmarks_marks_are_showing=1
    endif
endfunction

"---------------------------------------private

function! AutoResizeWindow(vert)
    if a:vert
        let longest = max(map(range(1, line('$')), "virtcol([v:val, '$'])"))
        exec "vertical resize " . (longest+4)
    else
        let line_counts = 0
        if &wrap
            let width = winwidth(0)
            let line_counts = map(range(1, line('$')), "foldclosed(v:val)==v:val?1:(virtcol([v:val, '$'])/width)+1")
        else
            let line_counts = [line('$')]
        endif

        let acc = 0
        for val in a:line_counts
            let acc += val
        endfor


        let folded_lines = range(1, line('$'))
        call filter(folded_lines, "foldclosed(v:val) > 0 && foldclosed(v:val) != v:val")
        let folded_lines_count = len(lines)

        let lines = acc - folded_lines_count
        exec 'resize ' . lines
        1
    endif
endfunction
"-----------------------------------------------------------------------------------------------------"
"-------------------------------------------------SET-------------------------------------------------"
"-----------------------------------------------------------------------------------------------------"

"--Undo, backup, etc
set undofile undolevels=1000 backup
set undodir=$VIM\\back
set backupdir=$VIM\\back
set directory=$VIM\\back

"--Window Config
set pumheight=10 pumwidth=40
set columns=160
set scrolloff=999
set backspace=2
set shiftwidth=4 softtabstop=4 expandtab
set wrap linebreak
set ignorecase smartcase
set smartindent 
set sessionoptions+=resize,winpos
set splitbelow splitright
set nohlsearch

"--Global Settings
set visualbell
set wildmenu wildignore=*.meta,*.prefab,*.unity,*.session,*.asset,*.jucer,*csproj,*.sln,*.collabignore
set cursorline
set noshowmode
set encoding=utf-8
set guifont=InputMono_Medium:h10:cANSI:qDRAFT
set updatetime=1000
set incsearch
set completeopt+=preview

"--Remove Elements
set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar

"-----------------------------------------------------------------------------------------------------"
"-------------------------------------------------LET-------------------------------------------------"
"-----------------------------------------------------------------------------------------------------"
"

"--Airline
let g:airline_right_sep=''
let g:airline_left_sep=''
let g:airline_left_alt_sep = '｜'
let g:airline_right_alt_sep = '｜'
let g:airline_powerline_fonts = 1
let g:airline_theme='deus'
let airline#extensions#tabline#show_buffers = 0
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#whitespace#enabled = 1
let g:airline#extensions#cursormode#enabled = 1
let g:airline#extensions#tabline#tab_nr_type = 2 " splits and tab number
let g:airline#extensions#tabline#tabs_label = 'TABS'
let g:airline#extensions#tabline#buffers_label = 'BUFF'
let g:airline#extensions#tabline#show_close_button = 0
let g:airline#extensions#capslock#enabled = 1
let g:airline#extensions#obsession#enabled = 1
let g:airline#extensions#obsession#indicator_text = '$'
call airline#parts#define_accent('mode', 'none')
call airline#parts#define_accent('linenr', 'none')
call airline#parts#define_accent('maxlinenr', 'none')
let g:airline#extensions#clock#format = '%H:%M:%S'
let g:airline#extensions#clock#updatetime = 1000
let g:airline#extensions#tabline#formatter = 'unique_tail'

let g:cursormode_color_map = {
            \   "i": g:airline#themes#{g:airline_theme}#palette.insert.airline_a[1],
            \   "n": g:airline#themes#{g:airline_theme}#palette.normal.airline_a[1],
            \   "R": g:airline#themes#{g:airline_theme}#palette.replace.airline_a[1],
            \   "V": g:airline#themes#{g:airline_theme}#palette.visual.airline_a[1],
            \   "v": g:airline#themes#{g:airline_theme}#palette.visual.airline_a[1],
            \   "\<C-V>": g:airline#themes#{g:airline_theme}#palette.visual.airline_a[1],
            \ }

let g:coc_notify_error_icon=":("

"--GitGutter
let g:gitgutter_enabled = 1
let g:gitgutter_signs = 1
let g:gitgutter_highlight_lines = 0
let g:gitgutter_override_sign_column_highlight = 1
let g:gitgutter_sign_added = '➕'
let g:gitgutter_sign_modified = 'o'
let g:gitgutter_sign_removed = '-'
let g:gitgutter_sign_removed_first_line = 'x1'
let g:gitgutter_sign_modified_removed = 'xo'

"--Fulscreen
let g:shell_fullscreen_items = 'mt'

"--ShowMarks
let g:showmarks_marks_are_showing=0

"--Startify
let g:startify_session_persistence = 1
let g:startify_change_to_vcs_root = 1
let g:startify_fortune_use_unicode = 1
let g:startify_padding_left = 15
let g:startify_session_sort = 1
let g:startify_files_number = 5
let g:startify_custom_header = ("")
let g:startify_session_autoload = 1

let g:startify_skiplist = [
            \ 'COMMIT_EDITMSG',
            \ 'bundle/.*/doc/',
            \ '/data/repo/neovim/runtime/doc',
            \ '/Users/mhi/local/vim/share/vim/vim74/doc',
            \ '/*.txt',
            \ '/.git',
            \ ]

let g:startify_lists = [
            \ { 'type': 'sessions'  , 'header': ['   Sessions']}     ,
            \ { 'type': 'dir'       , 'header': ['   Current Directory'] }    ,
            \ { 'type': 'files'     , 'header': ['   Recent Files']} ,
            \ { 'type': 'bookmarks' , 'header': ['   Bookmarks']}    ,
            \ { 'type': 'commands'  , 'header': ['   Commands']}     ,
            \ ]

"--netrw
let g:netrw_liststyle=3

"-----------------------------------------------------------------------------------------------------"
"-------------------------------------------------MAP-------------------------------------------------"
"-----------------------------------------------------------------------------------------------------"

"---Mode
inoremap <Esc> <Nop>
inoremap jj <Esc>
nnoremap v V
nnoremap V v
nnoremap <C-v> <C-q>

"--File Save Exit
nnoremap ; :
nnoremap ;w :w<CR>
nnoremap ;wq :wq<CR>
nnoremap ;;c :pclose<space>\|<space>cclose<space>\|<space>helpclose<CR>
nnoremap <leader>cd :lcd %:p:h<CR>:pwd<CR>
nnoremap <leader>yp :let @" = expand("%")<CR>

"--Window Navigation Modification
nnoremap H <C-w>h
nnoremap J <C-w>j
nnoremap K <C-w>k
nnoremap L <C-w>l
nnoremap tl :tabnext<CR>
nnoremap th :tabprevious<CR>
nnoremap tn :tabnew<CR>
nnoremap tw <C-W>T
nnoremap - <C-w><
nnoremap = <C-w>>
nnoremap _ <C-w>-
nnoremap + <C-w>+
nnoremap <leader>- :call AutoResizeWindow(1)<CR>
nnoremap <leader>= :call AutoResizeWindow(0)<CR>
nnoremap <leader>s <C-6>

"--Wee Remaps
noremap <C-V> <Esc>"*p
nmap <leader>j <c-f>
nmap <leader>k <c-b>

"--Edit Vimrc and Color
nnoremap <leader>ev :e $MYVIMRC<CR>
nnoremap <leader>eb :e $HOME/.bashrc<CR>
nnoremap <Leader>ec :e <C-R>=get(split(globpath(&runtimepath, 'colors/' . g:colors_name . '.vim'), "\n"), 0, '')<CR><CR>
nnoremap <leader>rv :so $MYVIMRC<CR>;

"--Gutter
nnoremap <leader>gm :call ShowMarksToggle()<CR>
nnoremap <leader>gg :GitGutterSignsToggle<CR>

"--Fugitive
nnoremap ;gg :G<CR>
nnoremap ;gp :G push<CR>

"--A.Vim Switch .h .cpp
nnoremap <leader>a :A<CR>
nnoremap <leader><leader>a :AV<CR>
nnoremap <leader>A :GenDefinition<CR>

"--FZF
nnoremap <leader>fp :FZF <CR>
nnoremap <leader>fh :FZF ~ <CR>
nnoremap <leader>fg :Rg <CR>

"--Easy Motion
nmap s <Plug>(easymotion-s)
nmap / <Plug>(easymotion-sn)
omap / <Plug>(easymotion-tn)

"--Startify
nnoremap <leader>wq :SSave!<CR> :SClose<CR> :q!<CR>

"--coc
nmap <silent><leader>gd <Plug>(coc-definition)
nmap <silent><leader>gn <Plug>(coc-type-definition)
nmap <silent><leader>gs <Plug>(coc-implementation)
nmap <silent><leader>gr <Plug>(coc-references)
nmap <silent><leader>gf <Plug>(coc-fix-current)
nmap <silent><leader>gc <Plug>(coc-rename)
nmap <silent><leader>gl :call CocAction('diagnosticNext')<cr>
nmap <silent><leader>gh :call CocAction('diagnosticPrevious')<cr>
nnoremap <silent><leader>gi :call ShowDocumentation()<CR>

let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Highlight'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }
