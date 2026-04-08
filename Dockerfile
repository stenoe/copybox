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
    ssh-keyscan -t rsa,ecdsa,ed25519 smear.emu.ee >> .ssh/known_hosts \
    mkdir -p /var/log && \
    touch /var/log/meteo-upload.log

RUN printf '%s\n' \
    'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' \
    echo "*/10 * * * * root /home/${USER}/cpweather.sh >> /var/log/meteo-upload.log 2>&1" \
    > /etc/cron.d/meteo-upload && \
    chmod 0644 /etc/cron.d/meteo-upload

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Ensure the cron daemon runs in the foreground (required for containers)
CMD ["cron","-f"]

