#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
[[ -r "/usr/share/z/z.sh" ]] && source /usr/share/z/z.sh
export EDITOR=nvim
alias ls='ls --color=auto'
alias xclip='xclip -selection c'
PS1='[\u@\h \W]\$ '
alias telegram='~/Downloads/Telegram/Telegram & disown; exit'
export HISTSIZE=""
export HISTFILESIZE=""
HISTTIMEFORMAT="%d/%m/%Y %T "  # for e.g. “29/02/1999 23:59:59”
export WORKON_HOME=~/.virtualenvs

#pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export GOPATH=$HOME/go

export PATH="~/.local/bin:$PATH"
