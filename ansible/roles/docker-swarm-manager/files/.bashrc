# HGI Docker Swarm Manager

# This uses the environment variable LC_HGI_USER to determine
# the user interacting with this, and log their history to
# ~/.hgi_history

export TZ='Europe/London'

trap '' 2
while [[ $LC_HGI_USER == "" ]]; do
	read -p "HGI User (i.e. mg38): " LC_HGI_USER
done
trap 2

hgi_history () {
	history -w
	echo -e "$LC_HGI_USER\t$(date)\t$(history 1)" >> ~/.hgi_history
}

PS1='$(hgi_history)\[\033[01;31m\]$LC_HGI_USER \[\033[01;32m\]swarm \[\033[01;34m\]\w \[\033[01;00m\]\$ '

alias ls='ls --color=auto'
alias grep='grep --color=auto'