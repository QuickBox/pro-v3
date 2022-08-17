<div align="center">

[<img width="550" src="https://quickbox.io/files/2018/12/qb_logo_original.png" alt="QuickBox Project Logo">](https://quickbox.io)

![version](https://badgen.net/badge/version/3.0.0.2808/blue)

##### OS/Distro support

![debian_11](https://badgen.net/badge/Debian%2011/passing/green) ![debian_10](https://badgen.net/badge/Debian%2010/passing/green) ![debian_9](https://badgen.net/badge/Debian%209/passing/orange)

**Heads up:** Though Debian 9 is supported, it has also hit it's EOL as of June 2022.<br/>It is advised to use either Debian 11 (bullseye)[^1] or Debian 10 (buster).<br/>You can read more on Debian 9 EOL [here](https://wiki.debian.org/LTS).

</div>

---

## INSTALLATION

### Step 1:

Elevate your bash environment to root and move to the `/root` directory.

```bash
sudo -i
```

- Why elevate your bash environment to root?
	- Because we need to be able to write to the `/root` directory as well as access restricted files and operations. By using `sudo -i` we temporarily elevate our bash environment to complete more sensitive tasks; such as building and configuring nginx, php, etc...
- If you receive a "sudo: command not found" error, please install sudo.
	- sudo can be installed with the following command as root:
		```bash
		apt-get install -y sudo
		```
- Why is sudo not installed?
	- This is a side-effect of installation parameters from the OS build. If a root password is specified during installation of the OS, sudo is not installed by default. If a root password is not specified during installation of the OS, sudo is installed. This is more commonly seen with local installs, however, some providers may not install sudo by default.

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

- If you receive a "curl: command not found" error, please install curl.
	- curl can be installed with the following command:
		```bash
		sudo apt-get install -y curl
		```
- What is curl?
	- curl is a command line tool that allows you to retrieve files from the internet.

### Step 4:

Run the installer.

```bash
./qbpro -u USERNAME -p 'PASSWORD' -k 'API_KEY'
```
USERNAME[^2], 'PASSWORD'[^3], 'API_KEY'[^4]

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

(apt-get -y update && apt-get -y upgrade && apt -y install curl; \
curl -sL "https://lab.quickbox.io/QuickBox/pro-v3/-/raw/main/qbpro_v3" > qbpro && chmod +x qbpro; \
./qbpro -u "${username}" -p "${password}" -k "${api_key}")
```

---

### REFERENCES

[^1]: <mark>Debian 11 (bullseye) is the recommended Distro for install.</mark>
[^2]: <mark>Your username is unique to your QuickBox installation and can be whatever you like.</mark>
[^3]: <mark>Your password is unique to your QuickBox installation and can be whatever you like.</mark>
[^4]: <mark>Your API Key is unique to your QuickBox account and can be found on [your account](https://quickbox.io/my-account/api-keys).</mark>

---
