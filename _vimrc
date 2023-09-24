"-----------------------------------------------------------------------------------------------------"
"------------------------------------------------PLUGIN-----------------------------------------------"
"-----------------------------------------------------------------------------------------------------"
call plug#begin()
Plug 'tpope/vim-fugitive' "Git Integration
Plug 'tpope/vim-rhubarb' "DEP 
Plug 'tpope/vim-surround' "Surround things
Plug 'tpope/vim-commentary' "Comment Things Out with gc
Plug 'tpope/vim-vinegar' "Netrw better
Plug 'tpope/vim-dispatch' "DEP asynch
Plug 'tpope/vim-repeat' "Repeat with . for plugins
Plug 'xolox/vim-misc' "Xolox Dependency DEP
Plug 'xolox/vim-shell' "Fullscreen Support
Plug 'vim-airline/vim-airline' "Status Bar
Plug 'vim-airline/vim-airline-themes' "Status Bar
Plug 'enricobacis/vim-airline-clock' "Status Bar Clock
Plug 'Raimondi/delimitMate' "Brace/Quote/etc Completion
Plug 'ctrlpvim/ctrlp.vim' "Search for files
Plug 'OrangeT/vim-csharp' "Better C#
Plug 'easymotion/vim-easymotion' "Search For Characters/Patterns
Plug 'osyo-manga/vim-over' "Find Replace
Plug 'Yggdroot/indentLine' "Indent Markers
Plug 'vim-scripts/a.vim' "Switch between .h and .cpp
Plug 'sheerun/vim-polyglot' "language packs
Plug 'jacquesbh/vim-showmarks' "Show marks in file
Plug 'tenfyzhong/vim-gencode-cpp' "Generate cpp function definitions
Plug 'airblade/vim-gitgutter' "Git In The Gutteer
Plug 'godlygeek/tabular' "aligning :Tabularize
Plug 'ReekenX/vim-rename2' "allow renaming of current file with :Rename
Plug 'mhinz/vim-startify' "start screen
Plug 'gillyb/stable-windows' "keep Windows aligned when new split
Plug 'neoclide/coc.nvim', { 'merged': 0, 'rev': 'release' } "lsp
call plug#end()

filetype plugin indent on
filetype plugin on

let mapleader = ","
colorscheme TomorrowNight
syntax on

"-----------------------------------------------------------------------------------------------------"
"-------------------------------------------------AUTO------------------------------------------------"
"-----------------------------------------------------------------------------------------------------"

augroup ClearHighlight
    autocmd!
    autocmd BufWrite,InsertEnter,WinLeave * let @/=""
augroup END

augroup FulscreenOnEnter
    autocmd!
    autocmd VimEnter * silent execute("Fullscreen")
augroup END

augroup HelpMax
    autocmd!
    autocmd BufWinEnter * if &l:buftype==#'help' | wincmd _ | endif
augroup END

