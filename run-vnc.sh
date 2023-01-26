#!/bin/bash

# set -x

# Allow the re-run of the profile to succeed to fix LD_LIBRARY_PATH issue 
unset PROSPECTIVE_MQSI_BASE_FILEPATH

echo ">>>> Starting the virtual X server"
vncserver -geometry 1600x1200

( sleep 5 ; echo ">>>> Starting window manager" ; DISPLAY=:1 icewm) &

# Start the port forwarder on port 6080 (5901 is the X server VNC port)
echo ">>>> Starting VNC forwarder on port 6080"
novnc_server --vnc localhost:5901 &

sleep 5
echo "========================================================================"
echo
echo
echo "Connect to one of the following URLs to access the virtual desktop:"
echo $CHE_DASHBOARD_URL | sed "s/devspaces/${DEVWORKSPACE_ID}-2/g"
echo $CHE_DASHBOARD_URL | sed "s/devspaces/${DEVWORKSPACE_ID}-2/g" | sed 's/https/http/g'
echo
echo
echo "========================================================================"
echo
