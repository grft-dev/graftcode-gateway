# graftcode-docker-images

`graftcode-docker-images` is a public repository of Dockerfiles for official Graftcode Gateway container images.

## Overview

This repository provides source Dockerfiles for official Docker Hub images that include Graftcode Gateway preinstalled. Each image downloads the latest `gg_linux_amd64.deb` installer from the `graftcode-gateway` GitHub Releases.

## Images in this repo

| Image | Base image | Docker Hub repository | Tags |
|---|---|---|---|
| Java | `eclipse-temurin` | `graftcode/eclipse-temurin` | `17-jdk`, `21-jdk`, `latest` |
| .NET | `mcr.microsoft.com/dotnet/sdk` | `graftcode/netcore` | `9.0`, `10.0`, `latest` |
| Node.js | `node:22` | `graftcode/node` | `22`, `latest` |
| Python | `python:3.12-slim` | `graftcode/python` | `3.12`, `latest` |
| PHP | `php:8.4-cli-bookworm` | `graftcode/php` | `8.4`, `latest` |
| Ruby | `ruby:3.3` | `graftcode/ruby` | `3.3`, `latest` |

## Pull official images

Use the public Docker Hub repositories and tags below:

```bash
docker pull graftcode/eclipse-temurin:17-jdk
docker pull graftcode/eclipse-temurin:21-jdk
docker pull graftcode/eclipse-temurin:latest
docker pull graftcode/netcore:latest
docker pull graftcode/netcore:9.0
docker pull graftcode/netcore:10.0
docker pull graftcode/node:22
docker pull graftcode/node:latest
docker pull graftcode/python:3.12
docker pull graftcode/python:latest
docker pull graftcode/php:8.4
docker pull graftcode/php:latest
docker pull graftcode/ruby:3.3
docker pull graftcode/ruby:latest
```

## Run an image

Example:

```bash
docker run --rm -p 80:80 -p 81:81 -e GC_PROJECT_KEY="$GC_PROJECT_KEY" graftcode/eclipse-temurin:21-jdk
```

Gateway listens on port `80` (WebSocket) by default. Graftcode Vision HTTP uses port `81`. Set `GC_PROJECT_KEY` when connecting to the portal.

## Image purpose

Each image is built to run the `gg` binary from Graftcode Gateway and expose port `80` by default. This repository is intended as the public source for these Docker image definitions.

## OCI metadata

All images include standard OCI labels:

- `org.opencontainers.image.title`
- `org.opencontainers.image.description`
- `org.opencontainers.image.source`
- `org.opencontainers.image.url`
- `org.opencontainers.image.vendor`
- `org.opencontainers.image.licenses`

## Build locally (optional)

If you want to rebuild an image locally, run from the repository root:

```bash
docker build -f src/java/17-jdk/Dockerfile -t graftcode/eclipse-temurin:17-jdk .
docker build -f src/java/21-jdk/Dockerfile -t graftcode/eclipse-temurin:21-jdk .
docker build -f src/java/21-jdk/Dockerfile -t graftcode/eclipse-temurin:latest .
docker build -f src/netcore/sdk/10.0/Dockerfile -t graftcode/netcore:10.0 .
docker build -f src/netcore/sdk/10.0/Dockerfile -t graftcode/netcore:latest .
docker build -f src/netcore/sdk/9.0/Dockerfile -t graftcode/netcore:9.0 .
docker build -f src/nodejs/Dockerfile -t graftcode/node:22 .
docker build -f src/nodejs/Dockerfile -t graftcode/node:latest .
docker build -f src/python/Dockerfile -t graftcode/python:3.12 .
docker build -f src/python/Dockerfile -t graftcode/python:latest .
docker build -f src/php/Dockerfile -t graftcode/php:8.4 .
docker build -f src/php/Dockerfile -t graftcode/php:latest .
docker build -f src/ruby/Dockerfile -t graftcode/ruby:3.3 .
docker build -f src/ruby/Dockerfile -t graftcode/ruby:latest .
```

Replace the Dockerfile and tag for the image you want.

## License

This repository is published under the terms of the included `LICENSE` file.