augroup PreviewWindow
    autocmd!
    autocmd BufCreate * if &previewwindow && (!bufexists(bufname('')) || expand('%:e')==#'tmp') | call FormatPreviewWindowDocs()|endif
    autocmd BufWrite * pclose | setlocal laststatus=2
    autocmd BufWinLeave * setlocal laststatus=2
augroup END

augroup FugitiveWindow
    autocmd!
    autocmd WinEnter * if &previewwindow && &filetype==?'gitcommit' | wincmd J |endif
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

"--Resize Window To Fit
function! Sum(vals)
    let acc = 0
    for val in a:vals
        let acc += val
    endfor
    return acc
endfunction

"---------------------------------------private
function! LogicalLineCounts()
    if &wrap
        let width = winwidth(0)
        let line_counts = map(range(1, line('$')), "foldclosed(v:val)==v:val?1:(virtcol([v:val, '$'])/width)+1")
    else
        let line_counts = [line('$')]
    endif
    return line_counts
endfunction

function! LinesHiddenByFoldsCount()
    let lines = range(1, line('$'))
    call filter(lines, "foldclosed(v:val) > 0 && foldclosed(v:val) != v:val")
    return len(lines)
endfunction

function! AutoResizeWindow(vert)
    if a:vert
        let longest = max(map(range(1, line('$')), "virtcol([v:val, '$'])"))
        exec "vertical resize " . (longest+4)
    else
        let line_counts  = LogicalLineCounts()
        let folded_lines = LinesHiddenByFoldsCount()
        let lines        = Sum(line_counts) - folded_lines
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
set scrolloff=4
set backspace=2
set shiftwidth=4 softtabstop=4 expandtab
set foldenable foldmethod=manual foldlevelstart=10 foldcolumn=1
set wrap linebreak
set smartindent ignorecase smartcase
set sessionoptions+=resize,winpos
set splitbelow splitright

"--Global Settings
set visualbell
set wildmenu wildignore=*.meta,*.prefab,*.unity,*.session,*.asset,*.jucer,*csproj,*.sln,*.collabignore
set cursorline
set noshowmode
set encoding=utf-8
set guifont=InputMono_Medium:h10:cANSI:qDRAFT
set updatetime=100
set incsearch
set nohlsearch
set completeopt+=preview

"--Remove Elements
set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar

"-----------------------------------------------------------------------------------------------------"
"-------------------------------------------------LET-------------------------------------------------"
"-----------------------------------------------------------------------------------------------------"

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

"--Delimitmate
let delimitMate_expand_cr = 1
let delimitMate_matchpairs = "(:),[:],{:}"

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
let g:netrw_altv=1

"-----------------------------------------------------------------------------------------------------"
"-------------------------------------------------MAP-------------------------------------------------"
"-----------------------------------------------------------------------------------------------------"

"---Mode
inoremap <Esc> <Nop>
nnoremap <Space> <Esc>
inoremap jj <Esc>
nnoremap v V
nnoremap V <C-q>

"--File Save Exit
nnoremap ; :
nnoremap ;w :w<CR>
nnoremap ;wq :wq<CR>
nnoremap ;ewq :wqa<CR>
nnoremap ;;c :pclose<space>\|<space>cclose<space>\|<space>helpclose<CR>

"--Window Navigation Modification
nnoremap H <C-w>h
nnoremap J <C-w>j
nnoremap K <C-w>k
nnoremap L <C-w>l
nnoremap tl :tabnext<CR>
nnoremap th :tabprevious<CR>
nnoremap tn :tabnew<CR>
nnoremap tq :tabclose<CR>
nnoremap { {zz
nnoremap } }zz
nnoremap - <C-w><
nnoremap = <C-w>>
nnoremap _ <C-w>-
nnoremap + <C-w>+
nnoremap <leader>- :call AutoResizeWindow(1)<CR>
nnoremap <leader>= :call AutoResizeWindow(0)<CR>

"--Wee Remaps
noremap <C-V> <Esc>"*p
nnoremap <leader>er :Lexplore<CR>:vertical resize 30<CR>
nnoremap <C-j> <C-f>
nnoremap <C-k> <C-b>

"--Edit Vimrc and Color
nnoremap <leader>ev :e $MYVIMRC<CR>
nnoremap <leader>eb :e $HOME/.bashrc<CR>
nnoremap <leader>rv :so $MYVIMRC<CR> :Fullscreen<CR> :Fullscreen<CR>
nnoremap <Leader>ec :e <C-R>=get(split(globpath(&runtimepath, 'colors/' . g:colors_name . '.vim'), "\n"), 0, '')<CR><CR>

"--Find And Replace
nnoremap <leader>fr :OverCommandLine<CR>%s/

"--Gutter
nnoremap <leader>gm :call ShowMarksToggle()<CR>
nnoremap <leader>gl :call ToggleLines()<CR>
nnoremap <leader>gg :GitGutterSignsToggle<CR>
nnoremap <leader>gh :GitGutterLineHighlightsToggle<CR>

"--Fugitive
nnoremap ;gac :Git add -- .<CR> :Git commit -m '
nnoremap ;gg :Git<CR>

"--A.Vim Switch .h .cpp
nnoremap <leader>a :A<CR>
nnoremap <leader><leader>a :AV<CR>

"--Buffers
nnoremap <leader>bl :bprevious<CR>
nnoremap <leader>bh :bnext<CR>
nnoremap <leader>bs :buffers<CR>

"--Ctrl P
nnoremap ;;p :CtrlP<CR>

"--Easy Motion
nmap s <Plug>(easymotion-s)
nmap <leader>j <Plug>(easymotion-j)
nmap <leader>k <Plug>(easymotion-k)
nmap / <Plug>(easymotion-sn)
omap / <Plug>(easymotion-tn)
map  n <Plug>(easymotion-next)
map  N <Plug>(easymotion-prev)

"--coc
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> gl :call CocAction('diagnosticNext')<cr>
nmap <silent> gh :call CocAction('diagnosticPrevious')<cr>
nmap <silent> gq <C-o>
nnoremap <silent> gi :call ShowDocumentation()<CR>
