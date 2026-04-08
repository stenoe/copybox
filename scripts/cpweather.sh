##!/usr/bin/env bash
set -euo pipefail

sftp -i "/root/.ssh/id_rsa" -b /home/transfer/copyWeatherToWebServer smear@smear.emu.ee

REMOTE_USER="smear"
REMOTE_HOST="smear.emu.ee"

LOCAL_DIR="/home/transfer/DataLog"
KEY_FILE="/root/.ssh/id_rsa"
KNOWN_HOSTS="/root/.ssh/known_hosts"

# sftp \
#   -i "${KEY_FILE}" \
#   -o IdentitiesOnly=yes \
#   -o UserKnownHostsFile="${KNOWN_HOSTS}" \
#   -o StrictHostKeyChecking=yes \
#   -b /home/transfer/copyWeatherToWebServer \
#   "${REMOTE_USER}@${REMOTE_HOST}"

#   <<EOF
# cd ${REMOTE_DIR}
# put ${LOCAL_DIR}/*
# bye
# EOF
