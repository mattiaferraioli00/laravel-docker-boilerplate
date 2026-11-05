#!/bin/bash
#
# Creates .env from .env.example and fills the per-developer values
# (WWWUSER, WWWGROUP, APP_KEY). It does not start Docker or Sail.

set -euo pipefail

# Project root: two levels above scripts/docker/
cd "$(dirname "$0")/../.."

readonly ORIGINAL_ENV=".env.example"
readonly LOCAL_ENV=".env"

if [ "$(id -u)" -eq 0 ]; then
    echo "Do not run this script as root or with sudo." >&2
    exit 1
fi

if [ ! -f "${ORIGINAL_ENV}" ]; then
    echo "${ORIGINAL_ENV} not found." >&2
    exit 1
fi

if [ -f "${LOCAL_ENV}" ]; then
    echo "${LOCAL_ENV} already exists, nothing to do."
    exit 0
fi

echo "Creating ${LOCAL_ENV}"

while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
        WWWUSER=*)  line="WWWUSER=$(id -u)" ;;
        WWWGROUP=*) line="WWWGROUP=$(id -g)" ;;
        APP_KEY=*)  line="APP_KEY=base64:$(head -c 32 /dev/urandom | base64 | tr -d '\n')" ;;
    esac
    printf '%s\n' "$line" >> "${LOCAL_ENV}"
done < "${ORIGINAL_ENV}"

echo "Done. Next steps are in the README."
