FROM ubuntu:24.04

# you can specify multiple platforms and build tools by separating them using a space
ENV ANDROID_PLATFORM_VERSIONS="35"
ENV ANDROID_BUILD_TOOL_VERSIONS="35.0.0"
ENV GRADLE_VERSION="8.12"
ENV NODE_VERSION="20.18.0"
ENV SDK_DOWNLOAD_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"

WORKDIR /root

# update and install packages
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get -y update && \
    apt-get -y install --no-install-recommends \
        apt-utils \
        curl \
        git \
        locales \
        openjdk-17-jdk-headless \
        unzip

# install android SDK
RUN	curl -SsL -o android-cmdline-tools.zip $SDK_DOWNLOAD_URL && \
    unzip -qq android-cmdline-tools.zip && \
    mkdir -p ./Android/cmdline-tools && \
    mv cmdline-tools ./Android/cmdline-tools/latest && \
    ./Android/cmdline-tools/latest/bin/sdkmanager --update && \
    echo "[Installing common packages]" && \
    yes | ./Android/cmdline-tools/latest/bin/sdkmanager "extras;android;m2repository" "extras;google;m2repository" && \
    echo "[Installing platforms]" && \
    for PLATFORM in $ANDROID_PLATFORM_VERSIONS; do yes | ./Android/cmdline-tools/latest/bin/sdkmanager "platforms;android-${PLATFORM}"; done && \
    echo "[Installing build tools]" && \
    for BUILDTOOL in $ANDROID_BUILD_TOOL_VERSIONS; do yes | ./Android/cmdline-tools/latest/bin/sdkmanager "build-tools;${BUILDTOOL}"; done && \
    echo "[Accepting licenses]" && \
    yes | ./Android/cmdline-tools/latest/bin/sdkmanager --licenses > /dev/null && \
    rm android-cmdline-tools.zip
ENV ANDROID_HOME="/root/Android"

# install gradle
RUN curl -SsL -o gradle.zip https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-all.zip && \
    mkdir -p /opt/gradle && \
    unzip -qq gradle.zip -d /opt/gradle && \
    rm gradle.zip
ENV PATH="${PATH}:/opt/gradle/gradle-${GRADLE_VERSION}/bin"

# install node, npm, npx
RUN curl -SsL -o /usr/local/sbin/n https://raw.githubusercontent.com/tj/n/master/bin/n && \
    chmod 755 /usr/local/sbin/n && \
    n ${NODE_VERSION}

WORKDIR /