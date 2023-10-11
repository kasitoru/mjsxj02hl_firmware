#!/bin/sh

GATEWAY=${1:-"192.168.1.1"}

errors=0
while true; do
    # Network connection
    if ! ping -c 1 $GATEWAY &> /dev/null; then
        echo "Reconnecting to an Access Point..."
        killall udhcpc wpa_supplicant
        ifconfig wlan0 down
        ifconfig wlan0 up
        wpa_supplicant -B -D nl80211 -i wlan0 -c /etc/wpa_supplicant.conf
        udhcpc -b -i wlan0
        errors=$((errors+1))
    else
        errors=0
    fi
    # Main application
    if ! killall -0 mjsxj02hl &> /dev/null; then
        echo "Restarting main application..."
        mjsxj02hl &
        errors=$((errors+1))
    else
        errors=0
    fi
    # Reboot if there are many errors
    if [ $errors -ge 5 ]; then
        echo "Too many errors! Rebooting the device..."
        reboot
    fi
    sleep 10
done
