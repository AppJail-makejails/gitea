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

## SSH

**TODO**

### Arguments

* `gitea_tag` (default: `13.2`): see [#tags](#tags).

## How to build the Image

**TODO**

## Tags

| Tag    | Arch    | Version           | Type   |
| ------ | ------- | ----------------- | ------ |
| `13.2` | `amd64` | `13.2-RELEASE-p1` | `thin` |
| `13.1` | `amd64` | `13.1-RELEASE-p8` | `thin` |
