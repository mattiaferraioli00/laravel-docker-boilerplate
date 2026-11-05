#!/bin/bash
#
# Re-publishes the Laravel Sail files and re-applies the boilerplate's changes.
#
# Run it after updating laravel/sail to pick up the fixes in Sail's Dockerfiles.
# It overwrites docker/ and ./sail with the files shipped by Sail, then:
#   - removes the PHP runtimes and database scripts the boilerplate does not use
#   - adds the COMPOSER_VERSION build argument to every Dockerfile
# It stops with an error when a change cannot be applied, which means Sail's
# Dockerfile changed and this script needs to be updated.
#
# compose.yaml is never touched.
# Requires the containers to be running (./sail up -d).

set -euo pipefail

# Project root: two levels above scripts/sail/
cd "$(dirname "$0")/../.."

if [ ! -f artisan ]; then
    echo "Project root not found: run scripts/sail/publish.sh from a Laravel project." >&2
    exit 1
fi

readonly SUPPORTED_PHP_VERSIONS="8.3 8.4 8.5"
readonly UNUSED_DATABASE_DIRECTORIES="docker/mariadb docker/pgsql"
readonly APP_SERVICE_NAME="app"
readonly COMPOSER_VERSION_MARKER="# boilerplate: COMPOSER_VERSION build argument (scripts/sail/publish.sh)"

# Sail from vendor/: the script overwrites ./sail, which must not be the one running.
readonly VENDOR_SAIL="./vendor/bin/sail"

#
# Prints an error message and stops the script.
#
# Arguments:
#   $1 - the message
#
fail() {
    printf 'Error: %s\n' "$1" >&2
    exit 1
}

#
# Rewrites a file in place with the output of a command, preserving its permissions.
#
# Arguments:
#   $1 - the file
#   $@ - the command that reads the file on stdin and prints the new content
#
rewrite_file() {
    local target_file="$1"
    local rewritten_file
    shift

    rewritten_file="$(mktemp)"
    "$@" < "$target_file" > "$rewritten_file"
    cat "$rewritten_file" > "$target_file"
    rm -f "$rewritten_file"
}

#
# Stops the script when the application container is not running.
#
ensure_containers_are_running() {
    [ -x "$VENDOR_SAIL" ] || fail "${VENDOR_SAIL} not found: install the Composer dependencies first."

    if ! "$VENDOR_SAIL" ps --status running --services 2>/dev/null | grep -qx "$APP_SERVICE_NAME"; then
        fail "the ${APP_SERVICE_NAME} container is not running: start it with ./sail up -d"
    fi
}

#
# Publishes Sail's Dockerfiles, database scripts and sail binary, overwriting the existing files.
#
publish_sail_files() {
    "$VENDOR_SAIL" artisan vendor:publish --tag=sail-docker --force
    "$VENDOR_SAIL" artisan vendor:publish --tag=sail-database --force
    "$VENDOR_SAIL" artisan vendor:publish --tag=sail-bin --force
    chmod +x sail
}

#
# Removes the PHP runtimes outside SUPPORTED_PHP_VERSIONS and the unused database scripts.
#
remove_unused_directories() {
    local runtime_directory
    local runtime_version
    local database_directory

    for runtime_directory in docker/[0-9]*.[0-9]*; do
        [ -d "$runtime_directory" ] || continue
        runtime_version="${runtime_directory#docker/}"

        if [[ " ${SUPPORTED_PHP_VERSIONS} " != *" ${runtime_version} "* ]]; then
            rm -rf "$runtime_directory"
            printf '  removed %s\n' "$runtime_directory"
        fi
    done

    for database_directory in $UNUSED_DATABASE_DIRECTORIES; do
        if [ -d "$database_directory" ]; then
            rm -rf "$database_directory"
            printf '  removed %s\n' "$database_directory"
        fi
    done
}

#
# Adds the COMPOSER_VERSION build argument to a Dockerfile and passes it to the Composer installer.
# An empty COMPOSER_VERSION keeps installing the latest Composer release.
#
# Arguments:
#   $1 - the Dockerfile
#
add_composer_version_argument() {
    local dockerfile="$1"

    if ! grep -qF "ARG COMPOSER_VERSION" "$dockerfile"; then
        rewrite_file "$dockerfile" awk -v marker="$COMPOSER_VERSION_MARKER" '
            { print }
            /^ARG PHP_EXTENSIONS=/ { print marker; print "ARG COMPOSER_VERSION=\"\"" }
        '
    fi

    if ! grep -qF '${COMPOSER_VERSION:+' "$dockerfile"; then
        rewrite_file "$dockerfile" awk '
            /getcomposer\.org\/installer/ {
                sub(/--filename=composer/, "--filename=composer ${COMPOSER_VERSION:+--version=$COMPOSER_VERSION}")
            }
            { print }
        '
    fi

    grep -qF "ARG COMPOSER_VERSION" "$dockerfile" \
        || fail "${dockerfile}: 'ARG PHP_EXTENSIONS=' not found, update add_composer_version_argument()."
    grep -qF -- '--version=$COMPOSER_VERSION' "$dockerfile" \
        || fail "${dockerfile}: Composer installer line not found, update add_composer_version_argument()."

    printf '  patched %s\n' "$dockerfile"
}

ensure_containers_are_running

echo "Publishing Sail files"
publish_sail_files

echo "Removing unused runtimes and database scripts"
remove_unused_directories

echo "Applying boilerplate changes"
for php_version in $SUPPORTED_PHP_VERSIONS; do
    [ -f "docker/${php_version}/Dockerfile" ] \
        || fail "docker/${php_version}/Dockerfile not published: Sail dropped PHP ${php_version}, update SUPPORTED_PHP_VERSIONS."
    add_composer_version_argument "docker/${php_version}/Dockerfile"
done

printf '\nDone. Review the changes with `git diff docker/ sail`, then rebuild with `./sail build --no-cache`.\n'
