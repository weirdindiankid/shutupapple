#!/bin/bash
while true; do
    killall -9 AirPlayXPCHelper 2>/dev/null
    killall -9 AirPlayUIAgent 2>/dev/null
    killall -9 rapportd 2>/dev/null
    killall -9 apsd 2>/dev/null
    sleep 1
done
