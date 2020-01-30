#!/bin/bash

CONFIG="$(dirname $(readlink -f $0))/config.properties"

function prop
{
    grep "${1}" "$CONFIG" | cut -d '=' -f2
}

MSG=$(prop "stop-message")
BOT=$(prop "bot-phone")
USER=$(prop "user-phone")

echo -e "$MSG" | signal-cli -u "$BOT" send "$USER"
