# vim: set ft=sh:
# ~/.bash_profile
#

# User specific aliases and functions
PATH="$HOME/bin:$PATH"
FIGNORE=$FIGNORE:.o:.class

[[ -f ~/.bashrc ]] && . ~/.bashrc
[[ -f ~/.profile ]] && . ~/.profile

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    echo ""
    fortune -aec
    echo ""
    pal -r 1-2
    echo ""
    echo "Greetings, $USER."
    read -erp "Start X? [Y/n]: "
    case $REPLY in
        [Nn])
            echo -e "You stay in the void.\n"
            ;;
        *)
            exec nohup startx > .xlog & vlock
            ;;
    esac
fi
