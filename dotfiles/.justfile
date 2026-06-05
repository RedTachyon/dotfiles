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

beszel-agent-install:
    #!/usr/bin/env bash
    set -euo pipefail

    : "${BESZEL_KEY:?Set BESZEL_KEY to the public key shown by the Beszel hub.}"
    : "${BESZEL_TOKEN:?Set BESZEL_TOKEN to the agent token from the Beszel hub.}"

    hub_url="${BESZEL_HUB_URL:-http://hb:8090}"
    listen="${BESZEL_LISTEN:-45876}"

    if [[ "$(uname -s)" == "Darwin" ]]; then
        curl -fsSL https://get.beszel.dev/brew -o /tmp/install-agent.sh
        chmod +x /tmp/install-agent.sh
        /tmp/install-agent.sh -k "$BESZEL_KEY" -t "$BESZEL_TOKEN" -url "$hub_url" -p "$listen" || true
        uid="$(id -u)"
        plist="$HOME/Library/LaunchAgents/homebrew.mxcl.beszel-agent.plist"
        launchctl bootout "user/$uid" "$plist" 2>/dev/null || true
        launchctl bootstrap "user/$uid" "$plist"
        launchctl print "user/$uid/homebrew.mxcl.beszel-agent" >/dev/null
        exit 0
    fi

    if [[ "$(uname -s)" != "Linux" ]]; then
        echo "beszel-agent-install currently supports Linux/systemd and macOS/Homebrew hosts."
        exit 1
    fi

    arch="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/aarch64/arm64/' -e 's/armv6l/arm/' -e 's/armv7l/arm/')"
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' EXIT

    curl -fsSL "https://github.com/henrygd/beszel/releases/latest/download/beszel-agent_Linux_${arch}.tar.gz" \
        | tar -xz -C "$tmpdir" beszel-agent

    sudo install -m 0755 "$tmpdir/beszel-agent" /usr/local/bin/beszel-agent

    if ! id beszel >/dev/null 2>&1; then
        sudo useradd --system --home-dir /var/lib/beszel-agent --shell /usr/sbin/nologin beszel
    fi
    if getent group docker >/dev/null 2>&1; then
        sudo usermod -aG docker beszel
    fi

    sudo install -d -m 0750 -o root -g beszel /etc/beszel-agent
    sudo install -d -m 0750 -o beszel -g beszel /var/lib/beszel-agent

    printf 'LISTEN="%s"\nKEY="%s"\nTOKEN="%s"\nHUB_URL="%s"\n' \
        "$listen" "$BESZEL_KEY" "$BESZEL_TOKEN" "$hub_url" \
        | sudo tee /etc/beszel-agent/env >/dev/null
    sudo chmod 0640 /etc/beszel-agent/env
    sudo chown root:beszel /etc/beszel-agent/env

    printf '%s\n' \
        '[Unit]' \
        'Description=Beszel Agent' \
        'After=network-online.target' \
        'Wants=network-online.target' \
        '' \
        '[Service]' \
        'User=beszel' \
        'Group=beszel' \
        'EnvironmentFile=/etc/beszel-agent/env' \
        'ExecStart=/usr/local/bin/beszel-agent' \
        'Restart=on-failure' \
        'RestartSec=5' \
        'StateDirectory=beszel-agent' \
        '' \
        '[Install]' \
        'WantedBy=multi-user.target' \
        | sudo tee /etc/systemd/system/beszel-agent.service >/dev/null

    sudo systemctl daemon-reload
    sudo systemctl enable beszel-agent.service
    sudo systemctl restart beszel-agent.service
    sudo systemctl status --no-pager --lines=12 beszel-agent.service

beszel-agent-start:
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ "$(uname -s)" == "Darwin" ]]; then
        uid="$(id -u)"
        plist="$HOME/Library/LaunchAgents/homebrew.mxcl.beszel-agent.plist"
        launchctl bootstrap "user/$uid" "$plist" 2>/dev/null || true
    else
        sudo systemctl start beszel-agent.service
    fi

beszel-agent-stop:
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ "$(uname -s)" == "Darwin" ]]; then
        launchctl bootout "user/$(id -u)" "$HOME/Library/LaunchAgents/homebrew.mxcl.beszel-agent.plist" 2>/dev/null || true
    else
        sudo systemctl stop beszel-agent.service
    fi

beszel-agent-restart:
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ "$(uname -s)" == "Darwin" ]]; then
        uid="$(id -u)"
        plist="$HOME/Library/LaunchAgents/homebrew.mxcl.beszel-agent.plist"
        launchctl bootout "user/$uid" "$plist" 2>/dev/null || true
        launchctl bootstrap "user/$uid" "$plist"
    else
        sudo systemctl restart beszel-agent.service
    fi

beszel-agent-status:
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ "$(uname -s)" == "Darwin" ]]; then
        launchctl print "user/$(id -u)/homebrew.mxcl.beszel-agent"
    else
        sudo systemctl status --no-pager --lines=20 beszel-agent.service
    fi

beszel-agent-logs:
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ "$(uname -s)" == "Darwin" ]]; then
        tail -f "$HOME/.cache/beszel/beszel-agent.log"
    else
        sudo journalctl -u beszel-agent.service -f
    fi

beszel-agent-disable:
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ "$(uname -s)" == "Darwin" ]]; then
        launchctl bootout "user/$(id -u)" "$HOME/Library/LaunchAgents/homebrew.mxcl.beszel-agent.plist" 2>/dev/null || true
    else
        sudo systemctl disable --now beszel-agent.service
    fi

beszel-agent-uninstall:
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ "$(uname -s)" == "Darwin" ]]; then
        launchctl bootout "user/$(id -u)" "$HOME/Library/LaunchAgents/homebrew.mxcl.beszel-agent.plist" 2>/dev/null || true
        brew uninstall beszel-agent
        rm -f "$HOME/.config/beszel/beszel-agent.env"
    else
        sudo systemctl disable --now beszel-agent.service 2>/dev/null || true
        sudo rm -f /etc/systemd/system/beszel-agent.service
        sudo systemctl daemon-reload
        sudo rm -f /usr/local/bin/beszel-agent
        sudo rm -rf /etc/beszel-agent
    fi

alias passwordless-sudo-enable := sudo-nopass-enable

alias passwordless-sudo-disable := sudo-nopass-disable

alias passwordless-sudo-status := sudo-nopass-status
