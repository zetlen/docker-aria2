#!/usr/bin/with-contenv bash

command="aria2c --conf-path=/config/aria2.conf --disable-ipv6=true --enable-rpc --rpc-listen-all --rpc-allow-origin-all --rpc-listen-port=6800 -d /download"
command="$command${RPC_SECRET:+ --rpc-secret=$RPC_SECRET} $USER_OPTS"

echo "*** executing => $command"
exec \
	s6-setuidgid abc $command
