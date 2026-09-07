<div align="center">

[<img width="550" src="https://quickbox.io/files/2018/12/qb_logo_original.png" alt="QuickBox Project Logo">](https://quickbox.io)

![version](https://badgen.net/badge/version/3.2.2.6733/blue)

**QuickBox Pro** is a complete media server management system featuring 60+ applications, a professional dashboard, CLI tools, and multi-user support.

</div>

---

## Table of Contents

- [Quick Install](#quick-install)
- [Supported Operating Systems](#supported-operating-systems)
- [Where to Get Your API Key](#where-to-get-your-api-key)
- [CLI Options](#cli-options)
- [Mail Stack](#mail-stack)
- [Step-by-Step Installation](#step-by-step-installation)
- [Troubleshooting](#troubleshooting)
- [Support](#support)

---

## Quick Install

**Requirements:** Root access, `curl`, a supported OS (Debian 12–13 or Ubuntu 22.04/24.04).

> [!IMPORTANT]
> **Fresh Installation Required:** QuickBox Pro should be installed on a fresh, minimal server installation for optimal compatibility and security. Installing on existing systems with pre-configured services is not recommended and may cause conflicts.

```bash
sudo -i
curl -sL "https://github.com/QuickBox/pro-v3/raw/refs/heads/main/qbpro_v3" > qbpro && chmod +x qbpro
./qbpro -u USERNAME -p 'PASSWORD' -k 'API_KEY'
```

Replace `USERNAME`, `PASSWORD`, and `API_KEY` with your values.

**One-liner (updates system first):**

```bash
sudo -i
apt-get -y update && apt-get -y upgrade && apt-get -y install curl && \
curl -sL "https://github.com/QuickBox/pro-v3/raw/refs/heads/main/qbpro_v3" > qbpro && chmod +x qbpro && \
./qbpro -u USERNAME -p 'PASSWORD' -k 'API_KEY'
```

---

## Supported Operating Systems

| Status | OS | Notes |
| --- | --- | --- |
| ✅ Recommended | Debian 13 (Trixie) | Best experience, current default |
| ✅ Recommended | Debian 12 (Bookworm) | Stable, long-term choice |
| ✅ Supported | Ubuntu 24.04 LTS | Works out of the box, but does contain bloat |
| ✅ Supported | Ubuntu 22.04 LTS | Works out of the box, but does contain bloat |
| ⛔ Retired | Debian 11 (Bullseye) | EOL; the installer no longer accepts it — [upgrade to Debian 12](https://v3.quickbox.io/articles/upgrade-debian-11-bullseye-to-debian-12-bookworm) |
| ⛔ Deprecated | Debian 10 (Buster) | EOL; installs may fail |

> [!WARNING]
> Debian 11 has reached End of Life and is no longer accepted by the installer. [Upgrade to Debian 12 (Bookworm)](https://v3.quickbox.io/articles/upgrade-debian-11-bullseye-to-debian-12-bookworm) to stay on a supported release.
>
> Debian 10 reached End of Life in June 2024. Upstream repos (e.g., php.sury.org) have been retired, causing fresh installs to fail. Use Debian 12 or 13.

---

## Where to Get Your API Key

You need a valid API key to install QuickBox Pro.

| Platform | URL | Status |
| --- | --- | --- |
| **v3 Platform** | https://v3.quickbox.io/dashboard/api-keys | ✅ Primary (launching soon!) |
| Classic Site | https://quickbox.io/my-account/api-keys | ⚠️ Legacy (to be retired) |

> [!IMPORTANT]
> **Platform Migration:** QuickBox Pro is transitioning to a new purpose-built platform at [v3.quickbox.io](https://v3.quickbox.io). All new purchases and billing are handled there. If you have existing API keys or subscriptions on the classic site, use the **Migration Utility** at [v3.quickbox.io/dashboard/migrate](https://v3.quickbox.io/dashboard/migrate) to transfer your keys and order history to the new platform. Your installed servers are unaffected—only your account records move. Migrate soon; the classic site will eventually be archived. Until the new site is public, you can continue purchasing and using API keys from the classic site for installations—but we recommend migrating when possible.

---

## CLI Options

### Required

| Flag | Description |
| --- | --- |
| `-u`, `--username` | Admin username (alphanumeric; cannot start or end with a number) |
| `-p`, `--password` | Admin password (avoid special characters: `!@#$%^&*()_+`) |
| `-k`, `--api-key` | Your QuickBox Pro API key |

> [!CAUTION]
> **Username Restrictions:** Avoid usernames that begin or end with numbers, contain uppercase letters, or use reserved names like `none`, `admin`, `root`, `user`, or `username`. The `none` username in particular will fail with applications like rtorrent that use screen.
>
> **Password Restrictions:** During initial setup, avoid special characters like `!`, `\`, `/`, `+`, `@`, and `%` as they can cause escaping issues. You can change to a stronger password with these characters after installation via the dashboard.

### Optional

| Flag | Description | Example |
| --- | --- | --- |
| `-d`, `--domain` | Domain name for the dashboard (enables SSL) | `-d mydomain.com` |
| `-e`, `--email` | Email address for notifications/SSL | `-e user@example.com` |
| `-ftp`, `--ftp` | Custom FTP port (numeric) | `-ftp 5757` |
| `-ssh`, `--ssh-port` | Custom SSH port (numeric) | `-ssh 4747` |
| `-t`, `--trackers` | Tracker policy: `allowed` or `blocked` | `-t blocked` |
| `-m`, `--mount` | External mount path | `-m /mnt/storage` |
| `-h`, `--help` | Display help | |

### DNS Challenge Options (for SSL via DNS validation)

| Flag | Description |
| --- | --- |
| `-dns`, `--dns` | Enable DNS challenge for SSL |
| `--dns-provider` | DNS provider name (required with `-dns` in non-interactive mode) |
| `--dns-credentials` | Path to DNS credentials file (required with `-dns` in non-interactive mode) |

### Example

```bash
./qbpro -u admin -p 'MySecurePass' -k 'qbp_abc123...' -d 'server.example.com' -e 'admin@example.com' -ssh 2222 -t blocked
```

---

## Mail Stack

QuickBox Pro includes a fully integrated Mail Stack featuring a secure mail server and webmail interface.

### Features
- **docker-mailserver:** A full-stack but simple-to-use mail server (SMTP, IMAP, Antispam, Antivirus).
- **SnappyMail:** A modern, fast, and secure webmail interface.
- **Unified Management:** Manage mailboxes via CLI or the Dashboard.

### Management via CLI
You can manage your mail accounts using the `qb` command or the direct management script:

```bash
# List all mail accounts
sudo /opt/quickbox/mail-stack/manage-mail.sh list

# Add a new account
sudo /opt/quickbox/mail-stack/manage-mail.sh add user@example.com 'mypassword'

# Change password
sudo /opt/quickbox/mail-stack/manage-mail.sh passwd user@example.com 'newpassword'

# Set quota
sudo /opt/quickbox/mail-stack/manage-mail.sh quota user@example.com 2G
```

### Accessing Webmail
Webmail is accessible at `http://mail.yourdomain.com` (or your configured mail hostname).
The administration interface for SnappyMail is available at `http://mail.yourdomain.com/?admin`.

---

## Step-by-Step Installation

### 1. Switch to Root

```bash
sudo -i
```

The installer must run as root. If `sudo` is not installed, log in as root directly or install it:

```bash
apt-get install -y sudo
```

### 2. Update System (Recommended)

```bash
apt-get -y update && apt-get -y upgrade
```

### 3. Install curl (if needed)

```bash
apt-get -y install curl
```

### 4. Download the Installer

```bash
curl -sL "https://github.com/QuickBox/pro-v3/raw/refs/heads/main/qbpro_v3" > qbpro && chmod +x qbpro
```

### 5. Run the Installer

```bash
./qbpro -u USERNAME -p 'PASSWORD' -k 'API_KEY'
```

The installer will download dependencies, validate your API key, and configure your system.

---

## Troubleshooting

### "API key not provided" or "Invalid API key"

- Ensure you're using the correct API key from [v3.quickbox.io/dashboard/api-keys](https://v3.quickbox.io/dashboard/api-keys) or [quickbox.io/my-account/api-keys](https://quickbox.io/my-account/api-keys).
- Verify your license is active.

### "User is not root or sudo"

The installer requires root privileges. Run:

```bash
sudo -i
```

### "Password has invalid characters"

Passwords cannot contain: `!@#$%^&*()_+`

Use alphanumeric characters and basic punctuation only.

### "Invalid username"

Usernames must be alphanumeric and cannot start or end with a number.

### "Invalid domain name"

Domain must be a valid FQDN. Ensure DNS records point to your server before using the `-d` flag.

### "Distro not supported"

Supported distributions: Debian 12 (Bookworm), Debian 13 (Trixie), Ubuntu 22.04 (Jammy), Ubuntu 24.04 (Noble).

---

## Support

- **Website:**
  - v3 Platform: https://v3.quickbox.io (preferable)
  - Classic Site: https://quickbox.io (to access legacy account features - to be deprecated)
- **Documentation:** https://v3.quickbox.io/docs
- **Discord:** https://discord.gg/mca7RSv5pa

## Updates

- Added optimizations and improvements to ensure the highest performance, stability, security and reliability of the platform's core applications and CLI stack.
