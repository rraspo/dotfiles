#!/usr/bin/env bash

sudo apt update && sudo apt install -y zsh curl git
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

if [ ! -d ~/.dotfiles ]; then
  git clone https://github.com/rraspo/dotfiles.git ~/.dotfiles
else
  echo "~/.dotfiles already exists. Pulling latest changes."
  cd ~/.dotfiles && git pull
fi

if ! grep -q "# Source custom Zsh configurations" ~/.zshrc; then
  echo -e "\n# Source custom Zsh configurations\nfor file in ~/.dotfiles/zsh/*.zsh; do\n  [ -r \"\$file\" ] && source \"\$file\"\ndone" >> ~/.zshrc
fi

if [ "$SHELL" != "$(which zsh)" ]; then
  echo "Setting Zsh as the default shell..."
  chsh -s "$(which zsh)"
  echo "Default shell set to Zsh."
else
  echo "Zsh is already the default shell."
fi

. ~/.zshrc
echo "Setup complete!"
