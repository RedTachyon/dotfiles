#!/bin/bash
# ~/.dotfiles/scripts/setup_dotfiles.sh
# This script creates symlinks in your home directory for every item (files and directories)
# inside ~/.dotfiles/dotfiles. If a target already exists, you'll be prompted whether to overwrite it.
# Overwritten items are moved to a backup directory.

# Directories
SOURCE_DIR="$HOME/.dotfiles/dotfiles"
TARGET_HOME="$HOME"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d%H%M%S)"

echo "Starting symlink setup..."
echo "Source: $SOURCE_DIR"
echo "Target: $TARGET_HOME"
echo "Backup directory: $BACKUP_DIR"
echo

# Collect all items (files and directories) from the source directory into an array
mapfile -d '' items < <(find "$SOURCE_DIR" -mindepth 1 -print0)

# Iterate over each item explicitly using a for-loop.
for src_item in "${items[@]}"; do
    # Compute the relative path so that ~/.dotfiles/dotfiles/.vimrc becomes .vimrc
    rel_path="${src_item#$SOURCE_DIR/}"
    target_item="$TARGET_HOME/$rel_path"
    target_dir="$(dirname "$target_item")"
    
    echo "Processing: $rel_path"
    
    # Ensure the target directory exists.
    mkdir -p "$target_dir"
    
    # Check if the target item already exists.
    if [ -e "$target_item" ] || [ -L "$target_item" ]; then
        echo "WARNING: $target_item already exists."
        read -r -p "Overwrite $target_item? (y/n): " answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            mkdir -p "$BACKUP_DIR/$(dirname "$rel_path")"
            mv "$target_item" "$BACKUP_DIR/$rel_path"
            echo "Moved existing item to backup: $BACKUP_DIR/$rel_path"
        else
            echo "Skipping $target_item"
            continue
        fi
    fi
    
    # Create the symlink.
    ln -s "$src_item" "$target_item"
    echo "Created symlink: $target_item -> $src_item"
    echo
done

echo "Symlink setup complete."

