ARG FREEBSD_RELEASE

FROM ghcr.io/appjail-makejails/core:${FREEBSD_RELEASE}

ARG NO_PKGCLEAN

LABEL org.opencontainers.image.title="Gitea" \
    org.opencontainers.image.description="Compact self-hosted Git service" \
    org.opencontainers.image.source="https://github.com/AppJail-makejails/gitea" \
    org.opencontainers.image.url="https://github.com/AppJail-makejails/gitea" \
    org.opencontainers.image.vendor="DtxdF" \
    org.opencontainers.image.authors="Jesús Daniel Colmenares Oviedo <dtxdf@disroot.org>"

RUN set -xe; \
    \
    pkg update; \
    pkg install gitea goreman gettext-runtime FreeBSD-ssh; \
    \
    if [ -z "${NO_PKGCLEAN}" ]; then \
        pkg clean -a; \
        rm -rf /var/cache/pkg/*; \
    fi; \
    rm -rf /var/db/pkg/repos/*

EXPOSE 22 3000

ENV GITEA_CUSTOM=/data/gitea

VOLUME ["/data"]

COPY entrypoint.sh environment-to-ini init-gitea init-sshd /

RUN chmod +x /entrypoint.sh /environment-to-ini /init-gitea /init-sshd

COPY Procfile /

RUN mkdir -p /app /data

COPY templates /templates

WORKDIR /app

ENTRYPOINT ["/entrypoint.sh"]
CMD ["goreman", "-rpc-server=false", "-f", "/Procfile", "start"]
