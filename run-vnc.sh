#!/bin/bash

# set -x

# Allow the re-run of the profile to succeed to fix LD_LIBRARY_PATH issue 
unset PROSPECTIVE_MQSI_BASE_FILEPATH

echo ">>>> Starting the virtual X server"
vncserver -geometry 1600x1200

( sleep 5 ; echo ">>>> Starting window manager" ; DISPLAY=:1 icewm) &

# Start the port forwarder on port 6080 (5901 is the X server VNC port)
echo "============================================================================"
echo
echo
echo "Starting VNC forwarder on port 6080."
echo
echo "Ignore the message saying \"Navigate to this URL\" as that URL does not"
echo "point to an OpenShift route, and a route for 6080 will be created later."
echo
echo
echo "============================================================================"
echo
novnc_server --vnc localhost:5901 &

sleep 5
echo "============================================================================"
echo
echo
echo "Enable port forwarding for port 6080 only: this port is used for the"
echo "novnc display viewer. Use the password entered above to access the console."
echo
echo "Note that the server may take a few seconds to become accessible."
echo
echo
echo "============================================================================"
echo
