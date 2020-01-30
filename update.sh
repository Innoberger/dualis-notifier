#!/bin/bash

CONFIG="$(dirname $(readlink -f $0))/config.properties"
DIR="$(dirname $(readlink -f $0))/json"

function prop
{
    grep "${1}" "$CONFIG" | cut -d '=' -f2
}

API=$(prop "json-api")
MSG=$(prop "new-grade-message")
BOT=$(prop "bot-phone")
USER=$(prop "user-phone")

DUALIS_USERNAME=$(prop "dualis-username-base64")
DUALIS_PASSWORD=$(prop "dualis-password-base64")

function call_api
{
    curl -u $(echo "$DUALIS_USERNAME" | base64 -d):$(echo "$DUALIS_PASSWORD" | base64 -d) -o "$DIR/grades.json" "$API"
}

if [[ ! -d "$DIR" ]]
then
   mkdir "$DIR"
fi

if [[ -f "$DIR/grades.json.old" ]]
then
   rm -f "$DIR/grades.json.old"
fi

if [[ ! -f "$DIR/grades.json" ]]
then
   call_api
   exit 0
fi

mv "$DIR/grades.json" "$DIR/grades.json.old"
call_api
diff "$DIR/grades.json.old" "$DIR/grades.json"

if [ "$?" -ne 0 ]
then
   echo -e "$MSG" | signal-cli -u "$BOT" send "$USER"
fi
