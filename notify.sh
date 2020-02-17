#!/bin/bash

CONFIG="$(dirname $(readlink -f $0))/config.properties"
DIR="$(dirname $(readlink -f $0))/json"

function prop
{
    grep "${1}" "$CONFIG" | cut -d '=' -f2
}

API=$(prop "json-api")
SIGNAL=$(prop "signal-cli")
MSG=$(prop "new-grade-message")
BOT=$(prop "bot-phone")
USER=$(prop "user-phone")

DUALIS_USERNAME=$(prop "dualis-username-base64")
DUALIS_PASSWORD=$(prop "dualis-password-base64")

function call_api
{
    apiJson=$(curl -s -u $(echo "$DUALIS_USERNAME" | base64 -d):$(echo "$DUALIS_PASSWORD" | base64 -d) "$API")
    extract_grades "$apiJson" > "$DIR/grades.json"
}

# Credit for the following function goes to neinkob15.
# I built in some modifications to work in this context.
# https://github.com/neinkob15/Dualis-API/blob/master/notenCompare.sh
function extract_grades
{
   raw="$1"
   json="["
   IFS="]" read -ra array <<< "$(echo $raw)"

   for block in "${array[@]}"
   do
      if ! [[ "$block" == *"name"* ]]
      then
         continue
      fi

      module=$(echo "$block" | sed 's/.*"name":"\([^"]*\)".*/\1/g')
      exam=$(echo "$block" | sed 's/.*"exam":"\([^"]*\)".*/\1/g')
      grade=$(echo "$block" | sed 's/.*"grade":"\([^"]*\)".*/\1/g')

      if [[ "$grade" == "-" ]] || [[ "$grade" == *"{"* ]]
      then
         continue
      fi

      json="$json\n{ \"module\": \"$module\", \"exam\": \"$exam\", \"grade\": \"$grade\" },"
   done

   json="${json::-1}\n]"

   echo -e "$json"
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
diff "$DIR/grades.json.old" "$DIR/grades.json" > /dev/null

if [ "$?" -eq 0 ]
then
   exit 0
fi

diff=$(diff --changed-group-format="%<" --unchanged-group-format="" "$DIR/grades.json" "$DIR/grades.json.old")
diff=$(echo "[${diff::-1}]" | jq .)

echo "$diff"
changes=""
IFS='
'

for change in $(echo "$diff" | jq -c '.[]')
do
   changeModule=$(echo "$change" | jq -r .module)
   changeExam=$(echo "$change" | jq -r .exam)
   changeGrade=$(echo "$change" | jq -r .grade)
   changes="$changes\nModul: $changeModule\nPrüfung: $changeExam\nNote: $changeGrade\n"
done

if [ "$changes" == "" ]
then
   exit 0
fi

MSG="${MSG//%GRADES%/$changes}"

echo -ne "$MSG" | "$SIGNAL" -u "$BOT" send "$USER"
