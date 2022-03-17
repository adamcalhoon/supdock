set runtimepath^=~/.vim runtimepath+=~/.vim/plugins runtimepath+=~/.vim/after
let &packpath=&runtimepath

filetype plugin indent on

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugins')
Plug 'lifepillar/vim-solarized8'
Plug 'ervandew/supertab'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/vim-easy-align'
Plug 'neovim/nvim-lspconfig'
Plug 'rhysd/vim-clang-format'
Plug 'rrethy/vim-illuminate'
Plug 'tpope/vim-fugitive'
Plug 'nvim-lua/lsp_extensions.nvim'
Plug 'nvim-lua/completion-nvim'
call plug#end()

" set bash as the default shell
set shell=bash

" configure tabwidth and insert spaces instead of tabs
set tabstop=4        " tab width is 4 spaces
set shiftwidth=4     " indent also with 4 spaces
set expandtab        " expand tabs to spaces
set textwidth=120    " line wrap happens in column 120

" mouse enabled in normal mode
set mouse=n

" turn syntax highlighting on
syntax on

" theme
set t_8f=[38;2;%lu;%lu;%lum   " set foreground color
set t_8b=[48;2;%lu;%lu;%lum   " set background color
set t_Co=256
set termguicolors               " enable GUI colors for the terminal to get truecolo
colorscheme solarized8          " set scheme

" highlight matching braces
set showmatch

" intelligent comments
set comments=sl:/*,mb:\ *,elx:\ */

" ruler
set ruler

" line numbers
set number

" allow hidden buffers with modifications
set hidden

" tab completion mode finds longest common string then lists if more than one
set wildmode=longest,list

" highlight all matches for the word under the cursor
set nohlsearch
highlight illuminatedWord term=bold cterm=bold gui=bold ctermbg=0 ctermfg=227
let g:Illuminate_delay=250

" show spelling mistakes with underlines
set spell
hi clear SpellBad
hi SpellBad cterm=underline

" show tabs and trailing spaces
highlight IckySpaces ctermbg=52 guibg=52
match IckySpaces /\t\+\|\s\+$/

" make :find more useful
set path+=**

" draw colored line to show where line wraps will happen
set colorcolumn=120
highlight ColorColumn ctermbg=17

" vimdiff specific...
if &diff
  " ignore whitespace
  set diffopt-=iwhite
  " allow saving in diffs
  set noreadonly
  " hard quit
  map Q :cquit<CR>
endif

" setup intellisense and clang-tidy
lua << EOF
    local XML_FILE = 'package.xml'

    local function get_catkin_build_path()
        local handle = io.popen("catkin config | grep \"Build Space\" | awk '{print $4}'")
        local build_path = handle:read('*l')
        string.gsub(build_path, '\n$', '')
        return build_path
    end

    require'lspconfig'.clangd.setup{
        cmd = {'clangd-11', '--background-index'};

        on_new_config = function(new_config)
            local root_dir = new_config.root_dir(vim.api.nvim_buf_get_name(0),
                                                 vim.api.nvim_get_current_buf())

            -- Find the name of the package by parsing the XML_FILE
            local reader = require'xmlreader'.from_file(('%s/%s'):format(root_dir, XML_FILE))
            while (reader:read()) do
                if (reader:node_type() == 'element' and reader:name() == 'name') then
                    local pkg_name = reader:read_string()
                    local compile_flag = ('--compile-commands-dir=%s/%s'):format(get_catkin_build_path(), pkg_name)
                    vim.list_extend(new_config.cmd, {compile_flag})
                    break
                end
            end
        end;

        root_dir = function(fname)
            return require'lspconfig/util'.root_pattern(XML_FILE)(fname)
        end
    }
EOF

" Configure pyright lsp
"" lua << EOF
""     require'lspconfig'.pyright.setup{}
"" EOF

" Configure rust lsp
" https://github.com/neovim/nvim-lspconfig#rust_analyzer
"lua <<EOF
"
"-- nvim_lsp object
"local nvim_lsp = require'lspconfig'
"
"-- function to attach completion when setting up lsp
"local on_attach = function(client)
"    require'completion'.on_attach(client)
"end
"
"local capabilities = vim.lsp.protocol.make_client_capabilities()
"capabilities.textDocument.completion.completionItem.snippetSupport = true
"
"-- Enable rust_analyzer
"nvim_lsp.rust_analyzer.setup({
"    capabilities=capabilities,
"    on_attach=on_attach
"})
"
"-- Enable diagnostics
"vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
"  vim.lsp.diagnostic.on_publish_diagnostics, {
"    virtual_text = false,
"    signs = true,
"    update_in_insert = true,
"  }
")
"EOF

" neovim insists on making Y behave like y$
unmap Y

" Esc exits terminal mode
:tnoremap <Esc> <C-\><C-n>

" add handy aliases for intellisense tools
let g:SuperTabDefaultCompletionType="<c-x><c-o>"
nnoremap <silent> gd    <cmd>lua vim.lsp.buf.declaration()<cr>
nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<cr>
nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<cr>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<cr>
nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<cr>
nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<cr>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<cr>
nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<cr>
nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<cr>
nnoremap <silent> <space>rn <cmd>lua vim.lsp.buf.rename()<cr>

" Trigger completion with <tab>
" found in :help completion
" Use <Tab> and <S-Tab> to navigate through popup menu
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

" use <Tab> as trigger keys
imap <Tab> <Plug>(completion_smart_tab)
imap <S-Tab> <Plug>(completion_smart_s_tab)

" have a fixed column for the diagnostics to appear in
" this removes the jitter when warnings/errors flow in
set signcolumn=yes

" Set updatetime for CursorHold
" 300ms of no cursor movement to trigger CursorHold
set updatetime=300

" Show diagnostic popup on cursor hover
autocmd CursorHold * lua vim.lsp.diagnostic.show_line_diagnostics()

" Goto previous/next diagnostic warning/error
nnoremap <silent> g[ <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
nnoremap <silent> g] <cmd>lua vim.lsp.diagnostic.goto_next()<CR>

" Enable type inlay hints
autocmd CursorMoved,InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost *.rs
\ lua require'lsp_extensions'.inlay_hints{ prefix = '', highlight = "Comment", enabled = {"TypeHint", "ChainingHint", "ParameterHint"} }

" file tidying commands
function! AddCopyright()
    0r~/.config/nvim/copyright.txt
endfunction
nmap <leader>c :call AddCopyright()<cr>
nmap <leader>f :ClangFormat<cr>
nmap <leader>w :%s/\s\+$//e<CR>

augroup TerminalStuff
    au!
    autocmd TermOpen * setlocal nonumber nospell
augroup END
