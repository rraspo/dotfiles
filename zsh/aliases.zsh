# Custom aliases and functions

# Navigation
alias ll='ls -lia'
alias rzsh='source ~/.zshrc'
alias ri='prevdir=\$(pwd) && cd ~/src/immich-app && sudo docker compose down && sudo docker compose up -d && cd \$prevdir'

# Alias to restart Immich server
alias ri="~/.dotfiles/scripts/restartimmich.sh"
