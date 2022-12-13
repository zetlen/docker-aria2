ARG ALPINE_VER=3.17

FROM ghcr.io/by275/base:alpine AS prebuilt
FROM ghcr.io/by275/base:alpine${ALPINE_VER} AS base

# 
# BUILD
# 
FROM base AS ariang

RUN \
    echo "**** install ariang ****" && \
    apk add --no-cache jq && \
    ARIANG_VER=$(curl -sL https://api.github.com/repos/mayswind/AriaNg/releases/latest | jq -r '.tag_name') && \
    curl -LJ https://github.com/mayswind/AriaNg/releases/download/${ARIANG_VER}/AriaNg-${ARIANG_VER}.zip -o ariang.zip && \
    unzip ariang.zip -d /ariang

FROM base AS webui-aria2

RUN \
    echo "**** install webui-aria2 ****" && \
    apk add --no-cache git && \
    git clone https://github.com/ziahamza/webui-aria2.git

# 
# COLLECT
# 
FROM base AS collector

# add s6-overlay
COPY --from=prebuilt /s6/ /bar/
ADD https://raw.githubusercontent.com/by275/docker-base/main/_/etc/cont-init.d/adduser /bar/etc/cont-init.d/10-adduser

# add ariang
COPY --from=ariang /ariang /bar/ariang

# add webui-aria2
COPY --from=webui-aria2 /webui-aria2/docs /bar/webui-aria2

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

# 
# RELEASE
# 
FROM base
LABEL maintainer="by275"
LABEL org.opencontainers.image.source https://github.com/by275/docker-aria2

RUN \
    echo "**** install runtime packages ****" && \
    apk add --no-cache aria2 nginx

COPY --from=collector /bar/ /

EXPOSE 80

VOLUME /config /download

HEALTHCHECK --interval=30s --timeout=30s --start-period=10s --retries=3 \
    CMD /usr/local/bin/healthcheck

ENTRYPOINT ["/init"]
