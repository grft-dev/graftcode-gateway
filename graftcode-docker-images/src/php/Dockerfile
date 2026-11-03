# gg hosts user code in its bundled libphp.so (PHP 8.4, ZTS, embed SAPI).
# The runtime image has no system PHP: distro NTS extensions cannot load into that libphp.
# php.ini is the Ubuntu 8.4 CLI file (memory_limit=-1) and PHPRC points at its directory.
# gg and the Hypertube native libs need libssl3, zlib, libuuid and libstdc++.
 
FROM ubuntu:22.04 AS php-ini
 
ARG DEBIAN_FRONTEND=noninteractive
 
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
    && curl -fsSL -o /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb \
    && dpkg -i /tmp/debsuryorg-archive-keyring.deb \
    && echo "deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ jammy main" > /etc/apt/sources.list.d/php.list \
    && apt-get update && apt-get install -y --no-install-recommends \
        php8.4-cli \
    && rm -f /tmp/debsuryorg-archive-keyring.deb \
    && rm -rf /var/lib/apt/lists/*
 
FROM ubuntu:22.04
 
LABEL org.opencontainers.image.title="Graftcode Gateway PHP"
LABEL org.opencontainers.image.description="PHP 8.4 image with Graftcode Gateway preinstalled"
LABEL org.opencontainers.image.source="https://github.com/grft-dev/graftcode-docker-images"
LABEL org.opencontainers.image.url="https://hub.docker.com/r/graftcode/php"
LABEL org.opencontainers.image.vendor="grft-dev"
LABEL org.opencontainers.image.licenses="MIT"
 
ARG DEBIAN_FRONTEND=noninteractive
 
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        wget \
        libssl3 \
        zlib1g \
        libuuid1 \
        libstdc++6 \
    && rm -rf /var/lib/apt/lists/*
 
RUN wget -O /tmp/gg.deb \
      https://github.com/grft-dev/graftcode-gateway/releases/latest/download/gg_linux_amd64.deb && \
    dpkg -i /tmp/gg.deb && \
    rm /tmp/gg.deb
 
COPY --from=php-ini /etc/php/8.4/cli/php.ini /etc/graftcode/php/php.ini
ENV PHPRC=/etc/graftcode/php
 
EXPOSE 80
 
CMD ["gg"]