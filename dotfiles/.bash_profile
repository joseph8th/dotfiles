# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

# Prompt options
PROMPT_WHITE="\[\033[1;37m\]"
PROMPT_GREEN="\[\033[01;32m\]"
PROMPT_CYAN="\[\033[01;36m\]"
PROMPT_GRAY="\[\033[0;37m\]"
PROMPT_BLUE="\[\033[0;34m\]"
PROMPT_PREFIX_LONG="${PROMPT_GREEN}\u${PROMPT_CYAN}@${PROMPT_BLUE}\h "
PROMPT_PREFIX_SHORT="${PROMPT_GREEN}\u${PROMPT_CYAN}:"

PS1_XS="PS1='\n${debian_chroot:+($debian_chroot)}${PROMPT_PREFIX_SHORT}${PROMPT_CYAN}\W${PROMPT_GRAY}:\$ '"
PS1_S="PS1='\n${debian_chroot:+($debian_chroot)}${PROMPT_PREFIX_SHORT}${PROMPT_CYAN}\W${PROMPT_GRAY} \$ '"
PS1_L="PS1='\n${debian_chroot:+($debian_chroot)}${PROMPT_PREFIX_SHORT}${PROMPT_CYAN}\w${PROMPT_GRAY} \$ '"
PS1_XL="PS1='\n${debian_chroot:+($debian_chroot)}${PROMPT_PREFIX_SHORT}${PROMPT_CYAN}\w${PROMPT_GRAY}
\$ '"

alias ps1=$PS1
alias ps1_s=$PS1_S
alias ps1_l=$PS1_L
alias ps1_xs=$PS1_XS
alias ps1_xl=$PS1_XL

if [ "$color_prompt" = yes ]; then
    #PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    ps1_l
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

if [ -x /usr/bin/mint-fortune ]; then
     /usr/bin/mint-fortune
fi

# Exports.

export ALTERNATE_EDITOR=""
export EDITOR="emacsclient -t"
export VISUAL="emacsclient -c -a emacs"
#export JAVA_HOME="/usr/lib/jvm/java-8-oracle"

# JEdwards convenience functions

alias gitlog="git log --graph --decorate --pretty=oneline --abbrev-commit"
alias glda='git log --pretty="%h [%cd] [%cn] %s" --date=short'
alias glg='git log --decorate --oneline --pretty="%h [%cd] [%cn] %s" --date=short | grep'

function glgp {
    git log --oneline | grep $1 | awk '{ print $1 }'
}

function update_configs {
    for f in $1/*.default; do
	echo cp $f `basename $f .default`
	cp $f `basename $f .default`
    done
}

function jcurl {
    curl "$@" | python -m json.tool | pygmentize -l json
}

# Minify CSS or JS files in place
function minify {
    local yui=$HOME/yuicompressor/yuicompressor-2.4.8.jar
    [[ ! -e "$yui" ]] \
	&& echo "Compressor not found: '$yui'" \
	&& return

    [[ -z $1 ]] \
	&& echo "Missing filename" \
	&& return

    local filepath="$1"
    [[ ! -e "$filepath" ]] \
	&& echo "File not found: '$filepath'" \
	&& return

    local dir=$(dirname "$filepath")
    local filename=$(basename "$filepath")
    local ext="${filename##*.}"
    local base="${filename%.*}"

    [[ "$ext" != "css" && "$ext" != "js" ]] \
	&& echo "Unknown extension type: '$ext'" \
	&& return

    local minfile="${base}.min.${ext}"
    echo "Minifying '$filename' => '$minfile' ..."
    java -jar "$yui" --type $ext -o "${dir}/${minfile}" "$filepath"
}

# toggle sound on push in git repos
function pushnoise {
    local cmd=
    local prepush=./.git/hooks/pre-push

    [[ ! -e .git ]] \
	&& echo "No .git found" \
	&& return

    if [[ ! -z $1 ]]; then
	cmd=$1
	[[ "$cmd" != "on" && "$cmd" != "off" ]] \
	    && echo "Command '$cmd' not recognized" \
	    && return 1
    else
	[[ -e $prepush ]] && cmd="off" || cmd="on"
    fi

    if [[ "$cmd" == "off" ]]; then
	[[ -e $prepush ]] && mv -f $prepush ${prepush}.sample
	echo "pushnoise: OFF"
    elif [[ "$cmd" == "on" ]]; then
	[[ ! -e $prepush ]] && cp ${prepush}.sample $prepush
	echo "pushnoise: ON"
    fi
}

# If $HOME/bin exists then add it to $PATH
#if [ -e ~/bin ]; then
#    export PATH="$PATH:$HOME/bin"
#fi


#export PATH="$HOME/.pyenv/bin:$PATH"
#eval "$(pyenv init -)"
#eval "$(pyenv virtualenv-init -)"


######################################################################
## Automatically loaded after this ...                              ##
######################################################################
