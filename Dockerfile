FROM ubuntu:focal

LABEL maintainer="phoenix-1708 <harikumar1708@gmail.com>"


ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV JAVA_OPTS=" -Xmx7G "
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=~/bin:/usr/local/bin:/home/cirrust/bin:$PATH

# Install all required packages
RUN apt-get update -q -y \
  && apt-get install -q -y --no-install-recommends \
    # Core Apt Packages
    apt-utils apt-transport-https python3-apt \
    # Linux Standard Base Packages
    sudo git ffmpeg maven nodejs ca-certificates-java pigz tar rsync rclone aria2 adb autoconf automake axel bc bison build-essential ccache lsb-core lsb-security ca-certificates systemd udev \
    # Upload/Download/Copy/FTP utils
    git curl wget wput axel rsync \
    # GNU and other core tools/utils
    binutils coreutils bsdmainutils util-linux patchutils libc6-dev sudo \
    # Security CLI tools
    ssh openssl libssl-dev sshpass gnupg2 gpg \
    # Tools for interacting with an Android platform
    android-sdk-platform-tools adb fastboot squashfs-tools \
    # OpenJDK8 as Java Runtime
    openjdk-8-jdk ca-certificates-java \
    maven nodejs \
    # Python packages
    python-all-dev python3-dev python3-requests \
    # Compression tools/utils/libraries
    zip unzip lzip lzop zlib1g-dev xzdec xz-utils pixz p7zip-full p7zip-rar zstd libzstd-dev lib32z1-dev \
    # GNU C/C++ compilers and Build Systems
    build-essential gcc gcc-multilib g++ g++-multilib \
    # make system and stuff
    clang llvm lld cmake automake autoconf \
    # XML libraries and stuff
    libxml2 libxml2-utils xsltproc expat re2c \
    # Developer's Libraries for ncurses
    ncurses-bin libncurses5-dev lib32ncurses5-dev bc libreadline-gplv2-dev libsdl1.2-dev libtinfo5 python-is-python2 ninja-build libcrypt-dev\
    # Misc utils
    file gawk xterm screen rename tree schedtool software-properties-common \
    dos2unix jq flex bison gperf exfat-utils exfat-fuse libb2-dev pngcrush imagemagick optipng advancecomp \
    # LTS specific Unique packages
    ${UNIQ_PACKAGES} \
    # Additional
    kmod \
  && unset UNIQ_PACKAGES \
  # Remove useless jre
  && apt-get -y purge default-jre-headless openjdk-11-jre-headless \
  # Show installed packages
  && apt list --installed \
  # Clean useless apt cache
  && apt-get -y clean && apt-get -y autoremove \
  && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* \
  && dpkg-divert --local --rename /usr/bin/ischroot && ln -sf /bin/true /usr/bin/ischroot \
  && chmod u+s /usr/bin/screen && chmod 755 /var/run/screen \
  && echo "Set disable_coredump false" >> /etc/sudo.conf

WORKDIR /home

RUN set -xe \
  && mkdir /home/cirrus/bin \
  && curl -sL https://gerrit.googlesource.com/git-repo/+/refs/heads/stable/repo?format=TEXT | base64 --decode  > /home/cirrus/bin/repo \
  && curl -s https://api.github.com/repos/tcnksm/ghr/releases/latest \
    | jq -r '.assets[] | select(.browser_download_url | contains("linux_amd64")) | .browser_download_url' | wget -qi - \
  && tar -xzf ghr_*_amd64.tar.gz --wildcards 'ghr*/ghr' --strip-components 1 \
  && mv ./ghr /home/cirrus/bin/ && rm -rf ghr_*_amd64.tar.gz \
  && chmod a+rx /home/cirrus/bin/repo \
  && chmod a+x /home/cirrus/bin/ghr

WORKDIR /home/cirrus

RUN set -xe \
  && mkdir -p extra && cd extra \
  && wget -q https://ftp.gnu.org/gnu/make/make-4.3.tar.gz \
  && tar xzf make-4.3.tar.gz \
  && cd make-*/ \
  && ./configure && bash ./build.sh 1>/dev/null && install ./make /usr/local/bin/make \
  && cd .. \
  && git clone https://github.com/ccache/ccache.git \
  && cd ccache && git checkout -q v4.2 \
  && mkdir build && cd build \
  && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr .. \
  && make -j8 && make install \
  && cd ../../.. \
  && rm -rf extra

# Set up udev rules for adb
RUN set -xe \
  && curl --create-dirs -sL -o /etc/udev/rules.d/51-android.rules -O -L https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules \
  && chmod 644 /etc/udev/rules.d/51-android.rules \
  && chown root /etc/udev/rules.d/51-android.rules

RUN CCACHE_DIR=/tmp/ccache ccache -M 5G \
  && chown cirrus:cirrus /tmp/ccache

USER cirrus

VOLUME ["/home/cirrus", "/tmp/ccache", "/tmp/rom"]
