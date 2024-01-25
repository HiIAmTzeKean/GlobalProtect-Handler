#!/bin/bash

# References:
# https://gist.github.com/kaleksandrov/3cfee92845a403da995e7e44ba771183
# https://gist.github.com/sming/0c56fb7a54a68d502aded2b71e501bba

# Tested machine
# Macbook pro 14 M2
# IOS 14.2.1
# 16GB RAM

THIS_SCRIPT_INVOCATION=$0

# The return status of this function will be 0 if globalprotect is running, 1 if not running because grep returns 0
# if it finds a match and 1 if not.
# We basically grep for globalprotect but exclude all the matches we don't want
ps-grep () {
	ps -A | grep Global | grep -v "grep" | grep -v "%CPU" > /dev/null        
}

ps-grep
IS_RUNNING=$?

if [ "$IS_RUNNING" -eq "0" ]

# we kill the process if it is running here
then
    echo "Stopping GlobalProtect..."
    
    # we first kill the process by finding its pid
    ps aux | grep -i globalprotect | grep -v grep | grep -v toggler | awk '{ print $2; }' | xargs kill -${2:-'TERM'}
    # then we stop the process from daemon from spawning more process
    launchctl remove com.paloaltonetworks.gp.pangps
    launchctl remove com.paloaltonetworks.gp.pangpa
    
# else we signal the process to start running
# sometimes this will not start the app and you will have to manually run the app
else
    echo "Starting GlobalProtect..."
    launchctl load /Library/LaunchAgents/com.paloaltonetworks.gp.pangpa.plist
    launchctl load /Library/LaunchAgents/com.paloaltonetworks.gp.pangps.plist
fi