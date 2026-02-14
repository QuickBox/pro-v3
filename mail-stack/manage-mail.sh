#!/usr/bin/env bash
# QuickBox Pro - Mail Stack Management Script

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

function usage() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  add [email] [password]  Add a new mailbox (or update password)"
    echo "  del [email]             Remove a mailbox"
    echo "  list                    List all mailboxes"
    echo "  passwd [email] [pass]   Change mailbox password"
    echo "  dkim                    View DKIM keys for DNS setup"
    echo "  help                    Show this help"
}

if [[ $# -lt 1 ]]; then
    usage
    exit 1
fi

COMMAND=$1
shift

# Check if terminal is interactive
DOCKER_OPTS="-i"
[[ -t 0 ]] && DOCKER_OPTS="-it"

case "${COMMAND}" in
    add|passwd)
        if [[ $# -lt 2 ]]; then
            echo "Usage: $0 ${COMMAND} [email] [password]"
            exit 1
        fi
        docker exec ${DOCKER_OPTS} mailserver setup email add "$1" "$2"
        ;;
    del)
        if [[ $# -lt 1 ]]; then
            echo "Usage: $0 del [email]"
            exit 1
        fi
        docker exec ${DOCKER_OPTS} mailserver setup email del "$1"
        ;;
    list)
        docker exec ${DOCKER_OPTS} mailserver setup email list
        ;;
    dkim)
        DOMAIN=$(docker exec mailserver bash -c 'echo ${MAIL_DOMAIN:-}')
        if [[ -z "${DOMAIN}" ]]; then
            DOMAIN=$(docker exec mailserver ls /tmp/docker-mailserver/opendkim/keys/ 2>/dev/null | head -n 1)
        fi

        if [[ -n "${DOMAIN}" ]]; then
            KEY_FILE="/tmp/docker-mailserver/opendkim/keys/${DOMAIN}/mail.txt"
            if docker exec mailserver test -f "${KEY_FILE}"; then
                echo -e "${GREEN}DKIM Public Key for ${DOMAIN}:${NC}"
                docker exec mailserver cat "${KEY_FILE}"
            else
                echo -e "${RED}DKIM key file not found at ${KEY_FILE}${NC}"
            fi
        else
            echo -e "${RED}Could not determine MAIL_DOMAIN.${NC}"
        fi
        ;;
    help|*)
        usage
        ;;
esac
