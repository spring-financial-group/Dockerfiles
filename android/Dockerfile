FROM jx3mqubebuild.azurecr.io/docker-io/library/node:20.18

# Install required dependencies
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables for Android SDK
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH="${JAVA_HOME}/bin:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/emulator:${ANDROID_SDK_ROOT}/cmdline-tools/bin:${PATH}"

# Install Android SDK command-line tools
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools \
    && cd $ANDROID_SDK_ROOT/cmdline-tools \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-10406996_latest.zip -O android-sdk.zip \
    && unzip android-sdk.zip \
    && mv cmdline-tools latest \
    && rm android-sdk.zip

# Accept Android SDK licenses
RUN yes | sdkmanager --licenses

# Install required Android SDK components (API 35, Extension Level 7)
RUN sdkmanager --install "platform-tools" \
    "platforms;android-35" \
    "build-tools;35.0.0" \
    "cmdline-tools;latest"

# Install Gradle 8.13
RUN wget -q https://services.gradle.org/distributions/gradle-8.13-bin.zip -O /tmp/gradle.zip \
    && unzip /tmp/gradle.zip -d /opt/ \
    && rm /tmp/gradle.zip \
    && ln -s /opt/gradle-8.13/bin/gradle /usr/local/bin/gradle

# Install Ruby required for Fastlane deployment
RUN apt update && apt install -y ruby ruby-dev
RUN export LC_ALL=UTF-8
RUN export LANG=UTF-8

# Install Fastlane and google cli tools
RUN apt install build-essential
RUN gem install google-api-client
RUN gem install fastlane
RUN export PATH="/opt/homebrew/lib/ruby/gems/3.4.0/bin/:$PATH"

# Verify installations
RUN node -v && npm -v && java -version && gradle -v && sdkmanager --list
