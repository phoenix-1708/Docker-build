# Copyright (c) 2016-022 Crave.io Inc. All rights reserved
FROM accupara/ubuntu:18.04

RUN set -x \
 && sudo apt-get update \
 && sudo apt-get -y dist-upgrade \
 && sudo apt-get -y install \
    bison \
    build-essential \
    curl \
    flex \
    g++-multilib \
    gcc-multilib \
    gnupg \
    gperf \
    lib32ncurses5-dev \
    libncurses5-dev \
    libncurses5 \
    lib32z-dev \
    libc6-dev-i386 \
    libgl1-mesa-dev \
    libx11-dev \
    libxml2-utils \
    unzip \
    x11proto-core-dev \
    xsltproc \
    zip \
    zlib1g-dev \
    libfreetype6 \
    brotli \
    openjdk-11-jdk \
    ccache \
    wget \
    pigz \
# Get the latest version of repo
 && curl https://storage.googleapis.com/git-repo-downloads/repo >/tmp/repo \
 && sudo mkdir /opt/aosp \
 && sudo chown admin:admin /opt/aosp \
 && sudo mv /tmp/repo /usr/bin/repo \
 && sudo chmod +x /usr/bin/repo \
# Remove python 2 completely
 && sudo apt-get purge -y python python2.7 \
 && sudo apt-get -y autoremove \
# Use python3 as the default python
 && sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
# Make sure that the default version of python is 3
 && if [ $(python --version | grep -c 'Python 3') -eq "0" ] ; then exit 1 ; fi \
# Final cleanups
 && sudo apt-get clean \
 && sudo rm -f /var/lib/apt/lists/*_dists_*
