#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
export EDITOR=vim
export TERM=xterm
alias ls='ls --color=auto'
alias xclip='xclip -selection c'
PS1='[\u@\h \W]\$ '
alias telegram='/home/lucas/Downloads/Telegram/Telegram & disown; exit'
VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
export HISTSIZE=""
export HISTFILESIZE=""
export WORKON_HOME=~/.virtualenvs
source /usr/bin/virtualenvwrapper.sh
export DEVKITPRO=/opt/devkitPro
export DEVKITARM=$DEVKITPRO/devkitARM
export PATH=$PATH:$DEVKITARM/bin
