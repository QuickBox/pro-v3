#!/usr/bin/env bash
# shellcheck disable=SC2249
set -euo pipefail

MAIL_STACK_DIR="${MAIL_STACK_DIR:-/opt/quickbox/mail-stack}"
# Check if we are running from the source directory or the installed directory
if [ ! -d "${MAIL_STACK_DIR}" ]; then
    MAIL_STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

DOCKER_COMPOSE="docker compose -f ${MAIL_STACK_DIR}/docker-compose.yml"

usage() {
    echo "QuickBox Mail Management CLI"
    echo "Usage: $0 {add|del|list|passwd|quota|dkim} [args]"
    echo
    echo "Commands:"
    echo "  add <email> <password>    Add a new email account"
    echo "  del <email>               Delete an email account"
    echo "  list                      List all email accounts"
    echo "  passwd <email> <password> Update password for an email account"
    echo "  quota <email> <quota>     Set quota for an email account (e.g. 1G)"
    echo "  dkim                      Generate DKIM keys"
    exit 1
}

if [ $# -lt 1 ]; then
    usage
fi

COMMAND=$1
shift

# Check if docker is available
if ! command -v docker >/dev/null; then
    echo "[!] Error: docker command not found." >&2
    exit 1
fi

# Check if the stack is running
if ! ${DOCKER_COMPOSE} ps | grep -q "mailserver.*running"; then
    echo "[!] Warning: mailserver container is not running. Some commands may fail." >&2
fi

case "${COMMAND}" in
    add)
        [ $# -lt 2 ] && echo "Usage: $0 add <email> <password>" && exit 1
        ${DOCKER_COMPOSE} exec -T mailserver setup email add "$1" "$2"
        ;;
    del)
        [ $# -lt 1 ] && echo "Usage: $0 del <email>" && exit 1
        ${DOCKER_COMPOSE} exec -T mailserver setup email del "$1"
        ;;
    list)
        ${DOCKER_COMPOSE} exec -T mailserver setup email list
        ;;
    passwd)
        [ $# -lt 2 ] && echo "Usage: $0 passwd <email> <password>" && exit 1
        ${DOCKER_COMPOSE} exec -T mailserver setup email update "$1" "$2"
        ;;
    quota)
        [ $# -lt 2 ] && echo "Usage: $0 quota <email> <quota>" && exit 1
        ${DOCKER_COMPOSE} exec -T mailserver setup email quota "$1" "$2"
        ;;
    dkim)
        ${DOCKER_COMPOSE} exec -T mailserver setup config dkim
        ;;
    *)
        usage
        ;;
esac
