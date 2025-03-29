#!/usr/bin/env python3
import os
import shutil
from datetime import datetime

def main():
    home = os.path.expanduser("~")
    source_dir = os.path.join(home, ".dotfiles", "dotfiles")
    # Create a backup directory with a timestamp for backups
    backup_dir = os.path.join(home, "dotfiles_backup_" + datetime.now().strftime("%Y%m%d%H%M%S"))

    print("Starting symlink setup...")
    print("Source: ", source_dir)
    print("Target: ", home)
    print("Backup directory (if needed): ", backup_dir)
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

            # If the target exists (file or symlink), prompt for action.
            if os.path.lexists(target_file):
                print("WARNING: {} already exists.".format(target_file))
                answer = input("Overwrite {}? (y = remove, b = backup and remove, n = skip): ".format(target_file))
                answer = answer.lower().strip()
                if answer == "n":
                    print("Skipping", target_file)
                    continue
                elif answer == "b":
                    # Ensure backup directory for this file exists
                    backup_target = os.path.join(backup_dir, rel_path)
                    backup_target_dir = os.path.dirname(backup_target)
                    if not os.path.exists(backup_target_dir):
                        os.makedirs(backup_target_dir, exist_ok=True)
                    try:
                        shutil.move(target_file, backup_target)
                        print("Moved existing item to backup: {}".format(backup_target))
                    except Exception as e:
                        print("Error backing up {}: {}".format(target_file, e))
                        continue
                elif answer == "y":
                    try:
                        if os.path.islink(target_file) or os.path.isfile(target_file):
                            os.remove(target_file)
                        else:
                            # For directories, use rmtree
                            shutil.rmtree(target_file)
                        print("Removed existing item: {}".format(target_file))
                    except Exception as e:
                        print("Error removing {}: {}".format(target_file, e))
                        continue
                else:
                    print("Invalid response. Skipping", target_file)
                    continue

            # Create the symlink.
            try:
                os.symlink(source_file, target_file)
                print("Created symlink: {} -> {}".format(target_file, source_file))
            except Exception as e:
                print("Error creating symlink for {}: {}".format(target_file, e))
            print()

    print("Symlink setup complete.")

if __name__ == "__main__":
    main()

