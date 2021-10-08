[![QuickBox](https://quickbox.io/files/2018/12/qb_logo_original.png "QuickBox")](https://quickbox.io)

---

## Script status

![Version v2.4.7](https://img.shields.io/badge/version-v2.4.7-lightgrey.svg?style=flat-square) ![BSD 3-Clause License](https://img.shields.io/badge/license-BSD%203--Clause%20License-blue.svg?style=flat-square)

#### Debian Builds
![Debian 9 Passing](https://img.shields.io/badge/Debian%209-passing-brightgreen.svg?style=flat-square) ![Debian 10 Passing](https://img.shields.io/badge/Debian%2010-passing-brightgreen.svg?style=flat-square)

> ##### Supported OS/Distro
>
> + Debian 9
> + Debian 10

---

## Before installation

---

You need to have a Fresh "blank" server installation.
After that access your box using a SSH client, like PuTTY.
Please run in root to avoid conflicts.

---

## How to install

---

It is advisable to run the below code to make certain your server has gotten a full update before stating the installation!

`apt-get -y update && apt-get -y upgrade`

> ### IMPORTANT: 
> DO NOT use usernames such as `admin` or `root` as these are system reserved and could cause breakage on certain functionality in QuickBox Pro. Additionally, try to avoid using characters such as ``~'\"` in passwords on setup as this can cause an identifying issue within Linux.

The setup does require root in order to run. If you are sudo on login, you can elevate to root with `sudo su -`.

**Run the following command to grab our latest release ...**
```
(apt-get -y update && apt-get -y upgrade && apt-get -y autoclean; \
apt-get -y install wget; \
cd /root && wget -q https://lab.quickbox.io/QuickBox/pro-v3/raw/master/quickbox_install && chmod +x quickbox_install; \
./quickbox_install -u 'USERNAME' -p 'PASSWORD' -k 'API_KEY')
```

#### What do these values mean?
```
  Options:
    -u,  --username         The QuickBox primary user
    -p,  --password         The QuickBox primary user password
    -k,  --api_key          The API Key associated with your install
    -d,  --domain           Domain/subDomain to use with QuickBox (note: this will automatically
                            generate a valid certificate on initial setup. Please ensure you
                            have a valid Domain & A Record setup before attempting to use this option.)
    -m,  --mount            Custom mount point for HDD status on dashboard
         --reboot           Automatically reboot at end of setup
    -h,  --help             Display this help and exit
    -v,  --version          Output version information and exit

    Examples:
    Note that these fields are unique to your wants.

  ./quickbox_install -u <admin_username> -p <admin_password> -k <api_key>
```
