ARG ALPINE_VER=3.16

FROM ghcr.io/linuxserver/baseimage-alpine:${ALPINE_VER} AS base

# 
# BUILD
# 
FROM base AS builder

RUN \
    mkdir -p /bar && \
    echo "**** install build dependencies ****" && \
    apk add --no-cache \
        curl \
        git \
        unzip

RUN \
    echo "**** install ariang ****" && \
    cd $(mktemp -d) && \
    ariang_ver=$(curl --silent https://api.github.com/repos/mayswind/AriaNg/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
    wget https://github.com/mayswind/AriaNg/releases/download/${ariang_ver}/AriaNg-${ariang_ver}.zip && \
    unzip "AriaNg-${ariang_ver}.zip" -d /bar/ariang

RUN \
    echo "**** install webui-aria2 ****" && \
    cd $(mktemp -d) && \
    git clone https://github.com/ziahamza/webui-aria2.git && \
    mv webui-aria2/docs /bar/webui-aria2

# add local files
COPY root/ /bar/

RUN \
    echo "**** permissions ****" && \
    chmod a+x \
        /bar/usr/local/bin/* \
        /bar/etc/cont-init.d/* \
        /bar/etc/s6-overlay/s6-rc.d/*/run

RUN \
    echo "**** s6: resolving dependencies ****" && \
    for dir in /bar/etc/s6-overlay/s6-rc.d/*; do mkdir -p "$dir/dependencies.d"; done && \
    for dir in /bar/etc/s6-overlay/s6-rc.d/*; do touch "$dir/dependencies.d/99-ci-service-check"; done && \
    echo "**** s6: creating a new bundled service ****" && \
    mkdir -p /tmp/app/contents.d && \
    for dir in /bar/etc/s6-overlay/s6-rc.d/*; do touch "/tmp/app/contents.d/$(basename "$dir")"; done && \
    echo "bundle" > /tmp/app/type && \
    mv /tmp/app /bar/etc/s6-overlay/s6-rc.d/app

# 
# RELEASE
# 
FROM base
LABEL maintainer="by275"
LABEL org.opencontainers.image.source https://github.com/by275/docker-aria2

RUN \
    echo "**** s6: registering service ****" && \
    touch /package/admin/s6-overlay/etc/s6-rc/sources/top/contents.d/app && \
    echo "**** install packages ****" && \
    apk add --no-cache curl aria2 nginx

COPY --from=builder /bar/ /

EXPOSE 80

VOLUME /config /download
WORKDIR /config

HEALTHCHECK --interval=30s --timeout=30s --start-period=10s --retries=3 \
    CMD /usr/local/bin/healthcheck

ENTRYPOINT ["/init"]
