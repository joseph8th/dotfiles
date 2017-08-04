#!/usr/bin/env bash

_copy() {
    local src="$1"
    local dst="$2"
    if [[ -e "$dst" ]]; then
	read -p "Overwrite $dst ? REALLY? {yes|no}: " doow
	[[ "$doow" != "yes" ]] && echo "Skipping $src" && return 1
    fi
    if [[ -d "$dst" ]]; then
	rm -rf "$dst"
	cp -r "$src" "$dst"
    else
	cp -f "$src" "$dst"
    fi
}

deposit() {
    local fname=
    local dotfiles=$(ls -d1 ./dotfiles/.*)
    for f in $dotfiles; do
	[[ "$f" == "./dotfiles/." || "$f" == "./dotfiles/.." ]] && continue
	fname=$(basename "$f")
	_copy "$f" "$HOME/$fname"
    done
}

collect() {
    [[ ! -e dotfiles ]] && mkdir dotfiles

    # emacs
    _copy ~/.emacs.d ./dotfiles/.emacs.d
    rm ./dotfiles/.emacs.d/session.*

    # screen
    _copy ~/.screenrc ./dotfiles/.screenrc

    # bash stuff
    _copy ~/.bash_aliases ./dotfiles/.bash_aliases
    _copy ~/.bash_profile ./dotfiles/.bash_profile

    #editorconfig
    _copy ~/.editorconfig ./dotfiles/.editorconfig
}

case "$1" in
    collect | c)
	collect
	;;
    deposit | d)
	deposit
	;;
    *)
	echo "usage: $0 {collect|deposit}"
	exit 1
	;;
esac
