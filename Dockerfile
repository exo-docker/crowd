FROM azul/zulu-openjdk-alpine:8u514-8.98

LABEL maintainer="Giovanni Silva <giovanni@atende.info>"

ENV SOFTWARE_NAME=crowd \
    SOFTWARE_VERSION=2.8.0 \
    SOFTWARE_PORT=8095

# Runtime tools: bash (scripts), curl (download + healthcheck), su-exec (drop
# privileges), tini (PID 1, signal forwarding), tar, patch (deployments patch
# conf/server.xml, e.g. root Context).
RUN apk add --no-cache bash curl su-exec tini tar patch

# --- Application (changes when the Crowd version is bumped) --------------------
COPY install.sh /root/install.sh
COPY scripts/install_impl.sh /root/scripts/install_impl.sh
RUN chmod +x /root/install.sh /root/scripts/install_impl.sh && /root/install.sh

# --- Runtime (scripts change most often, so they come last) --------------------
COPY run.sh /run.sh
COPY scripts/run_impl.sh /root/scripts/run_impl.sh
# Compatibility shim: deployments call `/sbin/my_init` (phusion baseimage) from
# their compose `command`, e.g. `sh -c "/opt/crowd/build.sh && /sbin/my_init"`.
RUN chmod +x /run.sh && \
    printf '#!/bin/sh\nexec /sbin/tini -- /run.sh "$@"\n' > /sbin/my_init && \
    chmod +x /sbin/my_init

VOLUME /opt/crowd-home
EXPOSE 8095

# Crowd takes a while to boot; give it room before marking it unhealthy.
HEALTHCHECK --interval=30s --timeout=5s --start-period=180s --retries=5 \
  CMD curl -fsL -o /dev/null "http://localhost:${SOFTWARE_PORT}/crowd/" || exit 1

CMD ["/sbin/my_init"]
