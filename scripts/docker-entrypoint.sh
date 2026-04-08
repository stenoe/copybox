#!/usr/bin/env bash
set -euo pipefail

# eval "$(ssh-agent -s)"

# if [[ -f "${HOME}/.ssh/id_rsa" ]]; then
#     ssh-add "${HOME}/.ssh/id_rsa"
# fi

# export SSH_KNOWN_HOSTS="${HOME}/.ssh/known_hosts"
# export SSH_OPTIONS="-o UserKnownHostsFile=${SSH_KNOWN_HOSTS} -o StrictHostKeyChecking=yes"

exec "$@"