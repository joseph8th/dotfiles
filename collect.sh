#!/usr/bin/env bash

main() {
    [[ ! -e dotfiles ]] && mkdir dotfiles
    
    # emacs
    cp -r ~/.emacs.d dotfiles
    rm ./.emacs.d/session.*

    # screen
    cp ~/.screenrc dotfiles

    # bash stuff
    cp ~/.bash_aliases dotfiles
    cp ~/.bash_profile dotfiles

    #editorconfig
    cp ~/.editorconfig dotfiles
}

main
