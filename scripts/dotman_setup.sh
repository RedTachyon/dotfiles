#!/bin/bash
# dotman_setup.sh
# This script installs a persistent alias for dotman in both Bash and Fish shells.

# Define the locations of your shell config files.
BASHRC="$HOME/.bashrc"
FISH_CONFIG="$HOME/.config/fish/config.fish"

# The alias line for Bash.
BASH_ALIAS="alias dotman='git --git-dir=\$HOME/.dotman/ --work-tree=\$HOME'"

# Append the alias to .bashrc if it isn’t already present.
if ! grep -Fxq "$BASH_ALIAS" "$BASHRC"; then
    echo "$BASH_ALIAS" >> "$BASHRC"
    echo "Added dotman alias to $BASHRC"
else
    echo "dotman alias already exists in $BASHRC"
fi

# For Fish, define a function. Note that Fish does not use the same alias syntax.
FISH_FUNCTION="function dotman; git --git-dir=\$HOME/.dotman/ --work-tree=\$HOME \$argv; end"

# Ensure the Fish config directory exists.
mkdir -p "$(dirname "$FISH_CONFIG")"

# Append the function definition to the Fish config if it isn’t already defined.
if ! grep -Fq "function dotman;" "$FISH_CONFIG"; then
    echo "$FISH_FUNCTION" >> "$FISH_CONFIG"
    echo "Added dotman function to $FISH_CONFIG"
else
    echo "dotman function already exists in $FISH_CONFIG"
fi

echo "dotman alias/function installation complete. Please reload your shell or source your config files."
