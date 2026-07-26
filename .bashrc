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
shopt -s histappend  # append to the history file instead of overwriting it,
                     # so concurrent shells (tmux panes) don't clobber each other
HISTCONTROL=ignoredups
export WORKON_HOME=~/.virtualenvs

# pyenv (only if installed on this machine)
export PYENV_ROOT="$HOME/.pyenv"
if [ -x "$PYENV_ROOT/bin/pyenv" ]; then
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

export GOPATH=$HOME/go

# poetry
export PATH="$HOME/.poetry/bin:$PATH"

if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
    GIT_PROMPT_ONLY_IN_REPO=1
    GIT_PROMPT_THEME=Default_Arch
    source $HOME/.bash-git-prompt/gitprompt.sh
fi
