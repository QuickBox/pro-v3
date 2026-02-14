#!/usr/bin/env bash
# QuickBox Pro - Mail Stack Deployment Script
# Shellcheck disable=SC2086

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}QuickBox Pro - Mail Stack Installer${NC}"
echo "======================================"

# Pre-flight checks
echo -n "Checking for Docker... "
if ! command -v docker &>/dev/null; then
    echo -e "${RED}FAILED${NC}"
    echo "Please install Docker before proceeding."
    exit 1
fi
echo -e "${GREEN}OK${NC}"

echo -n "Checking for Docker Compose... "
if ! docker compose version &>/dev/null; then
    echo -e "${RED}FAILED${NC}"
    echo "Please install Docker Compose (v2+) before proceeding."
    exit 1
fi
echo -e "${GREEN}OK${NC}"

echo -n "Checking outbound Port 25... "
if ! timeout 2 bash -c "</dev/tcp/google.com/25" &>/dev/null; then
    echo -e "${YELLOW}BLOCKED${NC}"
    echo -e "${YELLOW}WARNING: Outbound Port 25 is blocked. You WILL need a Relay Host to send emails.${NC}"
else
    echo -e "${GREEN}OPEN${NC}"
fi

# Check for port conflicts
REQUIRED_PORTS=(25 143 465 587 993 8888)
CONFLICTS=()
for port in "${REQUIRED_PORTS[@]}"; do
    if ss -tln | grep -q ":${port} "; then
        CONFLICTS+=("${port}")
    fi
done

if [[ ${#CONFLICTS[@]} -gt 0 ]]; then
    echo -e "${RED}PORT CONFLICTS DETECTED:${NC}"
    for port in "${CONFLICTS[@]}"; do
        echo -e " - Port ${port} is already in use."
    done
    echo "Please stop any services (like a default Postfix) using these ports before installing."
    exit 1
fi

# Configuration
if [[ ! -f "mailserver.env" ]]; then
    if [[ -f "mailserver.env.template" ]]; then
        cp mailserver.env.template mailserver.env
    else
        touch mailserver.env
    fi
fi
ln -sf mailserver.env .env

# Interactive Prompt
while true; do
    read -rp "Enter your Mail Domain (e.g. example.com): " MAIL_DOMAIN
    [[ -n "${MAIL_DOMAIN}" ]] && break
    echo -e "${RED}Domain cannot be empty!${NC}"
done

while true; do
    read -rp "Enter your Mail Hostname [mail.${MAIL_DOMAIN}]: " MAIL_HOSTNAME
    MAIL_HOSTNAME=${MAIL_HOSTNAME:-mail.${MAIL_DOMAIN}}
    [[ -n "${MAIL_HOSTNAME}" ]] && break
done

# Default SSL Paths for QuickBox
DEFAULT_CERT="/etc/nginx/ssl/quickbox.crt"
DEFAULT_KEY="/etc/nginx/ssl/quickbox.key"

while true; do
    read -rp "Enter path to SSL Certificate (fullchain) [${DEFAULT_CERT}]: " SSL_CERT_PATH
    SSL_CERT_PATH=${SSL_CERT_PATH:-${DEFAULT_CERT}}
    if [[ -f "${SSL_CERT_PATH}" ]]; then break; else echo -e "${RED}File not found!${NC}"; fi
done

while true; do
    read -rp "Enter path to SSL Private Key [${DEFAULT_KEY}]: " SSL_KEY_PATH
    SSL_KEY_PATH=${SSL_KEY_PATH:-${DEFAULT_KEY}}
    if [[ -f "${SSL_KEY_PATH}" ]]; then break; else echo -e "${RED}File not found!${NC}"; fi
done

# Update .env robustly
update_env() {
    local key=$1
    local value=$2
    # Escape value for sed
    local escaped_value=$(echo "${value}" | sed 's/[&/\]/\\&/g')
    if grep -q "^${key}=" mailserver.env; then
        sed -i "s|^${key}=.*|${key}=${escaped_value}|" mailserver.env
    else
        echo "${key}=${escaped_value}" >> mailserver.env
    fi
}

update_env "MAIL_DOMAIN" "${MAIL_DOMAIN}"
update_env "MAIL_HOSTNAME" "${MAIL_HOSTNAME}"
update_env "SSL_CERT_PATH" "${SSL_CERT_PATH}"
update_env "SSL_KEY_PATH" "${SSL_KEY_PATH}"

# Relay Configuration
read -rp "Do you want to configure a Relay Host? (y/n): " CONFIGURE_RELAY
if [[ "${CONFIGURE_RELAY,,}" == "y" ]]; then
    read -rp "Relay Host: " RELAY_HOST
    read -rp "Relay Port [587]: " RELAY_PORT
    RELAY_PORT=${RELAY_PORT:-587}
    read -rp "Relay User: " RELAY_USER
    read -rp "Relay Password: " RELAY_PASSWORD

    update_env "RELAY_HOST" "${RELAY_HOST}"
    update_env "RELAY_PORT" "${RELAY_PORT}"
    update_env "RELAY_USER" "${RELAY_USER}"
    update_env "RELAY_PASSWORD" "${RELAY_PASSWORD}"
fi

# Create directories
mkdir -p config/mail-data config/mail-state config/mail-config config/snappymail-data

# Pull and Start
echo "Starting containers..."
docker compose pull
docker compose up -d

# DKIM Generation
echo "Generating DKIM keys..."
docker exec mailserver setup config dkim domain "${MAIL_DOMAIN}"

echo "======================================"
echo -e "${GREEN}Mail Stack successfully deployed!${NC}"
echo -e "Webmail: ${YELLOW}https://${MAIL_HOSTNAME}${NC} (once Nginx is configured)"
echo -e "Management: Use ${YELLOW}./manage-mail.sh${NC} to add mailboxes."
echo ""
echo "IMPORTANT: Configure your DNS records (MX, SPF, DKIM, DMARC)."
echo "View DKIM public key with: ./manage-mail.sh dkim"
