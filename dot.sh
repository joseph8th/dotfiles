#!/usr/bin/env bash
#
# dot.sh
# Collect or Deposit dotfiles and eval arbitrary bash
# usage: dot.sh {collect|deposit}
#
# author: Joseph Edwards VIII
# email: jedwards8th at gmail.com

# Coupla globals make life simple
SUBCMD=
declare -a DOTFILE

_die_nice() {
    echo "$1"
    exit 1
}

_fail_n_die() {
    [ $1 -eq 0 ] && return 0
    _die_nice "$2"
}

_do_cmd() {
    # Run an arbitrary bit of bash
    local cmd="${@}"
    read -p "Really eval bash '$cmd' ? {yes|no}: " dorun
    [[ "$dorun" != "yes" ]] \
	&& echo "==> Skipping command" \
	&& return 1

    #Do it!
    eval $cmd
}

_scrap() {
    local src="$1"
    local base=$(basename "$src")
    local mv_to="./tmp/${base}"

    # Move files to local ./tmp always overwriting.
    [[ ! -e "$src" ]] && return 1
    [[ -e "$mv_to" ]] && rm -rf "$mv_to"

    echo "==> Moving $src -> $mv_to"
    mv -f "$src" "$mv_to"
}

_copy() {
    local src="$1"
    local dst="$2"
    [[ ! -e "$src" ]] \
	&& echo "==> Source file not found. Skipping $src" \
	&& return 1

    # Destination exists? Decide what to do...
    if [[ -e "$dst" ]]; then
	read -p "Overwrite $dst ? REALLY? {yes|no}: " doow
	[[ "$doow" != "yes" ]] \
	    && echo "==> Skipping $src" \
	    && return 1

	# Try to scrap the dest file/dir. Should work but JIC...
	_scrap "$dst"
	[ $? -gt 0 ] \
	    && echo "==> Unable to scrap $dst! Skipping $src" \
	    && return 1
    fi

    # No destination now! So no need to use --force
    [[ -d "$src" ]] \
	&& cp -r "$src" "$dst" \
	    || cp "$src" "$dst"
}

_parse_args() {
    # Set the subcommand
    case "$1" in
	collect | -c) SUBCMD=collect ;;
	deposit | -d) SUBCMD=deposit ;;
	*) _die_nice "usage: $0 {collect|deposit}" ;;
    esac
}

_read_dotfile() {
    # Need a Dotfile ... either 'Dotfile' or 'dotfile' but Dotfile preferred
    local dotfile=
    for f in [dD]otfile; do
	[[ "$f" == "Dotfile" ]] \
	    && local dotfile="$f" \
	    && break
	local dotfile="$f"
    done

    # validate
    [[ -z "$dotfile" ]] \
	&& echo "Dotfile not found!" \
	&& return 1

    # Read Dotfile into array ... skipping comments and empties
    readarray -t dotfile_arr < "$dotfile"
    local idx=0
    for f in "${dotfile_arr[@]}"; do
	[[ "${f:0:1}" == "#" || -z "${f:0:1}" ]] && continue
	DOTFILE[$idx]="$f"
	((idx++))
    done

    # validate
    [[ -z $DOTFILE ]] \
	&& echo "Empty Dotfile! Add some dotfiles .??*" \
	&& return 1

    return 0
}

_init() {
    # Init the local dirs
    if [[ ! -e ./dotfiles ]]; then
	mkdir ./dotfiles
	_fail_n_die $? "Failed mkdir ./dotfiles"
    fi
    if [[ ! -e ./tmp ]]; then
	mkdir ./tmp
	_fail_n_die $? "Failed mkdir ./tmp"
    fi

    # Read the Dotfile
    _read_dotfile
    _fail_n_die $? "Unable to read Dotfile"
}

_do_subcmd() {
    # Pretty simple... collect-from XOR deposit-to $HOME
    if [[ "$SUBCMD" == "collect" ]]; then
	echo "Collecting dotfiles ..."
	local token=C
	local src_dir=$HOME
	local dst_dir=./dotfiles
    elif [[ "$SUBCMD" == "deposit" ]]; then
	echo "Depositing dotfiles ..."
	local token=D
	local src_dir=./dotfiles
	local dst_dir=$HOME
    else
	_die_nice "Unrecognized subcommand: $SUBCMD"
    fi

    # Process the Dotfile watching for eval markup '$[CD]'
    for elt in "${DOTFILE[@]}"; do

	# Not a eval cmd markup? Then just copy and continue
	if [[ "${elt:0:1}" != "$" ]]; then
	    _copy "${src_dir}/${elt}" "${dst_dir}/${elt}"
	    continue
	fi

	# Otherwise an eval... sure... why not? Need '$ ' or '$[CD] ' with space.
	[[ "${elt:1:1}" == " " ]] && _do_cmd "${elt:2}"
	[[ "${elt:1:1}" == "$token" ]] && _do_cmd "${elt:3}"
    done
}

main() {
    _parse_args "$1"
    _init
    _do_subcmd
}

main "${@}"
