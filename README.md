# docker-aria2

This docker image is with

- s6-overlay v3
    - permission handling with ```PUID``` and ```PGID```
    - running an app with non-root user
- a choice of web-ui
    - [mayswind/AriaNg](https://github.com/mayswind/AriaNg)
    - [ziahamza/webui-aria2](https://github.com/ziahamza/webui-aria2)
- reverse proxied jsonrpc

## Usage

```yaml
version: '3'

services:
    container_name: aria2
    image: ghcr.io/by275/aria2:latest
    restart: always
    network_mode: "bridge"
    ports:
      - ${SERVICE_PORT}:80
    volumes:
      - ${DOCKER_ROOT}/aria2/config:/config
      - ${DOWNLOAD_ROOT}:/download
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=Asia/Seoul
      - WEBUI=webui-aria2
      - RPC_SECRET=${YOUR_RPC_SECRET}
      - USER_OPTS=${ADDITIONAL_ARGS}
```

Create and run your container as above, and then it will run

```bash
aria2c \
    --conf-path=/config/aria2.conf \
    --disable-ipv6=true \
    --enable-rpc \
    --rpc-listen-all \
    --rpc-allow-origin-all \
    --rpc-listen-port=6800 \
    -d /download \
    ${RPC_SECRET:+ --rpc-secret=$RPC_SECRET} \
    ${USER_OPTS[@]}
```

You can specify your rpc secret and additional command line arguments compaitible to aria2c **EXCEPT** fixed ones. Now following services are available on

| SERVICE  | URL |
|---|---|
| webui | ```http://${DOCKER_HOST_IP}:${SERVICE_PORT}/aria2``` |
| jsonrpc | ```http://${DOCKER_HOST_IP}:${SERVICE_PORT}/aria2/jsonrpc``` |
| xmlrpc | ```http://${DOCKER_HOST_IP}:${SERVICE_PORT}/aria2/xmlrpc``` |


## Environment variables

| ENV  | Description  | Default  |
|---|---|---|
| ```PUID``` / ```PGID```  | uid and gid for running an app  | ```911``` / ```911```  |
| ```TZ```  | timezone  |  |
| ```BASE_URL```  | location path with a preceding slash  | ```/aria2```  |
| ```WEBUI```  | either of ```ariang``` or ```webui-aria2```   | ```ariang```  |
