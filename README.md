# Gitea

Gitea is a forge software package for hosting software development version control using Git as well as other collaborative features like bug tracking, code review, continuous integration, kanban boards, tickets, and wikis. It supports self-hosting but also provides a free public first-party instance. It is a fork of Gogs and is written in Go. Gitea can be hosted on all platforms supported by Go including Linux, macOS, and Windows. The project is funded on Open Collective.

wikipedia.org/wiki/Gitea

<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/b/bb/Gitea_Logo.svg/800px-Gitea_Logo.svg.png" alt="gitea logo" width="60%" height="auto">

## How to use this Makejail

## Basic usage

Suppose the host IP is `192.168.1.102`:

```sh
appjail makejail -j gitea -f gh+AppJail-makejails/gitea \
    -V GITEA__SERVER__DOMAIN=192.168.1.102 \
    -V GITEA__DEFAULT__APP_NAME="Welcome to my git server!" \
    -o virtualnet=":gitea default" \
    -o nat \
    -o expose=3000
```

We can now publicly access our git server through `http://192.168.1.102:3000`.

This Makejail uses a script to set the gitea options in `/usr/local/etc/gitea/conf/app.ini` using environment variables that can be set using `appjail makejail -V` as you can see above. The script follows very simple rules:

1. Environment variables must have the form: `GITEA__SECTION_NAME__KEY_NAME`.
2. `SECTION` and `KEY_NAME` must be in uppercase. They can contain `_` and numbers.
3. `_0X2E_` will be replaced by `.` and `_0X2D_` by `-`.
4. To use the blank or global section, use `DEFAULT` as the section.

## Configuration file

We can use a static configuration file to deploy our git server in combination with environment variables.

```sh
appjail makejail -j gitea -f gh+AppJail-makejails/gitea \
    -V GITEA__DEFAULT__APP_NAME="Welcome to my git server!" \
    -o virtualnet=":gitea default" \
    -o nat \
    -o expose=3000 -- \
        --gitea_config_file /tmp/app.ini
```

## SSH

```sh
appjail makejail -j gitea -f gh+AppJail-makejails/gitea \
    -V GITEA__SERVER__SSH_PORT=2022 \
    -V GITEA__SERVER__DOMAIN=192.168.1.102 \
    -V GITEA__DEFAULT__APP_NAME="Welcome to my git server!" \
    -o virtualnet=":gitea default" \
    -o nat \
    -o expose=3000 \
    -o expose=2022:22 \
    -o copydir=/tmp/files \
    -o file=/etc/rc.conf.local
```

The tree structure of the `/tmp/files/` directory is as follows:

```
# tree -pug /tmp/files
[drwxr-xr-x root     wheel   ]  /tmp/files/
└── [drwxr-xr-x root     wheel   ]  etc
    └── [-rw-r--r-- root     wheel   ]  rc.conf.local

    2 directories, 1 file
```

**/etc/rc.conf.local**:

```
sshd_enable="YES"
```

### Arguments

* `gitea_tag` (default: `13.5`): see [#tags](#tags).
* `gitea_ajspec` (default: `gh+AppJail-makejails/gitea`): Entry point where the `appjail-ajspec(5)` file is located.
* `gitea_config_file` (optional): custom configuration file.

### Volumes

| Name      | Owner | Group | Perm | Type | Mountpoint     |
| --------- | ----- | ----- | ---- | ---- | -------------- |
| gitea-db  | 211   | 0     |  -   |  -   | /var/db/gitea  |
| gitea-log | 211   | 0     |  -   |  -   | /var/log/gitea |
| gitea-git | 211   | 211   |  -   |  -   | /usr/local/git |

## Tags

| Tag    | Arch    | Version        | Type   |
| ------ | ------- | -------------- | ------ |
| `13.5` | `amd64` | `13.5-RELEASE` | `thin` |
| `14.3` | `amd64` | `14.3-RELEASE` | `thin` |
