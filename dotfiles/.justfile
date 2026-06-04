set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

sudo-nopass-enable:
    toggle-passwordless-sudo enable

sudo-nopass-disable:
    toggle-passwordless-sudo disable

sudo-nopass-status:
    toggle-passwordless-sudo status

dot-update:
    #!/usr/bin/env bash
    set -euo pipefail

    cd "$HOME/.dotfiles"
    old_head="$(git rev-parse HEAD)"

    git pull --ff-only

    new_head="$(git rev-parse HEAD)"
    if [[ "$old_head" == "$new_head" ]]; then
        echo "Dotfiles are already up to date."
        exit 0
    fi

    python3 scripts/setup_dotfiles.py

alias passwordless-sudo-enable := sudo-nopass-enable

alias passwordless-sudo-disable := sudo-nopass-disable

alias passwordless-sudo-status := sudo-nopass-status
