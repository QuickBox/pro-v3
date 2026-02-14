# QuickBox Pro - Mail Stack

This module provides a native Mail Server and Webmail client using a containerized approach.

## Components
- **Backend**: [docker-mailserver](https://github.com/docker-mailserver/docker-mailserver) (Postfix, Dovecot, SpamAssassin, ClamAV, Fail2Ban).
- **Webmail**: [SnappyMail](https://github.com/the-djmaze/snappymail) - A fast, modern, and database-less webmail client.

## Requirements
- Docker and Docker Compose (v2+)
- A valid SSL certificate (e.g., from Let's Encrypt)
- Open ports: 25, 143, 465, 587, 993, and 8888 (for webmail)

## Installation
1. Navigate to the `mail-stack` directory.
2. Run the deployment script:
   ```bash
   sudo ./deploy.sh
   ```
3. Follow the prompts to configure your domain, SSL paths, and optional relay host.

## Management
Use the `manage-mail.sh` script to manage your mailboxes:
- **Add/Update mailbox**: `./manage-mail.sh add user@domain.com password`
- **Remove mailbox**: `./manage-mail.sh del user@domain.com`
- **List mailboxes**: `./manage-mail.sh list`
- **View DKIM records**: `./manage-mail.sh dkim`

## DNS Configuration
After installation, you **MUST** configure your DNS records for mail to function correctly and avoid being marked as spam:

| Record Type | Name | Value | Purpose |
| :--- | :--- | :--- | :--- |
| **MX** | `@` | `mail.yourdomain.com` | Directs incoming mail to your server |
| **A** | `mail` | `YOUR_SERVER_IP` | Points mail hostname to your server |
| **SPF** | `@` | `v=spf1 mx ~all` | Authorizes your server to send mail |
| **DKIM** | `mail._domainkey` | (Output from `./manage-mail.sh dkim`) | Cryptographically signs outgoing mail |
| **DMARC** | `_dmarc` | `v=DMARC1; p=none; rua=mailto:admin@yourdomain.com` | Instructs receivers on how to handle failed SPF/DKIM |

## SnappyMail Webmail Configuration
1. Access the SnappyMail admin panel at `https://mail.yourdomain.com/?admin` (or `http://YOUR_IP:8888/?admin`).
2. The default login is **admin** with **no password**. You will be prompted to set an admin password on your first visit.
3. In the admin panel, go to **Domains** and ensure your domain is configured to use the `mailserver` container:
   - **IMAP**: `mailserver` (Port 143, STARTTLS)
   - **SMTP**: `mailserver` (Port 587, STARTTLS)

## SSL Integration & Renewal
The mail server maps the certificates you specify during installation. If you are using Let's Encrypt (standard in QuickBox), the certificates will be automatically mapped.
To pick up renewed certificates, you can use the provided reload script:
```bash
sudo ./reload-certs.sh
```
It is recommended to add this script as a post-renewal hook for Certbot or as a weekly cron job.

## Troubleshooting
### Port 25 is Blocked
Many VPS providers (Hetzner, DigitalOcean, Vultr, etc.) block outbound Port 25 by default.
- **Symptom**: You can receive mail but cannot send it.
- **Solution**: Use an SMTP Relay (like SendGrid, Mailgun, or Amazon SES). The `deploy.sh` script includes an option to configure this automatically.

### Port Conflicts
If the installer fails due to port conflicts, ensure you don't have a default `postfix` or `exim4` service running on the host:
```bash
sudo systemctl stop postfix
sudo systemctl disable postfix
```

### Resource Usage
ClamAV (Antivirus) is disabled by default to save RAM. If you have 4GB+ of RAM and wish to enable it, set `ENABLE_CLAMAV=1` in `mailserver.env` and restart the stack:
```bash
docker compose up -d
```
