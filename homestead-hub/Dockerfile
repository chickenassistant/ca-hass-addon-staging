# The addon extends the main Chicken Assistant core image. Supervisor fills in
# BUILD_FROM from build.yaml when building locally; CI passes it explicitly.
ARG BUILD_FROM=ghcr.io/chickenassistant/core:latest
FROM ${BUILD_FROM}

# jq parses /data/options.json; curl queries the Supervisor API for the
# Mosquitto add-on credentials in run.sh.
RUN apt-get update \
    && apt-get install -y --no-install-recommends jq curl \
    && rm -rf /var/lib/apt/lists/*

COPY run.sh /run.sh
RUN chmod +x /run.sh

# Override the core entrypoint so HA options are translated into env vars
# before the server starts.
ENTRYPOINT []
CMD ["/run.sh"]
