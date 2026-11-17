FROM ubuntu:24.04

ARG RUNNER_VERSION=2.338.2
ARG RUNNER_SHA256=baebf204307bac6193480852732f0aba2ae97b6c5597c244f4d5558390147c40
ARG ANDROID_CMDLINE_TOOLS=13114758

ENV DEBIAN_FRONTEND=noninteractive \
    ANDROID_HOME=/opt/android-sdk \
    ANDROID_SDK_ROOT=/opt/android-sdk

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl git unzip zip jq openssh-client openjdk-21-jdk-headless \
        libfontconfig1 libfreetype6 fonts-dejavu-core libx11-6 libxext6 libxrender1 libxi6 libxtst6 libgl1 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -s /bin/bash runner

RUN mkdir -p "$ANDROID_HOME/cmdline-tools" \
    && curl -fsSLo /tmp/tools.zip "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMDLINE_TOOLS}_latest.zip" \
    && unzip -q /tmp/tools.zip -d "$ANDROID_HOME/cmdline-tools" \
    && mv "$ANDROID_HOME/cmdline-tools/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest" \
    && rm /tmp/tools.zip \
    && yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" --licenses > /dev/null \
    && "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" "platform-tools" > /dev/null \
    && chown -R runner:runner "$ANDROID_HOME"

WORKDIR /home/runner/actions-runner
RUN curl -fsSLo runner.tgz "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" \
    && echo "${RUNNER_SHA256}  runner.tgz" | sha256sum -c - \
    && tar xzf runner.tgz \
    && rm runner.tgz \
    && apt-get update \
    && ./bin/installdependencies.sh \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /home/runner/.gradle /home/runner/actions-runner/_work \
    && chown -R runner:runner /home/runner

COPY --chown=runner:runner entrypoint.sh /home/runner/entrypoint.sh
RUN chmod +x /home/runner/entrypoint.sh

USER runner
ENV PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
ENTRYPOINT ["/home/runner/entrypoint.sh"]
