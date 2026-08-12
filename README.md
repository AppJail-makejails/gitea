# Gitea

Gitea is a forge software package for hosting software development version control using Git as well as other collaborative features like bug tracking, code review, continuous integration, kanban boards, tickets, and wikis. It supports self-hosting but also provides a free public first-party instance. It is a fork of Gogs and is written in Go. Gitea can be hosted on all platforms supported by Go including Linux, macOS, and Windows. The project is funded on Open Collective.

wikipedia.org/wiki/Gitea

<img src="https://raw.githubusercontent.com/go-gitea/gitea/f899dfd6e0995afe6fd9fe58b0eb1d404c48d96b/assets/logo.svg" width="30%" height="auto" alt="Gitea logo">

## How to use this Makejail

### Standalone

```console
$ mkdir -p /var/appjail-volumes/gitea/data
$ appjail oci run -Pd \
    -o fstab="/var/appjail-volumes/gitea/data /data" \
    -e SSH_PORT=2222 \
    -o expose=3000 \
    -o expose=2222 \
    -e PUID=1000 \
    -e PGID=1000 \
    -o overwrite=force \
    -o virtualnet=":<random> default" \
    -o nat \
    ghcr.io/appjail-makejails/gitea gitea
```

### Deploy using `appjail-director`

#### Basics

The most simple setup just creates a volume and a network and starts the `ghcr.io/appjail-makejails/gitea:latest` image as a service. Since there is no database available, one can be initialized using SQLite3. Create a directory like `gitea` and paste the following content into a file named `appjail-director.yml`.

```yaml
options:
  - virtualnet: ':<random> default'
  - nat:

services:
  server:
    name: gitea
    makejail: gh+AppJail-makejails/gitea
    oci:
      environment:
        - PUID: 1000
        - PGID: 1000
        - SSH_PORT: 2222
    volumes:
      - gitea-data: /data
    options:
      - container: 'args:--pull'
      - expose: 2222
      - expose: 3000

volumes:
  gitea-data:
    device: /var/appjail-volumes/gitea/data
```

#### Databases

##### MySQL database

To start Gitea in combination with a MySQL database, apply these changes to the `appjail-director.yml` file created above.

```yaml
options:
  - virtualnet: ':<random> default'
  - nat:

services:
  server:
    name: gitea
    makejail: gh+AppJail-makejails/gitea
    oci:
      environment:
        - PUID: 1000
        - PGID: 1000
        - SSH_PORT: 2222
        - GITEA__database__DB_TYPE: mysql
        - GITEA__database__HOST: gitea-db:3306
        - GITEA__database__NAME: gitea
        - GITEA__database__USER: gitea
        - GITEA__database__PASSWD: gitea
    volumes:
      - gitea-data: /data
    options:
      - container: 'args:--pull'
      - expose: 2222
      - expose: 3000
      - priority: 10

  db:
    name: gitea-db
    makejail: gh+AppJail-makejails/mariadb
    priority: 98
    oci:
      environment:
        - PUID: 1000
        - PGID: 1000
        - MARIADB_ROOT_PASSWORD: gitea
        - MARIADB_USER: gitea
        - MARIADB_PASSWORD: gitea
        - MARIADB_DATABASE: gitea
    volumes:
      - db-data: /var/db/mysql
    options:
      - container: 'args:--pull'

volumes:
  gitea-data:
    device: /var/appjail-volumes/gitea/data
  db-data:
    device: /var/appjail-volumes/gitea/mariadb-data
```

##### PostgreSQL database

To start Gitea in combination with a PostgreSQL database, apply these changes to the `appjail-director.yml` file created above.

