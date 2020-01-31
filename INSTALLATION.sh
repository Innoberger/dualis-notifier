#!/bin/bash

DIR="$(dirname $(readlink -f $0))"
CONFIG="$DIR/config.properties"

echo "This is the dualis-notifier installation script."
echo "The script has been published by Innoberger / Fynn Arnold under the MIT license."
echo "Visit https://github.com/Innoberger/dualis-notifier for more information."
echo

echo "Where is your signal-cli installation?"
echo "Please type the full path, like this /opt/signal-cli-VERSION/bin/signal-cli"
read SIGNAL_CLI

while [ -z "$SIGNAL_CLI" ]
do
   echo "This value can not be empty. Please try again"
   read SIGNAL_CLI
done

echo "What phone number is your signal bot using?"
echo "Please use this format: +49123456789"
read BOT_PHONE

while [ -z "$BOT_PHONE" ]
do
   echo "This value can not be empty. Please try again"
   read BOT_PHONE
done

echo "What phone number do you want to receive signal messages with?"
echo "Please use this format: +49123456789"
read USER_PHONE

while [ -z "$USER_PHONE" ]
do
   echo "This value can not be empty. Please try again"
   read USER_PHONE
done

echo "What is your Dualis account username?"
echo "Default scheme is surname.givenName@dh-karlsruhe.de"
read DUALIS_USERNAME

while [ -z "$DUALIS_USERNAME" ]
do
   echo "This value can not be empty. Please try again"
   read DUALIS_USERNAME
done

echo "What is your Dualis account password?"
echo "Please note that your username and password will be base64 encoded"
read -s DUALIS_PASSWORD
echo

while [ -z "$DUALIS_PASSWORD" ]
do
   echo "This value can not be empty. Please try again"
   read DUALIS_PASSWORD
done

DUALIS_USERNAME=$(echo -e "$DUALIS_USERNAME" | tr -d '\n\r' | base64)
DUALIS_PASSWORD=$(echo -e "$DUALIS_PASSWORD" | tr -d '\n\r' | base64)

mv "$CONFIG.template" "$CONFIG"

sed -i "s/signal-cli=/signal-cli=$SIGNAL_CLI/g" "$CONFIG"
sed -i "s/bot-phone=/bot-phone=$BOT_PHONE/g" "$CONFIG"
sed -i "s/user-phone=/user-phone=$USER_PHONE/g" "$CONFIG"
sed -i "s/dualis-username-base64=/dualis-username-base64=$DUALIS_USERNAME/g" "$CONFIG"
sed -i "s/dualis-password-base64=/dualis-password-base64=$DUALIS_PASSWORD/g" "$CONFIG"

echo "Config setup successful"

crontab -l > "$DIR/crontab.tmp"
echo -e "\n# dualis-notifier" >> "$DIR/crontab.tmp"
echo "0 10 * * 1-5 $DIR/start.sh" >> "$DIR/crontab.tmp"
echo "0,15,30,45 10-16 * * 1-5 $DIR/update.sh" >> "$DIR/crontab.tmp"
echo "0 16 * * 1-5 $DIR/stop.sh" >> "$DIR/crontab.tmp"
crontab "$DIR/crontab.tmp"
rm -f "$DIR/crontab.tmp"

echo "Crontab installation successful"
echo "Do you want to send yourself a test signal message? [Y/n]"

read TEST_MSG

if [ -z "$TEST_MSG" ] || [ "$TEST_MSG" = "y" ] || [ "$TEST_MSG" = "Y" ]
then
   echo "Test signal message has been sent"
   echo "If you do not receive a message on your phone in a few seconds, please check the config file"
   echo -e "Hallo! Das ist eine Test-Nachricht der Anwendung Dualis-Notifier. Wenn du diese Nachricht erhalten hast, wurde die Applikation richtig installiert." | signal-cli -u "$BOT_PHONE" send "$USER_PHONE"
fi

echo "All done"
