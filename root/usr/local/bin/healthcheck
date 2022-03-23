#!/bin/bash

if [[ -z "${RPC_SECRET}" ]]; then
    curl --silent --fail -X POST 127.0.0.1/aria2/jsonrpc \
        -H 'Content-Type: application/json' \
        -d '{"jsonrpc":"2.0", "id":"qwer", "method":"aria2.getVersion"}' -o /dev/null
    if [[ "$?" == "0" ]]; then
        exit 0
    fi
else
    curl --silent --fail -X POST 127.0.0.1/aria2/jsonrpc \
        -H 'Content-Type: application/json' \
        -d '{"jsonrpc":"2.0", "id":"qwer", "method":"aria2.getVersion", "params":["token:'${RPC_SECRET}'"]}' -o /dev/null
    if [[ "$?" == "0" ]]; then
        exit 0
    fi
fi

exit 1
