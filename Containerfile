FROM docker.io/alpine:3

ARG BUILD_CREATED
ARG BUILD_VERSION
ARG BUILD_REVISION
ARG CLOUDFLARED_VERSION="2022.2.0"
ARG CLOUDFLARED_CHECKSUM_AMD64="2becd546616fda7adf8c3153306b58067751e09a3b5f8223bcd6c9b21e57c43a"
ARG CLOUDFLARED_CHECKSUM_ARM64="e1e358d393cf2cb89a45e0fcdb32f0c6668827c2de874ac9930bab116c2fc52c"

LABEL io.woffenden.app.doh-proxy.version="${CLOUDFLARED_VERSION}"
LABEL org.opencontainers.image.created="${BUILD_CREATED}"
LABEL org.opencontainers.image.version="${BUILD_VERSION}" 
LABEL org.opencontainers.image.revision="${BUILD_REVISION}"
LABEL org.opencontainers.image.url="https://github.com/jacobwoffenden/container-doh-proxy"
LABEL org.opencontainers.image.source="https://github.com/jacobwoffenden/container-doh-proxy"
LABEL org.opencontainers.image.vendor="Jacob Woffenden"
LABEL org.opencontainers.image.title="doh-proxy"
LABEL org.opencontainers.image.description="A multi-arch container to proxy DNS over HTTPS providers such as Cloudflare and Google"
LABEL org.opencontainers.image.documentation="https://github.com/jacobwoffenden/container-doh-proxy"
LABEL org.opencontainers.image.authors="Jacob Woffenden (jacob@woffenden.io)"
LABEL org.opencontainers.image.licenses="MIT"
LABEL io.artifacthub.package.readme-url="https://raw.githubusercontent.com/jacobwoffenden/container-doh-proxy/main/README.md"
LABEL io.artifacthub.package.alternative-locations="docker.io/jacobwoffenden/doh-proxy"

COPY src/root/build.sh /root/build.sh
COPY src/usr/local/bin/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY src/usr/local/bin/healthcheck.sh /usr/local/bin/healthcheck.sh
COPY src/etc/doh-proxy/providers.json /etc/doh-proxy/providers.json

RUN sh /root/build.sh

USER doh-proxy

HEALTHCHECK --interval=5s --timeout=5s --start-period=5s CMD [ "/usr/local/bin/healthcheck.sh" ]

EXPOSE 5053/udp
EXPOSE 9100/tcp

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
