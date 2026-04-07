FROM debian:bookworm-slim
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openssh-client rsync cron ca-certificates nano && \
    rm -rf /var/lib/apt/lists/*

ARG USER=transfer
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} ${USER} && \
    useradd -m -u ${UID} -g ${GID} -s /bin/bash ${USER}

WORKDIR /home/${USER}
COPY --chown=root:root .ssh/id_rsa.pub .ssh/
COPY --chown=root:root scripts/ ./
COPY --chown=root:root scripts/docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh && \
    ssh-keyscan -t rsa,ecdsa,ed25519 smear.emu.ee >> .ssh/known_hosts

# Install the cron job file (one‑line format)
# COPY --chown=${USER}:${USER} cronjob /etc/cron.d/meteo-upload
# COPY --chown=root:root cronjob /etc/cron.d/meteo-upload
# Give cron the right permissions (must be 0644)
# RUN chmod 0644 /etc/cron.d/meteo-upload && \
#     crontab /etc/cron.d/meteo-upload

RUN echo "*/10 * * * * root /home/${USER}/cpweather.sh >> /var/log/meteo-upload.log 2>&1" \
    > /etc/cron.d/meteo-upload && \
    chmod 0644 /etc/cron.d/meteo-upload


# USER ${USER}
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
# CMD ["sleep","infinity"]

# Ensure the cron daemon runs in the foreground (required for containers)
CMD ["cron","-f"]

