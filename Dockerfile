FROM ghcr.io/linuxserver/baseimage-alpine:3.15 AS base
FROM base AS builder

RUN \
    mkdir -p /bar && \
    echo "**** install build dependencies ****" && \
    apk add --no-cache \
        curl \
        git \
        unzip && \
    echo "**** install ariang ****" && \
    cd $(mktemp -d) && \
    ariang_ver=$(curl --silent https://api.github.com/repos/mayswind/AriaNg/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
    wget https://github.com/mayswind/AriaNg/releases/download/${ariang_ver}/AriaNg-${ariang_ver}.zip && \
    unzip "AriaNg-${ariang_ver}.zip" -d /bar/ariang && \
    echo "**** install webui-aria2 ****" && \
    cd $(mktemp -d) && \
    git clone https://github.com/ziahamza/webui-aria2.git && \
    mv webui-aria2/docs /bar/webui-aria2

# add local files
COPY root/ /bar/


FROM base
LABEL maintainer="wiserain"
LABEL org.opencontainers.image.source https://github.com/wiserain/docker-aria2

COPY --from=builder /bar/ /

RUN \
    echo "**** install packages ****" && \
    apk add --no-cache curl aria2 nginx && \
    echo "**** permissions ****" && \
    chmod a+x /healthcheck.sh && \
    echo "**** cleanup ****" && \
    rm -rf \
        /tmp/* \
        /root/.cache

EXPOSE 80

VOLUME /config /download
WORKDIR /config

HEALTHCHECK --interval=30s --timeout=30s --start-period=10s --retries=3 \
    CMD [ "/healthcheck.sh" ]

ENTRYPOINT ["/init"]
