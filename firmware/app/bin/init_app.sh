#!/bin/sh

echo
echo "============================="
echo " MJXSJ02HL CUSTOM FIRMWARE"
echo -n " VERSION: "
cat /usr/app/share/.version
echo " AUTHOR: Kasito"
echo " HOMEPAGE: https://kasito.ru"
echo "============================="
echo

# Generate device id
if [ ! -f /usr/app/share/.device_id ]; then
	tr -dc a-z0-9 < /dev/urandom | head -c 8 > /usr/app/share/.device_id
fi

# Set default timezone
if [ ! -f /etc/TZ ]; then
	echo "Set default timezone (UTC+3:00)"
	echo "UTC-3:00" > /etc/TZ
fi

# Copy wpa_supplicant.conf from sd-card
if [ -f /mnt/mmc/wpa_supplicant.conf ]; then
	echo "Copy wpa_supplicant.conf from sd-card..."
	cp -f /mnt/mmc/wpa_supplicant.conf /etc/wpa_supplicant.conf
	chmod 644 /etc/wpa_supplicant.conf
fi

# Copy mjsxj02hl.conf from sd-card
if [ -f /mnt/mmc/mjsxj02hl.conf ]; then
	echo "Copy mjsxj02hl.conf from sd-card..."
	cp -f /mnt/mmc/mjsxj02hl.conf /usr/app/share/mjsxj02hl.conf
	chmod 644 /usr/app/share/mjsxj02hl.conf
fi

# Create empty configuration file if it is missing
if [ ! -f /usr/app/share/mjsxj02hl.conf ]; then
	touch /usr/app/share/mjsxj02hl.conf
	chmod 644 /usr/app/share/mjsxj02hl.conf
fi

# Connect to Wi-Fi
ifconfig wlan0 up
if [ -f /etc/wpa_supplicant.conf ]; then
	echo "Connecting to an Access Point..."
	wpa_supplicant -B -D nl80211 -i wlan0 -c /etc/wpa_supplicant.conf
	udhcpc -b -i wlan0
else
	echo "Starting the access point..."
	hostapd -B /etc/hostapd.conf
	ifconfig wlan0 192.168.1.1
	udhcpd -fS /etc/udhcpd.conf
fi

# Time synchronization
echo "Time synchronization..."
ntpd -p pool.ntp.org

# WEB server
echo "Starting WEB server..."
httpd -p 80 -h /usr/app/www

# Telnet server (root:toor)
echo "Starting Telnet server..."
telnetd

# FTP server (root:toor)
echo "Starting FTP server..."
tcpsvd -vE 0.0.0.0 21 ftpd -w / &

# Main application
echo "Starting main application..."
mjsxj02hl &

# Execute run.sh from sd-card
if [ -f /mnt/mmc/run.sh ]; then
	echo "Execute /mnt/mmc/run.sh script..."
	/mnt/mmc/run.sh
fi

