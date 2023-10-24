#
# ~/.bashrc
#
# If not running interactively, don't do anything
[[ $- != *i* ]] && return
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias neofetch='neofetch --source ~/.config/neofetch/loli'
PS1='[\u@\h \W]\$ '
neofetch
#source /usr/share/nvm/init-nvm.sh
