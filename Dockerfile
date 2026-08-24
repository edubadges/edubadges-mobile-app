# syntax=docker/dockerfile:1
#
# Edubadges web app.
#
#   docker build --build-arg APP_FLAVOR=acc -t edubadges-web:acc .
#   docker run --rm -p 8080:8080 edubadges-web:acc
#
# The image is nginx plus the compiled web app: no application server, no
# database, no secrets. It listens on 8080 as a non-root user and expects TLS to
# terminate on the reverse proxy in front of it.
#
# Flavor is a build argument rather than a runtime one because the flavor is
# compiled into the bundle. One flavor per image, four images per release.

ARG FLUTTER_VERSION=3.41.3
ARG FLUTTER_CHANNEL=stable

# --- Build stage -------------------------------------------------------------
# Flutter is installed from Google's official release tarball rather than a
# third-party Flutter image, so the only external dependencies are Debian and
# storage.googleapis.com.
#
# Pinned to linux/amd64 because Google publishes the Linux SDK for x64 only.
# This costs emulation time when building on an Apple Silicon machine, but the
# compiled web output is just files - architecture-independent - so the runtime
# stage below stays native to whatever host builds or runs it.
ARG BUILD_PLATFORM=linux/amd64
FROM --platform=${BUILD_PLATFORM} debian:bookworm-slim AS build

ARG FLUTTER_VERSION
ARG FLUTTER_CHANNEL
ARG APP_FLAVOR

RUN test -n "${APP_FLAVOR}" || { \
      echo "error: --build-arg APP_FLAVOR=<dev|tst|acc|prod> is required" >&2; \
      exit 1; \
    }

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
         ca-certificates curl git unzip xz-utils python3 \
    && rm -rf /var/lib/apt/lists/*

# The SDK tarball is around a gigabyte, so retry rather than failing the whole
# build on a dropped connection. HTTP/1.1 avoids intermittent HTTP/2 stream
# resets seen against storage.googleapis.com on long transfers.
RUN curl -fsSL --http1.1 --retry 5 --retry-delay 5 --retry-all-errors \
      -o /tmp/flutter.tar.xz \
      "https://storage.googleapis.com/flutter_infra_release/releases/${FLUTTER_CHANNEL}/linux/flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz" \
    && tar -xf /tmp/flutter.tar.xz -C /opt \
    && rm /tmp/flutter.tar.xz

ENV PATH="/opt/flutter/bin:${PATH}"

RUN git config --global --add safe.directory /opt/flutter \
    && flutter config --no-analytics \
    && flutter --version

WORKDIR /app
COPY . .

RUN flutter pub get

# Both scripts are the same ones used by CI and by anyone building by hand, so
# the image cannot be built with different flags than a local build.
RUN ./tool/build_web.sh "${APP_FLAVOR}" \
    && ./tool/render_nginx_conf.sh "${APP_FLAVOR}" > /app/default.conf

# --- Runtime stage -----------------------------------------------------------
# nginx-unprivileged runs as uid 101 and listens on 8080 without needing any
# capabilities, which is what lets this run under a restrictive pod policy.
FROM nginxinc/nginx-unprivileged:stable-alpine AS runtime

ARG APP_FLAVOR
LABEL org.opencontainers.image.title="Edubadges web" \
      org.opencontainers.image.description="Edubadges Flutter web app served by nginx" \
      org.opencontainers.image.vendor="SURF" \
      nl.edubadges.flavor="${APP_FLAVOR}"

COPY --from=build /app/build/web /usr/share/nginx/html
COPY --from=build /app/default.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -q -O /dev/null http://127.0.0.1:8080/health || exit 1
