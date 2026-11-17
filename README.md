# actions-runner

A self-hosted GitHub Actions runner in a Docker container, with the Android command-line tools and a JDK, registered for the `adukilabs` organisation.

## Set up

1. Put the registration token in `.env` as `RUNNER_TOKEN`. It is the value after `--token` in the `./config.sh` line GitHub shows under the organisation's Settings, Actions, Runners, New self-hosted runner. It is valid for one hour and used once. `.env` is git-ignored; never commit or share it.
2. Build and start:

   ```bash
   docker compose up -d --build
   docker compose logs -f
   ```

The log ends with "Listening for Jobs" when the runner is online.

## Day to day

- `docker compose restart`, `docker compose stop`, `docker compose start`, `docker compose ps`, `docker compose logs -f`.
- The container restarts with Docker (`restart: unless-stopped`).
- The registration lives inside the container. `stop`, `start` and `restart` keep it. `docker compose down` or `up --force-recreate` deletes the container, and the next `up` needs a fresh token in `.env`.
- Gradle caches, the work folder and the Android SDK are in the volumes `actions-runner_gradle`, `actions-runner_work` and `actions-runner_sdk`; they survive `down` unless you pass `-v`.

## Versions

`RUNNER_VERSION`, `RUNNER_SHA256` and `ANDROID_CMDLINE_TOOLS` are build arguments at the top of the `Dockerfile`; the checksum is the one GitHub shows next to the download. The runner updates itself while running; rebuild with a newer version and checksum when recreating the container.
