" ==========================================
" Vim Configuration File
" ==========================================

" ==========================================
" 1. Vim-Plug 自動インストール
" ==========================================
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif


" ==========================================
" 2. プラグイン管理
" ==========================================
call plug#begin('~/.vim/plugged')

" UI / 外観
Plug 'ghifarit53/tokyonight-vim'
Plug 'itchyny/lightline.vim'
Plug 'ryanoasis/vim-devicons'

" ナビゲーション / ファイル操作
Plug 'preservim/nerdtree'

" 開発効率
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'tpope/vim-commentary'
Plug 'jiangmiao/auto-pairs'

" キーバインド アシスト
Plug 'liuchengxu/vim-which-key'


call plug#end()


" ==========================================
" 3. 基本設定
" ==========================================

" --- 文法・構文 ---
syntax on
set number
set relativenumber

set cursorline
set background=dark
set termguicolors

" --- インデント ---
set tabstop=4
set shiftwidth=4
set expandtab
set smartindent
set autoindent

" --- 検索 ---
set ignorecase
set smartcase
set incsearch
set hlsearch

" --- パフォーマンス / その他 ---
set laststatus=2
set updatetime=300
set clipboard=unnamedplus



" ==========================================
" 4. 外観設定（テーマ・ステータスラインなど）
" ==========================================

" --- Tokyo Night Theme ---
let g:tokyonight_style = 'night'
let g:tokyonight_enable_italic = 1
colorscheme tokyonight

" --- 背景透過設定 ---
highlight Normal guibg=NONE ctermbg=NONE
highlight NonText guibg=NONE ctermbg=NONE
highlight LineNr guibg=NONE ctermbg=NONE
highlight SignColumn guibg=NONE ctermbg=NONE
highlight EndOfBuffer guibg=NONE ctermbg=NONE

" --- Lightline 設定 ---
let g:lightline = {
      \ 'colorscheme': 'tokyonight',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'readonly', 'filename', 'modified' ] ]
      \ }
      \ }


" ==========================================
" 5. Coc.nvim 拡張機能
" ==========================================
let g:coc_global_extensions = [
      \ 'coc-html',
      \ 'coc-css',
      \ 'coc-tsserver',
      \ 'coc-pyright',
      \ 'coc-rust-analyzer',
      \ 'coc-go',
      \ 'coc-clangd',
      \ 'coc-java',
      \ 'coc-sh',
      \ 'coc-yaml',
      \ 'coc-sql',
      \ 'coc-json',
      \ 'coc-vimlsp',
      \ 'coc-markdown-preview-enhanced',
      \ 'coc-webview',
      \ 'coc-docker'
      \ ]

" ==========================================
" 6. キーバインド
" ==========================================

" --- vim-which-key 設定 ---
nnoremap <silent> <leader> :<c-u>WhichKey '<Space>'<CR>
vnoremap <silent> <leader> :<c-u>WhichKeyVisual '<Space>'<CR>

let g:which_key_use_floating_win = 1
let g:which_key_vertical = 1

let g:which_key_map = {
      \ 'r' : ['<Plug>(coc-rename)', 'Rename'],
      \ 'a' : ['<Plug>(coc-codeaction)', 'Code Action'],
      \ 'g' : {
      \   'name' : '+Go To',
      \   'd' : ['<Plug>(coc-definition)', 'Definition'],
      \   'r' : ['<Plug>(coc-references)', 'References'],
      \   'y' : ['<Plug>(coc-type-definition)', 'Type Definition'],
      \   'i' : ['<Plug>(coc-implementation)', 'Implementation'],
      \ },
      \ }

" --- 基本操作 ---
inoremap jj <Esc>

" --- Insert mode cursor移動 (Ctrl / Alt + hjkl) ---
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>
inoremap <A-h> <Left>
inoremap <A-j> <Down>
inoremap <A-k> <Up>
inoremap <A-l> <Right>

" --- ファイルツリー (NERDTree) ---
nnoremap <C-n> :NERDTreeToggle<CR>

" --- 検索ハイライト解除 ---
nnoremap <Esc> :nohlsearch<CR>

" --- Coc.nvim 補完操作設定 ---
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Markdownプレビューのショートカット
autocmd FileType markdown nnoremap <C-p> :CocCommand markdown-preview-enhanced.openPreview<CR>

" --- 言語サーバーのアクション ---
" 定義ジャンプ (GoTo Definition)
nmap <silent> gd <Plug>(coc-definition)
" 参照確認 (GoTo References)
nmap <silent> gr <Plug>(coc-references)
" 型定義ジャンプ
nmap <silent> gy <Plug>(coc-type-definition)
" 実装ジャンプ
nmap <silent> gi <Plug>(coc-implementation)

" K でホバー表示（ドキュメント確認）
nnoremap <silent> K :call ShowDocumentation()<CR>
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" コードアクション (エラーの自動修正提案など)
nmap <leader>ac <Plug>(coc-codeaction)
" リネーム (変数名の一括変更)
nmap <leader>rn <Plug>(coc-rename)nnoremap <Space>p :put =system('win32yank.exe -o --lf')<CR>
