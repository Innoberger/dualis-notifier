# dualis-notifier
Signal notification app to message you when a new grade has been released on DHBW Dualis.

![Signal message examples](https://imgur.com/download/HjkrwXM)

## How does it work?
* At 10 am every weekday, you will receive a signal message that the messenger has been enabled.
* Between 10 am and 4 pm on weekdays, the script will check your grades in Dualis every 15 minutes. If changes were made, you will receive a message and a link to quickly login.
* At 4 pm every weekday, you will receive a signal message that the messenger has been disabled.
* Thanks to neinkob15's server running his [Dualis API](https://github.com/neinkob15/Dualis-API) to host the Dualis data in the convinient JSON format.
* You can adjust the times and time intervals in your cronjob (crontab -e).

## Preconditions
You need to have installed and successfully configured [jq](https://stedolan.github.io/jq/) and [signal-cli](https://github.com/AsamK/signal-cli).

## Installation
As simple as it is: Clone this repo, execute INSTALLATION.sh and follow the instructions. The installation script will setup the config file and add cronjobs automatically. You're done!
