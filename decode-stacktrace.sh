#!/bin/bash

cd "$(dirname "${0}")"

VOLUME_NAME="casesensitive"
REPO_PATH="/Volumes/${VOLUME_NAME}/linux"
DOCKER_IMAGE="ubuntu:latest"
WORKDIR="/linux"

ssh-keygen -R rpi400.local
scp  -o StrictHostKeyChecking=no rpi400.local:dmesg.log dmesg.log.temp

LAST_CALL_TRACE=$(grep -n 'Call trace' dmesg.log | tail -n 1 | cut -d: -f1)
head -$((LAST_CALL_TRACE + 100)) dmesg.log.temp > dmesg.log
rm dmesg.log.temp

docker run -v "$(pwd):/notes" -v "${REPO_PATH}:${WORKDIR}" -w "${WORKDIR}" -ti --rm "$DOCKER_IMAGE" bash -c '
set -xveu
set -o pipefail
apt-get update
apt-get upgrade -y
apt install -y git bc bison flex libssl-dev make libc6-dev libncurses5-dev crossbuild-essential-arm64
export KERNEL=kernel8
cat /notes/dmesg.log | scripts/decode_stacktrace.sh vmlinux | tee /notes/dmesg.log.decoded
'
