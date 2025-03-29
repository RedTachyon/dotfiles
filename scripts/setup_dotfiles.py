#!/usr/bin/env python3
import os
import shutil
from datetime import datetime

def main():
    home = os.path.expanduser("~")
    source_dir = os.path.join(home, ".dotfiles", "dotfiles")
    # Create a backup directory with a timestamp
    backup_dir = os.path.join(home, "dotfiles_backup_" + datetime.now().strftime("%Y%m%d%H%M%S"))

    print("Starting symlink setup...")
    print("Source: ", source_dir)
    print("Target: ", home)
    print("Backup directory: ", backup_dir)
    print()

    # Walk through every file in the source directory
    for root, _, files in os.walk(source_dir):
        for file in files:
            source_file = os.path.join(root, file)
            # Calculate the relative path (e.g., ".vimrc")
            rel_path = os.path.relpath(source_file, source_dir)
            target_file = os.path.join(home, rel_path)
            target_dir = os.path.dirname(target_file)

            print("Processing:", rel_path)
            # Ensure the target directory exists
            if not os.path.exists(target_dir):
                os.makedirs(target_dir, exist_ok=True)

            # If the target exists (file or symlink), prompt for overwrite
            if os.path.lexists(target_file):
                print("WARNING: {} already exists.".format(target_file))
                answer = input("Overwrite {}? (y/n): ".format(target_file))
                if answer.lower().startswith("y"):
                    # Make sure backup directory for this file exists
                    backup_target = os.path.join(backup_dir, rel_path)
                    backup_target_dir = os.path.dirname(backup_target)
                    if not os.path.exists(backup_target_dir):
                        os.makedirs(backup_target_dir, exist_ok=True)
                    shutil.move(target_file, backup_target)
                    print("Moved existing item to backup: {}".format(backup_target))
                else:
                    print("Skipping", target_file)
                    continue

            # Create the symlink
            try:
                os.symlink(source_file, target_file)
                print("Created symlink: {} -> {}".format(target_file, source_file))
            except Exception as e:
                print("Error creating symlink for {}: {}".format(target_file, e))
            print()

    print("Symlink setup complete.")

if __name__ == "__main__":
    main()

