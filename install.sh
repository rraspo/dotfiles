#!/usr/bin/env bash

sudo apt update && sudo apt install -y zsh curl git
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

if [ ! -d ~/.dotfiles ]; then
  git clone https://github.com/your-username/dotfiles.git ~/.dotfiles
else
  echo "~/.dotfiles already exists. Pulling latest changes."
  cd ~/.dotfiles && git pull
fi

ln -sf ~/.dotfiles/zsh/aliases.zsh ~/.oh-my-zsh/custom/aliases.zsh
ln -sf ~/.dotfiles/zsh/prompt.zsh ~/.oh-my-zsh/custom/prompt.zsh

if [[ "$SHELL" != "$(which zsh)" ]]; then
  echo "Setting Zsh as the default shell..."
  chsh -s "$(which zsh)"
  echo "Default shell set to Zsh."
else
  echo "Zsh is already the default shell."
fi

source ~/.zshrc
echo "Setup complete!"
