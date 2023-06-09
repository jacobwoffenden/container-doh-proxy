FROM docker.io/alpine:3.18.0

ARG BUILD_CREATED
ARG BUILD_VERSION
ARG BUILD_REVISION
ARG CLOUDFLARED_VERSION

LABEL com.cloudflare.cloudflared.version="${CLOUDFLARED_VERSION}"
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
LABEL io.artifacthub.package.alternative-locations="docker.io/jacobwoffenden/doh-proxy,quay.io/jacobwoffenden/doh-proxy"

COPY src/root/build.sh /root/build.sh
COPY src/usr/local/bin/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY src/usr/local/bin/healthcheck.sh /usr/local/bin/healthcheck.sh
COPY src/etc/doh-proxy/providers.json /etc/doh-proxy/providers.json

RUN sh /root/build.sh

USER doh-proxy

HEALTHCHECK --interval=5s --timeout=5s --start-period=5s CMD [ "/usr/local/bin/healthcheck.sh" ]

EXPOSE 53/udp
EXPOSE 9100/tcp

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
