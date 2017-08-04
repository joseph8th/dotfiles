#!/usr/bin/env bash

overwrite() {
    [[ ! -e "$1" ]] && return 0

    read -p "Overwrite $1 ? REALLY? {yes|no}: " doow
    [[ "$doow" == "yes" ]]  && return 0 || return 1
}

main() {
    local dotfiles=$(ls -d1 ./dotfiles/.*)

    for f in $dotfiles; do
	echo $f
    done
}

main
