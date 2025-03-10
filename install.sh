#!/bin/bash -e

INSTALL_TARAGET=~/.config/nvim
PKG_INSTALL_COMMAND="yay -S" 

# Make config directory for Neovim's init.vim
echo '[*] Preparing Neovim config directory ...'
mkdir -p $INSTALL_TARAGET

# Install nvim (and its dependencies: pip3, git), Python 3 and ctags (for tagbar)
echo '[*] App installing Neovim and its dependencies (Python 3 and git), and dependencies for tagbar (exuberant-ctags) ...'
$PKG_INSTALL_COMMAND neovim python python-pip git curl python-neovim-git 

# Install virtualenv to containerize dependencies
echo '[*] Pip installing virtualenv to containerize Neovim dependencies (instead of installing them onto your system) ...'
python3 -m pip install --user virtualenv
python3 -m virtualenv -p python3 $INSTALL_TARAGET/env

# Install pip modules for Neovim within the virtual environment created
echo '[*] Activating virtualenv and pip installing Neovim (for Python plugin support), libraries for async autocompletion support (jedi, psutil, setproctitle), and library for pep8-style formatting (yapf) ...'
source $INSTALL_TARAGET/env/bin/activate
pip install neovim==0.2.6 jedi psutil setproctitle yapf
deactivate

# Install vim-plug plugin manager
echo '[*] Downloading vim-plug, the best minimalistic vim plugin manager ...'
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# (Optional but recommended) Install a nerd font for icons and a beautiful airline bar (https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts) (I'll be using Iosevka for Powerline)
echo "[*] Downloading patch font into ~/.local/share/fonts ..."
curl -fLo ~/.fonts/Iosevka\ Term\ Nerd\ Font\ Complete.ttf --create-dirs https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Iosevka/Regular/complete/Iosevka%20Term%20Nerd%20Font%20Complete.ttf

# (Optional) Alias vim -> nvim
echo '[*] Aliasing vim -> nvim, remember to source ~/.zshrc...'
echo "alias vim='nvim'" >> ~/.zshrc

# Enter Neovim and install plugins using a temporary init.vim, which avoids warnings about missing colorschemes, functions, etc
echo -e '[*] Running :PlugInstall within nvim ...'
sed '/call plug#end/q' init.vim > $INSTALL_TARAGET/init.vim
nvim -c ':PlugInstall' -c ':UpdateRemotePlugins' -c ':qall'
#rm ~/.config/nvim/init.vim

# Copy init.vim in current working directory to nvim's config location ...
echo '[*] Copying init.vim -> $INSTALL_TARAGET/init.vim'
cp init.vim $INSTALL_TARAGET

echo -e "[+] Done, welcome to \033[1m\033[92mNeoVim\033[0m! Try it by running: nvim/vim. Want to customize it? Modify $INSTALL_TARAGET/init.vim"

