#!/bin/zsh
# Script to restart the Immich Docker Compose setup and return to the original directory

prevdir=$(pwd)  # Save the current directory
cd ~/src/immich-app || exit 1  # Change to the Immich directory or exit
sudo docker compose down  # Stop the containers
sudo docker compose up -d  # Start the containers
cd "$prevdir" || exit 1  # Return to the previous directory