```yaml
options:
  - virtualnet: ':<random> default'
  - nat:

services:
  server:
    name: gitea
    makejail: gh+AppJail-makejails/gitea
    oci:
      environment:
        - PUID: 1000
        - PGID: 1000
        - SSH_PORT: 2222
        - GITEA__database__DB_TYPE: postgres
        - GITEA__database__HOST: gitea-db:5432
        - GITEA__database__NAME: gitea
        - GITEA__database__USER: gitea
        - GITEA__database__PASSWD: gitea
    volumes:
      - gitea-data: /data
    options:
      - container: 'args:--pull'
      - expose: 2222
      - expose: 3000
      - priority: 10

  db:
    name: gitea-db
    makejail: gh+AppJail-makejails/postgres
    priority: 98
    oci:
      environment:
        - PUID: 1000
        - PGID: 1000
        - POSTGRES_USER: gitea
        - POSTGRES_PASSWORD: gitea
        - POSTGRES_DB: gitea
    volumes:
      - db-data: /var/db/postgres
    options:
      - container: 'args:--pull'
      - template: !ENV '${PWD}/template.conf'

volumes:
  gitea-data:
    device: /var/appjail-volumes/gitea/data
  db-data:
    device: /var/appjail-volumes/gitea/postgres-data
```

**template.conf**:

```
exec.start: "/bin/sh /etc/rc"
exec.stop: "/bin/sh /etc/rc.shutdown jail"
mount.devfs
persist
sysvmsg: new
sysvsem: new
sysvshm: new
```

#### Startup

To start this setup based on `appjail-director`, execute `appjail-director up -p gitea`, to launch Gitea. Logs can be viewed with `appjail-director info -p info`.

To shut down the setup, execute `appjail-director down -dp gitea`. This will stop and kill the containers. The volumes will still exist.

**Example**:

```console
$ appjail-director up -p gitea
Starting Director (project:gitea) ...
Creating db (gitea-db) ... Done.
 - Configuring environment (OCI):
   - PUID ... Done.
   - PGID ... Done.
   - POSTGRES_USER ... Done.
   - POSTGRES_PASSWORD ... Done.
   - POSTGRES_DB ... Done.
Starting db (gitea-db) ... Done.
Creating server (gitea) ... Done.
 - Configuring environment (OCI):
   - PUID ... Done.
   - PGID ... Done.
   - SSH_PORT ... Done.
   - GITEA__database__DB_TYPE ... Done.
   - GITEA__database__HOST ... Done.
   - GITEA__database__NAME ... Done.
   - GITEA__database__USER ... Done.
   - GITEA__database__PASSWD ... Done.
Starting server (gitea) ... Done.
Finished: gitea
$ appjail-director info -p gitea
gitea:
 state: DONE
 last log: /home/user/.director/logs/2026-08-08_00h13m38s
 locked: false
 services:
  + server (gitea)
  + db (gitea-db)
$ ls ~/.director/logs/2026-08-08_00h13m38s/server/
makejail.log        oci-environment.log start.log
$ tail ~/.director/logs/2026-08-08_00h13m38s/server/start.log
gitea: created
ifconfig_eb_4e4319d98e5:  -> inet 10.0.0.8 netmask 255.192.0.0 broadcast 10.63.255.255
add net default: gateway 10.0.0.1
defaultrouter: NO -> 10.0.0.1
[00:00:07] [ debug ] [gitea] Running initscript `/usr/local/appjail/jails/gitea/init` ...
[00:00:07] [ debug ] [gitea] `/usr/local/appjail/jails/gitea/init` exits with status code 0
[00:00:08] [ debug ] [gitea] Executing the process specified by the container ...
[00:00:11] [ debug ] [gitea] Running: date +%Y-%m-%d.log
[00:00:11] [ debug ] [gitea] Executing: daemon -f -o "/var/log/appjail/jails/gitea/container/2026-08-08.log" -t "running gitea:appjail-gitea" -p "/usr/local/appjail/jails/gitea/conf/boot/oci/pid" /usr/local/libexec/appjail/jexec/jexec -l -d "/app" -e "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" -e "ASSUME_ALWAYS_YES=yes" -e "PUID=1000" -e "PGID=1000" -e "GITEA_CUSTOM=/data/gitea" -e "GITEA__database__DB_TYPE=postgres" -e "GITEA__database__HOST=gitea-db:5432" -e "GITEA__database__NAME=gitea" -e "GITEA__database__PASSWD=gitea" -e "GITEA__database__USER=gitea" -e "PGID=15000" -e "PUID=15000" -e "SSH_PORT=2222"  -- "gitea" "/entrypoint.sh" "goreman" "-rpc-server=false" "-f" "/Procfile" "start"
[00:00:11] [ info  ] [gitea] Detached: pid:46606, log:jails/gitea/container/2026-08-08.log
$ appjail logs tail jails/gitea/container/2026-08-08.log
00:14:49 gitea | 2026/08/08 00:14:49 cmd/web.go:115:showWebStartupMessage() [I] Gitea version: 1.26.4 built with go1.26.5-X:jsonv2 : pam, sqlite, sqlite_unlock_notify
00:14:49 gitea | 2026/08/08 00:14:49 cmd/web.go:116:showWebStartupMessage() [I] * RunMode: prod
00:14:49 gitea | 2026/08/08 00:14:49 cmd/web.go:117:showWebStartupMessage() [I] * AppPath: /usr/local/sbin/gitea
00:14:49 gitea | 2026/08/08 00:14:49 cmd/web.go:118:showWebStartupMessage() [I] * WorkPath: /usr/local/share/gitea
00:14:49 gitea | 2026/08/08 00:14:49 cmd/web.go:119:showWebStartupMessage() [I] * CustomPath: /data/gitea
00:14:49 gitea | 2026/08/08 00:14:49 cmd/web.go:120:showWebStartupMessage() [I] * ConfigFile: /data/gitea/conf/app.ini
00:14:49 gitea | 2026/08/08 00:14:49 cmd/web.go:121:showWebStartupMessage() [I] Prepare to run install page
00:14:49 gitea | 2026/08/08 00:14:49 cmd/web.go:329:listen() [I] Listen: http://0.0.0.0:3000
00:14:49 gitea | 2026/08/08 00:14:49 cmd/web.go:333:listen() [I] AppURL(ROOT_URL): http://localhost:3000/
00:14:49 gitea | 2026/08/08 00:14:49 modules/graceful/server.go:52:NewServer() [I] Starting new Web server: tcp:0.0.0.0:3000 on PID: 45603
```

