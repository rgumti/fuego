#!/bin/bash
#Author: rgumti
#Description: Network not steadily available to mount nfs share
#this script will wait for network to be up before mounting

set -eu

logger -t "$(basename "$0")" "Waiting for fefe.viva.local"
while ! ping -c 1 -n -w 1 fefe.viva.local &> /dev/null
do
    printf "%c" "."
done

logger -t "$(basename "$0")" "fefe.viva.local is back online...attempting to mount share"

/usr/bin/mount fefe:/volume1/net

if grep -qs '/volume1/net' /proc/mounts; then
    logger -t "$(basename "$0")" "NFS fefe Share Mounted"
    exit 0
else
    logger -t "$(basename "$0")" "NFS fefe Share NOT Mounted"
    exit 1
fi
