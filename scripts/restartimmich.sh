#!/bin/zsh
# Script to restart the Immich Docker Compose setup and return to the original directory

prevdir=$(pwd)
cd ~/src/immich-app || exit 1
sudo docker compose down
sudo docker compose up -d
cd "$prevdir" || exit 1
