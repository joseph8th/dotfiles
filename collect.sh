#!/usr/bin/env bash

main() {
    # emacs
    cp -r ~/.emacs.d .
    rm ./.emacs.d/session.*

    # screen
    cp ~/.screenrc .

    # bash stuff
    cp ~/.bash_aliases .
    cp ~/.bash_profile .

    #editorconfig
    cp ~/.editorconfig .
}

main
