#!/bin/bash

#####################################################
# Install developer tools inside the docker container
#####################################################
if [ ! -d nvim ]; then
    echo "install.bash must be run in the directory where it was unpacked"
    exit
fi

# Install neovim dependencies
sudo apt-get --yes install libtool-bin gettext

# Build and install neovim with default settings
pushd . > /dev/null
git clone http://github.com/neovim/neovim.git
cd neovim
make -j8
sudo make install
popd > /dev/null

# Update bash aliases to use neovim
cat >> ~/.bash_aliases << EOF
alias vi=nvim
alias vim=nvim
alias vimdif="nvim -d"
EOF

# Install nvim-lsp clangd helper dependencies
sudo apt-get --yes install luarocks libxml2-dev
sudo luarocks install lua-xmlreader

# Update vim configuration
mkdir -p ~/.config/nvim
cp -R nvim/. ~/.config/nvim/.

# Add ftplugin to enable intellisense
pushd . > /dev/null
mkdir -p ~/.vim/after/ftplugin
cd ~/.vim/after/ftplugin
cat > c.vim << EOF
set omnifunc=v:lua.vim.lsp.omnifunc
EOF
popd > /dev/null

# Install valgrind and valgrind viewer
sudo apt-get --yes install valgrind kcachegrind
