#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

source /usr/share/git/completion/git-prompt.sh

PROMPT_DIRTRIM=2

_ranger_string() {
    echo "${RANGER_LEVEL:+:r$RANGER_LEVEL}"
}

if [ -n "$SSH_CLIENT" ] && [ -z "$TMUX" ]; then
    if [[ "$TERM" =~ "256color" ]]; then
        PS1='[\e[0;33m\]\u@\h$(_ranger_string) \[\e[0;32m\]\w\[\e[0m\]]\[\e[0;34m\]$(__git_ps1 " (%s)")\[\e[0m\]\$ '
    else
        PS1='[\u@\h$(_ranger_string) \w]$(__git_ps1 " (%s)")\$ '
    fi
else
    if [[ "$TERM" =~ "256color" ]]; then
        PS1='[\u$(_ranger_string) \[\e[0;32m\]\w\[\e[0m\]]\[\e[0;34m\]$(__git_ps1 " (%s)")\[\e[0m\]\$ '
    else
        PS1='[\u$(_ranger_string) \w]$(__git_ps1 " (%s)")\$ '
    fi
fi

eval $(dircolors -b ~/.dircolors)

HISTSIZE=9000
HISTFILESIZE=$HISTSIZE
HISTCONTROL=ignorespace:ignoredups
HISTIGNORE="cd:clear:exit:ls:ll:la:hb *:pwsafe *:pw *:up *:p *"

# reedit a history substitution line if it failed
shopt -s histreedit
# edit a recalled history line before executing
shopt -s histverify
# append to history
shopt -s histappend

GPG_TTY=$(tty)
export GPG_TTY
export SDL_AUDIODRIVER=alsa
export SDL_VIDEO_FULLSCREEN_HEAD=1
export EDITOR=vim
export TERMCMD=urxvtc
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWUPSTREAM="auto"
set -o vi

shopt -s autocd             # change to named directory
shopt -s cdspell            # autocorrects cd misspellings
shopt -s checkwinsize       # update the value of LINES and COLUMNS after each command if altered
shopt -s cmdhist            # save multi-line commands in history as single line
shopt -s dotglob            # include dotfiles in pathname expansion
shopt -s expand_aliases     # expand aliases
shopt -s extglob            # enable extended pattern-matching features

# aliases
alias grep="grep --color=auto"
alias egrep="grep -E"

alias diff="colordiff"

alias ls="ls -h --color --group-directories-first"
alias ll="ls -l"
alias la="ll -a"

alias df="df -hT"
alias du='du -hs'

alias ..="cd .."

alias rss="newsbeuter"
alias less="/usr/share/vim/vim73/macros/less.sh"
alias pw="pwsafe"
alias Man="/usr/bin/man"
alias Less="/usr/bin/less"
alias pactree="pactree -c"
alias pacdeps="pactree -r"
alias lock='i3lock -c000000'
alias rsync='rsync -avhP'
alias sxiv='sxiv -dg +24+12'

# for the lazy
alias v='vim'
alias r='ranger'
alias c='clear'
alias s='rsync'
alias x='aunpack'
alias p='pw -p'
alias up='pw -up'
alias i='sxiv'
alias L='Less'
alias m='man'
alias M='Man'

if [ $UID -ne 0 ]; then
    alias sudo='sudo '
    alias reboot='sudo reboot'
    alias poweroff='sudo poweroff'
fi

# eval keychain if env-file exists
if [[ -f $HOME/.keychain/$HOSTNAME-sh ]]; then
    . $HOME/.keychain/$HOSTNAME-sh
fi

# a wrapper that displays the manpage in vim
man() {
    [[ $# -lt 1 ]] && echo "What manual page do you want?" && return

    /usr/bin/man -w "$@" &> /dev/null
    (( $? == 16 )) && echo "No such manual." && return

    vim -RMnc "Man $1 $2" -c "1bw" -c "set so=100" -c "map q :q<CR>" -c "set nomodifiable"
}

# eval keychain
sshchain() {
    eval $(keychain --eval --agents ssh -Q --quiet id_rsa)
}

# sprunge pastebin service
sprunge() {
    curl -F 'sprunge=<-' http://sprunge.us
}

# small rtcwake wrapper
wake() {
    [[ $# -lt 1 ]] && echo "No wake up date given." && return
    date="$@"
    unixd=$(date -d "$date" +%s) || return

    sudo rtcwake -t $unixd -m mem
}

