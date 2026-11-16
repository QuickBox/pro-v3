#!/usr/bin/env bash
set -euo pipefail

MAIL_STACK_DIR="${MAIL_STACK_DIR:-/opt/quickbox/mail-stack}"
DB_PATHS=("/opt/quickbox/config/db/qbpro.db" "/srv/quickbox/db/qbpro.db")

echo "=== QuickBox Mail Stack Deployment ==="

# Pre-flight checks
echo "[i] Performing pre-flight checks..."

# Check port conflicts
for port in 25 143 465 587 993 8888; do
    if command -v lsof >/dev/null && lsof -Pi :$port -sTCP:LISTEN -t >/dev/null; then
        echo "[!] Error: Port $port is already in use." >&2
        exit 1
    fi
done

# Check outbound port 25
echo "[i] Checking outbound port 25 connectivity..."
if ! timeout 2 bash -c 'cat < /dev/null > /dev/tcp/portquiz.net/25' 2>/dev/null; then
    echo "[!] Warning: Outbound port 25 seems blocked. Mail delivery might fail."
fi

# Directory setup
echo "[i] Setting up directories..."
mkdir -p "${MAIL_STACK_DIR}"/{mail-data,mail-state,mail-config,snappymail-data,dashboard}
# Copy files if they are in the current source directory but not in MAIL_STACK_DIR
if [ "$(pwd)" != "${MAIL_STACK_DIR}" ] && [ -d "../mail-stack" ]; then
    echo "[i] Copying stack files to ${MAIL_STACK_DIR}..."
    cp -r ../mail-stack/* "${MAIL_STACK_DIR}/"
elif [ "$(pwd)" != "${MAIL_STACK_DIR}" ] && [ -d "./mail-stack" ]; then
    echo "[i] Copying stack files to ${MAIL_STACK_DIR}..."
    cp -r ./mail-stack/* "${MAIL_STACK_DIR}/"
fi
chmod -R 775 "${MAIL_STACK_DIR}"

# Detect PUID/PGID
PUID=$(id -u)
PGID=$(id -g)
echo "[i] Detected PUID=${PUID}, PGID=${PGID}"

# Environment Setup
if [ ! -f "${MAIL_STACK_DIR}/.env" ]; then
    echo "[i] Creating initial .env file..."
    MAIL_HOSTNAME="mail.$(hostname -f 2>/dev/null || echo "example.com")"
    MAIL_DOMAIN="$(hostname -d 2>/dev/null || echo "example.com")"

    # Secure Token Generation
    if ! API_TOKEN=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32); then
        echo "[!] Error: Failed to generate API token." >&2
        exit 1
    fi

    cat <<EOF > "${MAIL_STACK_DIR}/.env"
MAIL_HOSTNAME=${MAIL_HOSTNAME}
MAIL_DOMAIN=${MAIL_DOMAIN}
SSL_CERT_PATH=/etc/letsencrypt/live/${MAIL_HOSTNAME}/fullchain.pem
SSL_KEY_PATH=/etc/letsencrypt/live/${MAIL_HOSTNAME}/privkey.pem
PUID=${PUID}
PGID=${PGID}
API_TOKEN=${API_TOKEN}
EOF
fi

# Load variables from .env
# shellcheck disable=SC1091
if [ -f "${MAIL_STACK_DIR}/.env" ]; then
    MAIL_HOSTNAME=$(grep '^MAIL_HOSTNAME=' "${MAIL_STACK_DIR}/.env" | cut -d'=' -f2)
    SSL_CERT_PATH=$(grep '^SSL_CERT_PATH=' "${MAIL_STACK_DIR}/.env" | cut -d'=' -f2)
    SSL_KEY_PATH=$(grep '^SSL_KEY_PATH=' "${MAIL_STACK_DIR}/.env" | cut -d'=' -f2)
fi

# SSL validation
echo "[i] Validating SSL certificates..."
if [ ! -f "${SSL_CERT_PATH:-}" ] || [ ! -f "${SSL_KEY_PATH:-}" ]; then
    echo "[!] Warning: SSL certificates not found at ${SSL_CERT_PATH:-}. Stack might fail to start."
    if [ -n "${SSL_CERT_PATH:-}" ]; then
        mkdir -p "$(dirname "${SSL_CERT_PATH}")" 2>/dev/null || echo "[!] Could not create certificate directory."
    fi
fi

# Database registration
echo "[i] Registering Mail Stack in database..."
DB_FILE=""
for db in "${DB_PATHS[@]}"; do
    if [ -f "$db" ]; then
        DB_FILE="$db"
        break
    fi
done

if [ -n "$DB_FILE" ]; then
    sqlite3 "$DB_FILE" "INSERT OR IGNORE INTO software_information (software_name, software_service_name) VALUES ('MailStack', 'mail-stack');" || echo "[!] DB registration failed."
    echo "[✓] Registered in $DB_FILE"
fi

# Configuring sudoers for dashboard API
echo "[i] Configuring sudoers for dashboard API..."
SUDOERS_FILE="/etc/sudoers.d/quickbox-mail-stack"
if [ -d "/etc/sudoers.d" ]; then
    if ! echo "www-data ALL=(ALL) NOPASSWD: ${MAIL_STACK_DIR}/manage-mail.sh" | tee "${SUDOERS_FILE}" >/dev/null 2>&1; then
        echo "[!] Could not create sudoers file. Dashboard API may require manual sudo configuration."
    else
        chmod 440 "${SUDOERS_FILE}" 2>/dev/null || true
    fi
fi

# Process Nginx Configuration
echo "[i] Configuring Nginx..."
if [ -f "${MAIL_STACK_DIR}/nginx.conf.template" ]; then
    sed "s/{{MAIL_HOSTNAME}}/${MAIL_HOSTNAME}/g" "${MAIL_STACK_DIR}/nginx.conf.template" > "${MAIL_STACK_DIR}/nginx.conf"
    if [ -d "/etc/nginx/sites-enabled" ]; then
        cp "${MAIL_STACK_DIR}/nginx.conf" /etc/nginx/sites-enabled/mail-stack.conf 2>/dev/null || echo "[!] Could not install Nginx config."
        if command -v nginx >/dev/null; then
            nginx -t 2>/dev/null && systemctl reload nginx 2>/dev/null || echo "[!] Nginx reload failed."
        fi
    fi
fi

# Install Systemd Service
echo "[i] Installing systemd service..."
if [ -f "${MAIL_STACK_DIR}/mail-stack.service" ]; then
    cp "${MAIL_STACK_DIR}/mail-stack.service" /etc/systemd/system/mail-stack.service 2>/dev/null || echo "[!] Could not install systemd service."
    if command -v systemctl >/dev/null; then
        systemctl daemon-reload 2>/dev/null || true
        systemctl enable mail-stack.service 2>/dev/null || true
        echo "[✓] Systemd service install attempted."
    fi
fi

# Pull images
echo "[i] Pulling Docker images..."
if command -v docker >/dev/null; then
    (cd "${MAIL_STACK_DIR}" && docker compose pull) || echo "[!] Docker pull failed. Continuing..."
fi

echo "[✓] Deployment script completed successfully."
