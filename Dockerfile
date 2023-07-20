FROM ubuntu:latest

ARG S6_OVERLAY_VERSION=v3.1.5.0
ARG ARIA2_VERSION=1.36.0

ARG OVERLAY_URL_BASE="https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}"
ARG ARIA2_URL_BASE="https://github.com/P3TERX/Aria2-Pro-Core/releases/download/${ARIA2_VERSION}}"

RUN echo "== Downloading s6 overlay ==" && \
    mkdir -p /s6 && \
    if [ "$TARGETARCH" = "arm64" ]; then \
        OVERLAY_ARCH=aarch64 ; \
    elif [ "$TARGETARCH" = "arm" ]; then \
        OVERLAY_ARCH=armhf ; \
    elif [ "$TARGETARCH" = "amd64" ]; then \
        OVERLAY_ARCH="x86_64" ; \
    else echo "unknown architecture '${TARGETARCH}'" ; exit 1 ; fi && \
    curl -sL "${OVERLAY_URL_BASE}/s6-overlay-noarch.tar.xz" | tar Jxpf - -C /s6 && \
    curl -sL "${OVERLAY_URL_BASE}/s6-overlay-${OVERLAY_ARCH}.tar.xz" | tar Jxpf - -C /s6 && \
    curl -sL "${OVERLAY_URL_BASE}/s6-overlay-symlinks-noarch.tar.xz" | tar Jxpf - -C /s6 && \
    curl -sL "${OVERLAY_URL_BASE}/s6-overlay-symlinks-arch.tar.xz" | tar Jxpf - -C /s6 && \
    echo "== Installing Aria2 (Patched PRO binary)" && \
    mkdir -p /ariatmp && \
    if [ "$TARGETARCH" = "arm" ]; then \
        ARIA2_ARCH=armhf ; \
    else ARIA2_ARCH=$OVERLAY_ARCH; \
    curl -sL \
        "${ARIA2_URL_BASE}/aria2-${ARIA2_VERSION}-static-linux-${ARIA_ARCH}.tar.gz" | tar Jxpf - -C /usr/local/bin/



RUN echo "== Installing Aria2-Pro-Core =="
ADD https://github.com/P3TERX/Aria2-Pro-Core/releases/download/[version]/aria2-[version]-static-linux-[arch].tar.gz /tmp
RUN \
    echo "blorp" \
    && wget https://github.com/P3TERX/Aria2-Pro-Core/releases/download/[version]/aria2-[version]-static-linux-[arch].tar.gz


RUN \
    apk add --no-cache \
        curl \
        xz



ENV \
    PS1="$(whoami)@$(hostname):$(pwd)\\$ " \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0

RUN \
    echo "**** install core packages ****" && \
    apk add --no-cache \
        bash \
        ca-certificates \
        coreutils \
        curl \
        procps \
        shadow \
        tzdata \
        && \
    echo "**** create abc user and make empty dirs ****" && \
    groupmod -g 1000 users && \
    useradd -u 911 -U -d /config -s /bin/false abc && \
    usermod -G users abc && \
    mkdir -p \
        /config \
        /defaults \
        && \
    echo "**** cleanup ****" && \
    rm -rf \
        /tmp/*

RUN \
    echo "**** install webui-aria2 ****" && \
    apk add --no-cache git && \
    git clone https://github.com/ziahamza/webui-aria2.git


# add local files
COPY root/ /bar/

RUN \
    echo "**** directories ****" && \
    mkdir -p /bar/download && \
    echo "**** permissions ****" && \
    chmod a+x \
        /bar/usr/local/bin/* \
        /bar/etc/cont-init.d/* \
        /bar/etc/s6-overlay/s6-rc.d/*/run

RUN \
    echo "**** s6: resolve dependencies ****" && \
    for dir in /bar/etc/s6-overlay/s6-rc.d/*; do mkdir -p "$dir/dependencies.d"; done && \
    for dir in /bar/etc/s6-overlay/s6-rc.d/*; do touch "$dir/dependencies.d/legacy-cont-init"; done && \
    echo "**** s6: create a new bundled service ****" && \
    mkdir -p /tmp/app/contents.d && \
    for dir in /bar/etc/s6-overlay/s6-rc.d/*; do touch "/tmp/app/contents.d/$(basename "$dir")"; done && \
    echo "bundle" > /tmp/app/type && \
    mv /tmp/app /bar/etc/s6-overlay/s6-rc.d/app && \
    echo "**** s6: deploy services ****" && \
    rm /bar/package/admin/s6-overlay/etc/s6-rc/sources/top/contents.d/legacy-services && \
    touch /bar/package/admin/s6-overlay/etc/s6-rc/sources/top/contents.d/app

HEALTHCHECK --interval=30s --timeout=30s --start-period=10s --retries=3 \
    CMD /usr/local/bin/healthcheck

ENTRYPOINT ["/init"]
