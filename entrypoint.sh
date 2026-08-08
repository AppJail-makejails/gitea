#!/bin/sh

. /lib.subr

set -e

create_user

change_owner /app
change_owner /data

for FOLDER in /data/gitea/conf /data/gitea/log /data/git /data/ssh; do
    if [ -d "${FOLDER}" ]; then
        continue
    fi

    mkdir -p "${FOLDER}"
done

/init-gitea
/init-sshd

exec "$@"
