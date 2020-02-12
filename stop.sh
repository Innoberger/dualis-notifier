#!/bin/bash

CONFIG="$(dirname $(readlink -f $0))/config.properties"

function prop
{
    grep "${1}" "$CONFIG" | cut -d '=' -f2
}

SIGNAL=$(prop "signal-cli")
MSG=$(prop "stop-message")
BOT=$(prop "bot-phone")
USER=$(prop "user-phone")

echo -ne "$MSG" | "$SIGNAL" -u "$BOT" send "$USER"