**Note**: If using a non-3000 port on http, change app.ini to match `LOCAL_ROOT_URL = http://localhost:3000/`.

#### Installation

After starting the AppJail setup via `appjail-director`, Gitea should be available using a favorite browser to finalize the installation. Visit http://server-ip:3000 (from external hosts) or http://jail-ip:3000 (from the same host) and follow the installation wizard.

#### Configure the user inside Gitea using environment variables

* `PUID`: **1000**: The UID (Unix user ID) of the user that runs Gitea within the container.
* `PGID`: **1000**: The GID (Unix group ID) of the user that runs Gitea within the container.

#### Customization

Customization files described [here](https://docs.gitea.com/administration/customizing-gitea) should be placed in `/data/gitea` directory. The configuration file will be saved at `/data/gitea/conf/app.ini` after the installation.

Example: Analogous to the non-docker-installation customization linked above, you can create a `/public` folder within `/data/gitea` and place your custom `robots.txt` there which will then be served normally.

#### Upgrading

**WARNING**: Make sure you have volumed data to somewhere outside the container.

To upgrade your installation to the latest release:

```console
$ export DIRECTOR_PROJECT=gitea
$ appjail-director down -d && appjail-director up
```

#### Managing Deployments With Environment Variables

In addition to the environment variables above, any settings in `app.ini` can be set or overridden with an environment variable of the form: `GITEA__section_name__KEY_NAME=value`. These settings are applied each time the docker container starts by `environment-to-ini` command (a warpper of `gitea config edit-ini`), and won't be passed into Gitea's sub-processes. See `gitea config edit-ini --help` for more details.

These environment variables can be passed to the container in `appjail-director.yml`. The following example will enable an smtp mail server if the required env variables `GITEA__mailer__FROM`, `GITEA__mailer__HOST`, `GITEA__mailer__PASSWD` are set on the host or in a `.env` file in the same directory as `appjail-director.yml`.

The settings can be also set or overridden with the content of a file by defining an environment variable of the form: `GITEA__section_name__KEY_NAME__FILE` that points to a file.

```yaml
...
services:
  server:
    name: gitea
    makejail: gh+AppJail-makejails/gitea
    oci:
      environment:
        - GITEA__mailer__ENABLED: 'true'
        - GITEA__mailer__FROM: !ENV '${GITEA__mailer__FROM}'
        - GITEA__mailer__PROTOCOL: smtps
        - GITEA__mailer__SMTP_ADDR: !ENV '${GITEA__mailer__SMTP_ADDR}'
        - GITEA__mailer__SMTP_PORT: !ENV '${GITEA__mailer__SMTP_PORT}'
        - GITEA__mailer__USER: !ENV '${GITEA__mailer__USER}'
        - GITEA__mailer__PASSWD: !ENV '${GITEA__mailer__PASSWD}'
```

In `appjail-director`, you can use a `.env` file to define some environment variables that should not be included in `appjail-director.yml`. The only requirement is that you use the `!ENV` tag, as shown in the example above.

**.env**:

```dotenv
DIRECTOR_PROJECT=gitea
GITEA__mailer__FROM=GITEA__mailer__FROM not set
GITEA__mailer__SMTP_ADDR=GITEA__mailer__SMTP_ADDR not set
GITEA__mailer__SMTP_PORT=GITEA__mailer__SMTP_PORT not set
GITEA__mailer__USER=apikey
GITEA__mailer__PASSWD=GITEA__mailer__PASSWD not set
```

Gitea will generate new secrets/tokens for every new installation automatically and write them into the app.ini. If you want to set the secrets/tokens manually, you can use the following docker commands to use of Gitea's built-in [generate utility functions](https://docs.gitea.com/administration/command-line#generate). Do not lose/change your SECRET_KEY after the installation, otherwise the encrypted data can not be decrypted anymore.

The following commands will output a new `SECRET_KEY` and `INTERNAL_TOKEN` to `stdout`, which you can then place in your environment variables.

```console
$ SUFFIX=$(openssl rand -hex 6)
$ appjail oci run \
    -o ephemeral \
    ghcr.io/appjail-makejails/gitea gitea-$SUFFIX \
    gitea generate secret SECRET_KEY
$ appjail oci run \
    -o ephemeral \
    ghcr.io/appjail-makejails/gitea gitea-$SUFFIX \
    gitea generate secret INTERNAL_TOKEN && 
  appjail stop gitea-$SUFFIX
```

```yaml
...
services:
  server:
    name: gitea
    makejail: gh+AppJail-makejails/gitea
    oci:
      environment:
        - GITEA__security__SECRET_KEY=[value returned by generate secret SECRET_KEY]
        - GITEA__security__INTERNAL_TOKEN=[value returned by generate secret INTERNAL_TOKEN]
```

### Arguments (stage: build)

* `gitea_from` (default: `ghcr.io/appjail-makejails/gitea`): Location of OCI image. See also [OCI Configuration](#oci-configuration).
* `gitea_tag` (default: `latest`): OCI image tag. See also [OCI Configuration](#oci-configuration).


### Volumes

| Name | Owner | Group | Perm | Type | Mountpoint |
| --- | --- | --- | --- | --- | --- |
| appjail-263aca83a3-data | `${PUID}` | `${PGID}` | - | - | /data |

## OCI Configuration

```yaml
build:
  variants:
    - tag: 15.1
      containerfile: Containerfile
      aliases: ["latest"]
      default: true
      args:
        FREEBSD_RELEASE: "15.1"
        NO_PKGCLEAN: "1"
      cache_dirs: ["pkgcache0:/var/cache/pkg"]
```
