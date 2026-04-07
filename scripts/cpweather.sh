#!/usr/bin/env bash
set -euo pipefail

#
# Script to copy weather data for the website.
#

echo "copy files\n"

# secure file transfer of the file to the webserver
# copyWeatherToWebServer is a batch script with sftp commands for the transfer 
#
sftp -b /home/transfer/copyWeatherToWebServer smear@smear.emu.ee

echo "done"


