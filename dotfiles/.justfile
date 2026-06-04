set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

passwordless-sudo-enable:
    toggle-passwordless-sudo enable

passwordless-sudo-disable:
    toggle-passwordless-sudo disable

passwordless-sudo-status:
    toggle-passwordless-sudo status

alias sudo-nopass-enable := passwordless-sudo-enable

alias sudo-nopass-disable := passwordless-sudo-disable

alias sudo-nopass-status := passwordless-sudo-status
