#!/bin/bash

# Find directories in ~/c excluding ~/c itself, show in fzf, and store selected directory in variable
selected_dir=$(ls -td ~/c/*/ | cut -d'/' -f5 | fzf)

# If no directory is selected, exit the script
if [ -z "$selected_dir" ]; then
    echo "No directory selected. Exiting."
    exit 1
fi

# Check if main.py exists in the selected directory
if [ -e ~/c/"$selected_dir"/main.py ]; then
    file_to_open="main.py"
else
    file_to_open=""
fi

# Change to the selected directory
cd ~/c/"$selected_dir"

# Create a new tmux session with the selected directory name and open nvim
tmux new-session -d -s "$selected_dir" "nvim $file_to_open"

# Split the pane horizontally
tmux split-window -h

# Select the left pane
tmux select-pane -L

# Attach to the newly created tmux session
tmux attach-session -t "$selected_dir"
