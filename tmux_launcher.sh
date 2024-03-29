#!/bin/bash

# Find directories in ~/c excluding ~/c itself, show in fzf, and store selected directory in variable
selected_dir=$(ls -td ~/c/*/ | cut -d'/' -f5 | fzf)

# If no directory is selected, exit the script
if [ -z "$selected_dir" ]; then
    echo "No directory selected. Exiting."
    exit 1
fi

# Change to the selected directory
cd ~/c/"$selected_dir"

# Create a new tmux session with the selected directory name and open nvim
tmux new-session -d -s "$selected_dir"

# Attach to the newly created tmux session
tmux attach-session -t "$selected_dir"
