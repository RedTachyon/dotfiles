#!/bin/bash
# ~/.dotfiles/scripts/setup_dotfiles.sh
# This script creates symlinks in your home directory for all files inside ~/.dotfiles/dotfiles.
# If a target file already exists, you'll be asked whether to overwrite it.
# Existing files that are overwritten are moved to a backup directory.

# Directory containing your dotfiles (inside your bare dotfiles repo)
SOURCE_DIR="$HOME/.dotfiles/dotfiles"
# Your home directory where the symlinks will be created
TARGET_HOME="$HOME"
# Create a backup directory with a timestamp in case files need to be moved
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d%H%M%S)"

echo "Starting symlink setup..."
echo "Source: $SOURCE_DIR"
echo "Target: $TARGET_HOME"
echo "Backup (if needed): $BACKUP_DIR"
echo

# Traverse all files (recursively) in the source directory.
find "$SOURCE_DIR" -type f | while read -r src_file; do
    # Compute the path relative to SOURCE_DIR.
    rel_path="${src_file#$SOURCE_DIR/}"
    target_file="$TARGET_HOME/$rel_path"
    target_dir="$(dirname "$target_file")"
    
    echo "Processing $rel_path ..."
    
    # Ensure the target directory exists.
    mkdir -p "$target_dir"
    
    # If a file (or symlink) already exists at the target, prompt for action.
    if [ -e "$target_file" ] || [ -L "$target_file" ]; then
        echo "WARNING: $target_file already exists."
        read -p "Overwrite $target_file? (y/n): " answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            # Create the backup directory for this file if it doesn't exist.
            mkdir -p "$BACKUP_DIR/$(dirname "$rel_path")"
            mv "$target_file" "$BACKUP_DIR/$rel_path"
            echo "Moved existing file to backup: $BACKUP_DIR/$rel_path"
        else
            echo "Skipping $target_file"
            continue
        fi
    fi

    # Create the symlink.
    ln -s "$src_file" "$target_file"
    echo "Created symlink: $target_file -> $src_file"
    echo
done

echo "Symlink setup complete."

