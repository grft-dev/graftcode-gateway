FROM eclipse-temurin:21-jdk

LABEL org.opencontainers.image.title="Graftcode Gateway Java"
LABEL org.opencontainers.image.description="Java 21 image with Graftcode Gateway preinstalled"
LABEL org.opencontainers.image.source="https://github.com/grft-dev/graftcode-docker-images"
LABEL org.opencontainers.image.url="https://hub.docker.com/r/graftcode/eclipse-temurin"
LABEL org.opencontainers.image.vendor="grft-dev"
LABEL org.opencontainers.image.licenses="MIT"

ARG GG_VERSION=1.4.10
RUN apt-get update && apt-get install -y --no-install-recommends wget ca-certificates \
    && wget -O /tmp/gg.deb \
      "https://github.com/grft-dev/graftcode-gateway/releases/download/v${GG_VERSION}/gg_linux_amd64.deb" \
    && dpkg -i --force-overwrite /tmp/gg.deb \
    && rm /tmp/gg.deb \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 80

CMD ["gg"]
