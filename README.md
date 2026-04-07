# Container to copy meteo data files

A set of data files containing meteorological data measured at the SMEAR Estonia station are updated every 10 minutes. This container takes care to transfer these files to the smear.emu.ee webserver where these are shown as online data.

## Task description 

This project packages the file transfer workflow into a small Docker container. The container starts an SSH agent, loads the configured private key if it is available, and runs a cron job in the foreground so the process stays alive inside Docker.

At each scheduled run, the `cpweather.sh` script opens an SFTP session to `smear.emu.ee` and uploads the latest weather data files from `/home/transfer/DataLog/` into the website directory on the remote server. The upload list is defined in `copyWeatherToWebServer` and currently includes:

- `weather.csv`
- `lgr*.csv`
- `thermo*.csv`
- `wind30m.csv`

In short, the repository provides an automated and repeatable way to publish updated meteorological measurements from the local data source to the public web server without requiring a manually maintained transfer environment.

## Dockerfile description

The Dockerfile builds a small Debian Bookworm based image for scheduled file transfer tasks. During build time it installs the required runtime tools, mainly `openssh-client` for SFTP access and `cron` for periodic execution.

It also creates a `transfer` user and sets `/home/transfer` as the working directory. The transfer scripts are copied into that directory, the container entrypoint script is installed into `/usr/local/bin/`, and the SSH host key for `smear.emu.ee` is added to `known_hosts` so the connection can be validated without an interactive prompt.

Instead of relying on an external cron configuration file, the Dockerfile writes the cron entry directly into `/etc/cron.d/meteo-upload`. That job runs `cpweather.sh` every 10 minutes and appends the output to `/var/log/meteo-upload.log`.

At runtime, the entrypoint starts an SSH agent and loads a private key if one is available in the container. After that, the container launches `cron -f`, which keeps cron in the foreground so the container stays alive and continues to perform the scheduled uploads.

## Build

Build the image from the repository root with either Podman or Docker:

```bash
podman build -t sftp-meteo .
```

```bash
docker build -t sftp-meteo .
```

If needed, you can also override the image user identifiers during build time:

```bash
podman build \
      --build-arg USER=transfer \
      --build-arg UID=1000 \
      --build-arg GID=1000 \
      -t sftp-meteo .
```

## Container usage

The container can be started using podman (or docker), it is recommended to provide the private key only on runtime startup so it is not copied into the container. 

```bash
podman run -d --name meteo-upload \ 
      -v /path/to/data:/home/transfer/DataLog \
      -v "/path/to/.ssh:/root/.ssh:ro" \
      sftp-meteo
```
In the current version the cron job started as root and attempts to run the cron job as user led to the problem that cron could not create it's pid file:

```bash
cron: can't open or create /var/run/crond.pid: Permission denied
```
It is also beneficial to populate the .ssh folder intended to use with the container with a known_hosts file using

```bash
ssh-keyscan -t rsa,ecdsa,ed25519 name.ofyour.server >> .ssh/known_hosts
```
if you didn't use the .ssh folder where you already had connected to this server. That prevents the sftp call to wait for manual input to accept the connection.



