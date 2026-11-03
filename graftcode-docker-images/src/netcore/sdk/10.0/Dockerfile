FROM mcr.microsoft.com/dotnet/sdk:10.0

LABEL org.opencontainers.image.title="Graftcode Gateway .NET"
LABEL org.opencontainers.image.description=".NET 10 image with Graftcode Gateway preinstalled"
LABEL org.opencontainers.image.source="https://github.com/grft-dev/graftcode-docker-images"
LABEL org.opencontainers.image.url="https://hub.docker.com/r/graftcode/netcore"
LABEL org.opencontainers.image.vendor="grft-dev"
LABEL org.opencontainers.image.licenses="MIT"

RUN wget -O /tmp/gg.deb \
      https://github.com/grft-dev/graftcode-gateway/releases/latest/download/gg_linux_amd64.deb && \
    dpkg -i /tmp/gg.deb && \
    rm /tmp/gg.deb

EXPOSE 80

CMD ["gg"]