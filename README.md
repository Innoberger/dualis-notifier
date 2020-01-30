# dualis-notifier
Signal notification app to message you when a new grade has been released on DHBW Dualis.

## How does it work?
* At 10 am every weekday, you will receive a signal message that the messenger has been enabled.
* Between 10 am and 6 pm on weekdays, the scirpt will check your grades in Dualis every 15 minutes. If changes were made, you will receive a message and a link to quickly login.
* At 6 pm every weekday, you will receive a signal message that the messenger has been disabled.
* Thanks to neinkob15's server running his [Dualis API](https://github.com/neinkob15/Dualis-API) to host the Dualis data in the convinient JSON format.

## Preconditions
You need to have installed and successfully configured [signal-cli](https://github.com/AsamK/signal-cli).

## Installation
As simple as it is: Clone this repo, execute INSTALLATION.sh and follow the instructions. The installation script will setup the config file, add cronjobs and remove itself afterwards. You're done!
