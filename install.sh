#!/bin/bash

# Script Setup
## Global Variables
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FILES=(agignore gitconfig gitignore.global tern-project tmux.conf vimrc zshrc)
TMUX_VERSION=2.3

## Helper for colored output. Usage: color $red "Error!"
black=30 red=31 green=32 brown=33 blue=34 purple=35 cyan=36 gray=37
color() {
  echo -e "\e[1;$1m$2\e[0m"
}

source $DIR/install/helpers.sh

# Install Programs
## apt
installif zsh silversearcher-ag
installif build-essential cmake python-dev python3-dev

## npm
color $green "updating global npm packages"
make npm

# System Setup
## ZSH Setup
if [[ $SHELL != *"zsh"* ]]; then
  color $green "Setting ZSH to be the default shell"
  chsh -s "$(which zsh)"
fi

# Symlink config files to home
## TODO ask override if symlink fails
## TODO find a better way to do this than an array
color $green "Linking config files to ~/"
for file in "${FILES[@]}"; do
  link $file $HOME/.$file
done

# Neovim
make neovim

# install base16-shell
if [[ ! -e ~/.config/base16-shell ]]; then
  git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
  find  ~/.config/base16-shell/scripts -type f -exec chmod 744 {} \;
  ~/.config/base16-shell/scripts/base16-google-dark.sh
fi

# install tmux plugin manager
if [[ ! -e ~/.tmux/plugins/tpm ]]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# install latest tmux
if [[ $(tmux -V) != *"$TMUX_VERSION"* ]]; then
  color $green "Upgrading tmux to $TMUX_VERSION"
  make tmux version=$TMUX_VERSION
fi

# Install vim plug
if [[ ! -e ~/.vim/autoload/plug.vim ]]; then
  color $green "Installing vim plug"
  curl -LSsfo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# Install and configure vim plugins
vim +PlugUpdate +qa

# Install oh-my-zsh
if [ ! -n "$ZSH" ]; then
  ZSH=~/.oh-my-zsh
fi

if [[ ! "$(which thefuck)" ]]; then
  installif python3-dev python3-pip
  sudo -H pip3 install --upgrade pip setuptools thefuck
fi

if [[ ! -d "$ZSH" ]]; then
  color $green "Installing ZSH"
  git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git $ZSH
fi

color $green "Installing ZSH spaceship theme"
make zsh-theme

if [[ $SHELL != *"zsh"* ]]; then
  zsh
fi
