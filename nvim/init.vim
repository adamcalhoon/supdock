set runtimepath^=~/.vim runtimepath+=~/.vim/plugins runtimepath+=~/.vim/after
let &packpath=&runtimepath

filetype plugin indent on

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugins')
Plug 'altercation/vim-colors-solarized'
Plug 'ervandew/supertab'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'acalhoon/nvim-lsp', { 'branch': 'develop' } " lsp required tweak
Plug 'rhysd/vim-clang-format'
Plug 'rrethy/vim-illuminate'
Plug 'tpope/vim-fugitive'
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
set background=dark
let g:solarized_termtrans=1
colorscheme solarized

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

    local function package_root(fname)
        return require'nvim_lsp/util'.root_pattern(XML_FILE)(fname)
    end

    require'nvim_lsp'.clangd.setup{
        cmd = {'clangd-9', '--background-index'};

        gen_cmdline_args = function(fname)
            local args = {}

            -- Find the name of the package by parsing the XML_FILE
            local xml = require'xmlreader'
            local reader = xml.from_file(('%s/%s'):format(package_root(fname), XML_FILE))
            while (reader:read()) do
                if (reader:node_type() == 'element' and reader:name() == 'name') then
                    -- Add the build space for the package as a commandline argument
                    local ws = require'os'.getenv('READY_WORKSPACE')
                    local pkg_name = reader:read_string()
                    table.insert(args, ('--compile-commands-dir=%s/build/%s'):format(ws, pkg_name))
                    break
                end
            end
            return args
        end;

        root_dir = package_root;
    }
EOF

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
