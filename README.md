[![QuickBox](https://quickbox.io/files/2018/12/qb_logo_original.png "QuickBox")](https://quickbox.io)

---

# RELEASE COMING SOON

July 17, 2022

---

> The below has only been staged for release in the near future. Please check back for updates. Do not attempt to use this set of steps until then.

## INSTALLATION

### Step 1:

It's good practice to first check your system apt.

```bash
sudo apt-get -y update && sudo apt-get -y upgrade
```

### Step 2:

Elevate your bash environment to root and move to the `/root` directory.

```bash
sudo -i
```

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
