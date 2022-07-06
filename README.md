<div align="center">

[<img width="550" src="https://quickbox.io/files/2018/12/qb_logo_original.png" alt="QuickBox Project Logo">](https://quickbox.io)

![version](https://badgen.net/badge/version/3.0.0-beta.2503/blue) ![license](https://badgen.net/badge/license/BSD%203-Clause%20License/blue)

##### OS/Distro support

![debian_11](https://badgen.net/badge/Debian%2011/passing/green) ![debian_10](https://badgen.net/badge/Debian%2010/passing/green)

</div>


---

# RELEASE COMING SOON

# July 17, 2022

---

> ## The below has only been staged for release in the near future.<br/>Please check back for updates.<br/>Do not attempt to use this set of steps until then.

---

## INSTALLATION

### Step 1:

Elevate your bash environment to root and move to the `/root` directory.

```bash
sudo -i
```

- Why elevate your bash environment to root?
	- Because we need to be able to write to the `/root` directory as well as access restricted files and operations. By using `sudo -i` we temporarily elevate our bash environment to complete more sensitive tasks; such as building and configuring nginx, php, etc...

### Step 2:

It's good practice to check your system apt.

```bash
apt-get -y update && apt-get -y upgrade
```

- Why check your system apt?
	- Because we need to be able to install packages that are not available in the repositories.
	- We also need to check for available security updates and be able to install them.
	- We also need to check for available general updates and be able to install them.
	- Though QuickBox does it for you on software installs and version updates, it's good practice to check your system apt regularly.

### Step 3:

Grab the latest setup file.

```bash
curl -sL "https://lab.quickbox.io/QuickBox/pro-v3/-/raw/main/qbpro_v3" > qbpro && chmod +x qbpro
```

### Step 4:

Run the installer.

```bash
./qbpro -u USERNAME -p 'PASSWORD' -k 'API_KEY'
```
USERNAME[^1], 'PASSWORD'[^2], 'API_KEY'[^3]

---

##### Advanced Usage (Optional)

```bash
  -d | --domain DOMAIN
  -e | --email EMAIL@ADDRESS
-ftp | --ftp FTP_PORT
-ssh | --ssh-port SSH_PORT
  -t | --trackers [allowed | blocked]
```

example:

```bash
./qbpro -u USERNAME -p 'PASSWORD' -k 'API_KEY' -d 'DOMAIN' -e 'EMAIL@ADDRESS' -ftp FTP_PORT -ssh SSH_PORT -t blocked
```

The above example will install QuickBox Pro with the following options:

- Domain: DOMAIN (the domain name of your server - example: `-d 'mydomain.com'`).
    - **You must have a valid domain name already registered with your provider and the proper DNS records set up.**<br/>This will set the Dashboard for QuickBox Pro to your domain as well as install a valid SSL certificate.
- Email: EMAIL@ADDRESS (the email address of your user - example: `-e 'my@email.com'`).
- FTP Port: FTP_PORT (the port number of your FTP server - example: `-ftp 5757`).
- SSH Port: SSH_PORT (the port number of your SSH server - example: `-ssh 4747`).
- Trackers: allowed (allow trackers to be downloaded - example: `-t allowed`).
- Trackers: blocked (block trackers from being downloaded - example: `-t blocked`).

Run in single snippet. Updating username, password, and api_key details as required:

```bash
username="ENTER_DESIRED_USERNAME_HERE"
password="ENTER_DESIRED_PASSWORD_HERE"
api_key="ENTER_API_KEY_HERE"

(apt-get -y update && apt-get -y upgrade; \
curl -sL "https://lab.quickbox.io/QuickBox/pro-v3/-/raw/main/qbpro_v3" > qbpro && chmod +x qbpro; \
./qbpro -u "${username}" -p "${password}" -k "${api_key}")
```

---

[^1]: <mark>Your username is unique to your QuickBox installation and can be whatever you like.</mark>
[^2]: <mark>Your password is unique to your QuickBox installation and can be whatever you like.</mark>
[^3]: <mark>Your API Key is unique to your QuickBox account and can be found on [your account](https://quickbox.io/my-account/api-keys).</mark>

---
