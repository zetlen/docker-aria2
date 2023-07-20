#!/usr/bin/with-contenv bash

if [ ! -f /config/aria2.conf ]; then
    echo "== No /config/aria2.conf found. Copying from /defaults/ =="
    cp /defaults/aria2.conf /config/aria2.conf
else
    echo "== Found /config/aria2.conf =="
fi

chown -R runner:runner \
    /config \
    /download

# version info
echo "== aria2 v$(echo $(aria2c -v) | awk '{print $3}') ready! =="
