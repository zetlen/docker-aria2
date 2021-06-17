FROM ghcr.io/linuxserver/baseimage-alpine:3.14
LABEL maintainer="wiserain"
LABEL org.opencontainers.image.source https://github.com/wiserain/docker-aria2

# install packages
RUN \
 echo "**** install basics ****" && \
 apk add --no-cache curl && \
 echo "**** install build dependencies ****" && \
 apk add --no-cache --virtual=build-deps \
	git \
	unzip && \
 echo "**** install aria2 ****" && \
 apk add --no-cache aria2 && \
 echo "**** install ariang ****" && \
 cd $(mktemp -d) && \
 ariang_ver=$(curl --silent https://api.github.com/repos/mayswind/AriaNg/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') && \
 wget https://github.com/mayswind/AriaNg/releases/download/${ariang_ver}/AriaNg-${ariang_ver}.zip && \
 unzip "AriaNg-${ariang_ver}.zip" -d /ariang && \
 echo "**** install webui-aria2 ****" && \
 cd $(mktemp -d) && \
 git clone https://github.com/ziahamza/webui-aria2.git && \
 mv webui-aria2/docs /webui-aria2 && \
 echo "**** install nginx ****" && \
 apk add --no-cache nginx && \
 echo "**** cleanup ****" && \
 apk del --no-cache --purge build-deps && \
 rm -rf \
 	/tmp/* \
	/root/.cache

# add local files
COPY root/ /

RUN chmod a+x /healthcheck.sh

EXPOSE 80

VOLUME /config /download
WORKDIR /config

HEALTHCHECK --interval=30s --timeout=30s --start-period=10s --retries=3 CMD [ "/healthcheck.sh" ]

ENTRYPOINT ["/init"]
