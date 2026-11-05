#!/bin/bash
#
# Creates .env from .env.example when it is missing, then fills the per-developer
# values that are still empty (WWWUSER, WWWGROUP, APP_KEY). Values that are already
# set are never overwritten. It does not start Docker or Sail.

set -euo pipefail

# Project root: two levels above scripts/sail/
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

if [ ! -f "${LOCAL_ENV}" ]; then
    cp "${ORIGINAL_ENV}" "${LOCAL_ENV}"
    echo "Created ${LOCAL_ENV} from ${ORIGINAL_ENV}"
fi

# Fill only the empty values: a value that is already set is never overwritten.
rewritten_env="$(mktemp)"

while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
        WWWUSER=)  line="WWWUSER=$(id -u)" ;;
        WWWGROUP=) line="WWWGROUP=$(id -g)" ;;
        APP_KEY=)  line="APP_KEY=base64:$(head -c 32 /dev/urandom | base64 | tr -d '\n')" ;;
    esac
    printf '%s\n' "$line" >> "${rewritten_env}"
done < "${LOCAL_ENV}"

cat "${rewritten_env}" > "${LOCAL_ENV}"
rm -f "${rewritten_env}"

echo "Done. Next steps are in the README."
