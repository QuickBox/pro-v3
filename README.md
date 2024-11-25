<div align="center">

[<img width="550" src="https://quickbox.io/files/2018/12/qb_logo_original.png" alt="QuickBox Project Logo">](https://quickbox.io)

![version](https://badgen.net/badge/version/3.1.3.4473/blue)

### OS/Distro Support

![debian_12](https://badgen.net/badge/Debian%2012/passing/green) ![debian_11](https://badgen.net/badge/Debian%2011/passing/green) ![debian_10](https://badgen.net/badge/Debian%2010/EOL/black)

![ubuntu_22.04](https://badgen.net/badge/Ubuntu%2022.04/passing/green)

> :warning: **Support for Debian 10 has officially ended as of June 2024, marking its End of Life (EOL).**
> Consequently, some upstream repositories, such as php.sury.org, have retired their sources for Debian 10.
> This may result in installation failures for new setups.
> Please note that QuickBox is not responsible for the availability or maintenance of third-party repositories.

We recommend using either Debian 12 (Bookworm)[^1] or Debian 11 (Bullseye)
Learn more about Debian 10 EOL [here](https://wiki.debian.org/LTS).

</div>

---

## Installation

### Step 1: Elevate to Root

Switch to the root user and navigate to the `/root` directory.

```bash
sudo -i
```

- **Why elevate to root?**  
  Root access is required to modify system files, such as those in `/root` and to perform critical tasks like configuring Nginx, PHP, etc.

- **Missing sudo?**  
  If `sudo` is not installed, you can add it with the following command as root:

```bash
apt-get install -y sudo
```

  - **Why is sudo not installed by default?**  
    This is usually determined by the OS installation parameters. If a root password is specified during the installation, `sudo` is not installed. If no root password is set, `sudo` is automatically installed. This can also vary by provider.

### Step 2: Update Your System

Ensure your system’s package lists are up to date and install any available upgrades.

```bash
apt-get -y update && apt-get -y upgrade
```

- **Why update?**  
  Updating ensures you have the latest software packages and security patches installed. It's a good practice to regularly update your system.

### Step 3: Download the Setup Script

Fetch the latest QuickBox Pro setup script.

```bash
curl -sL "https://lab.quickbox.io/QuickBox/pro-v3/-/raw/main/qbpro_v3" > qbpro && chmod +x qbpro
```

- **Curl not found?**  
  If you receive a "curl: command not found" error, install curl with the following command:

```bash
sudo apt-get install -y curl
```

- **What is curl?**  
  `curl` is a command-line tool used to download files from the internet.

### Step 4: Run the Installer

Run the setup script, providing your `USERNAME`, `PASSWORD`, and `API_KEY`:

```bash
./qbpro -u USERNAME -p 'PASSWORD' -k 'API_KEY'
```

- `USERNAME`: Your desired username.
- `PASSWORD`: Your desired password.
- `API_KEY`: Your unique API Key from your QuickBox account.

---

### Advanced Usage (Optional)

You can add optional flags to customize your installation:

```bash
-d | --domain DOMAIN
-e | --email EMAIL@ADDRESS
-ftp | --ftp FTP_PORT
-ssh | --ssh-port SSH_PORT
-t | --trackers [allowed | blocked]
```

**Example:**

```bash
./qbpro -u USERNAME -p 'PASSWORD' -k 'API_KEY' -d 'mydomain.com' -e 'my@email.com' -ftp 5757 -ssh 4747 -t blocked
```

This example installs QuickBox Pro with the following options:

- **Domain**: The domain name for your server.  
    Example: `-d 'mydomain.com'`.  
    **Important**: Ensure the domain is registered and DNS records are properly configured. This will set up the QuickBox Dashboard on your domain and install an SSL certificate.
  
- **Email**: Your email address for notifications.  
    Example: `-e 'my@email.com'`.
  
- **FTP Port**: Custom FTP port.  
    Example: `-ftp 5757`.
  
- **SSH Port**: Custom SSH port.  
    Example: `-ssh 4747`.
  
- **Trackers**: Control tracker downloads.  
    Example:  
    - `-t allowed` (allow trackers)  
    - `-t blocked` (block trackers)

### Run All in One Command

Update `USERNAME`[^2], `PASSWORD`[^3], and `API_KEY`[^4] as needed, and run everything in one command:

```bash
username="ENTER_DESIRED_USERNAME_HERE"
password="ENTER_DESIRED_PASSWORD_HERE"
api_key="ENTER_API_KEY_HERE"

(apt-get -y update && apt-get -y upgrade && apt -y install curl; \
curl -sL "https://lab.quickbox.io/QuickBox/pro-v3/-/raw/main/qbpro_v3" > qbpro && chmod +x qbpro; \
./qbpro -u "${username}" -p "${password}" -k "${api_key}")
```

---

### References

[^1]: Debian 12 (Bookworm) is the recommended distribution.
[^2]: Choose a unique username for your QuickBox installation.
[^3]: Choose a unique password for your QuickBox installation.
[^4]: Your API Key is available in your QuickBox account [here](https://quickbox.io/my-account/api-keys).

---
