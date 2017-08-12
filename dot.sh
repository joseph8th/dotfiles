#!/usr/bin/env bash

_copy() {
    local src="$1"
    local dst="$2"
    [[ ! -e "$src" ]] && echo "Source file not found: $src" && return 1
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

_do_cmd() {
    local cmd="${@}"
    read -p "Really eval bash '$cmd' ? {yes|no}: " dorun
    [[ "$dorun" != "yes" ]] && echo "Skipping command" && return 1
    eval $cmd
}

deposit() {
    # Process the Dotfile
    for elt in "${@}"; do
	# Run commands specified by leading '$ ' or '$C '
	if [[ "${elt:0:1}" == "$" ]]; then
	    [[ "${elt:1:1}" == " " ]] && _do_cmd "${elt:2}"
	    [[ "${elt:1:1}" == "D" ]] && _do_cmd "${elt:3}"
	    continue
	fi

	# Otherwise copy to $HOME
	_copy "./dotfiles/${elt}" "$HOME/${elt}"
    done
}

collect() {
    # Make sure dotfiles directory exists
    [[ ! -e ./dotfiles ]] && mkdir ./dotfiles

    # Process the Dotfile
    for elt in "${@}"; do
	# Run commands specified by leading '$ ' or '$C '
	if [[ "${elt:0:1}" == "$" ]]; then
	    [[ "${elt:1:1}" == " " ]] && echo "all subcmd..." && _do_cmd "${elt:2}"
	    [[ "${elt:1:1}" == "C" ]] && echo "collect subcmd..." && _do_cmd "${elt:3}"
	    continue
	fi

	# Otherwise copy to ./dotfiles
	_copy "$HOME/${elt}" "./dotfiles/${elt}"
    done
}

main() {
    # Need a Dotfile ... either 'Dotfile' or 'dotfile' but Dotfile preferred
    local dotfile=
    for f in [dD]otfile; do
	[[ "$f" == "Dotfile" ]] && dotfile="$f" && break
	dotfile="$f"
    done

    # No Dotfile? Bye!
    [[ -z "$dotfile" ]] && echo "'Dotfile' not found!" && exit 1

    # Set the subcommand
    local subcmd=
    case "$1" in
	collect | -c)
	    subcmd=collect
	    ;;
	deposit | -d)
	    subcmd=deposit
	    ;;
	*)
	    echo "usage: $0 {collect|deposit}"
	    exit 1
	    ;;
    esac

    # Read Dotfile into array
    local dotfile_arr=
    readarray -t dotfile_arr < "$dotfile"

    local dotfiles=
    local idx=0
    for f in "${dotfile_arr[@]}"; do
	[[ "${f:0:1}" == "#" || -z "${f:0:1}" ]] && continue
	dotfiles[$idx]="$f"
	((idx++))
    done

    # Run subcommand
    $subcmd "${dotfiles[@]}"
}

main "${@}"
