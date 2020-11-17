#!/bin/sh
#
# (c) Copyright PaperCut Software, 2007
#
# Author: Valentino Lauciani (vlauciani@gmail.com)
# Starting from an idea of: Chris Dance (chris.dance <a> papercut.com) -> https://www.papercut.com/kb/Main/CopyingPrinterConfigOnTheMac#the-script
# A simple script to copy printers and configurations from one Apple Mac OS X 
# system to another.
#

TARGET_HOST=`hostname`
SOURCE_HOST=
SOURCE_USER=

if [ -z "${1}" ]; then
    echo
    echo "USAGE: pull-printer-config <SOURCE_HOST> <SOURCE_USER>"
    echo "    SOURCE_HOST: The remote system whose printer config you'd like to copy."
    echo "    SOURCE_USER: An user on SOURCE_HOST with admin privilege"
    echo
    exit 1
else
    SRC_HOST=${1}
fi

if [ -z "$2" ]; then
    echo
    echo "USAGE: pull-printer-config <SOURCE_HOST> <SOURCE_USER>"
    echo "    SOURCE_HOST: The remote system whose printer config you'd like to copy."
    echo "    SOURCE_USER: An user on SOURCE_HOST with admin privilege"
    echo
    exit 1
else
    SRC_USER=${2}
fi

USERID=`id | sed "s/^uid=\([0-9][0-9]*\).*$/\1/"`
if test "${USERID}" -ne 0; then
    echo "Error: Please run this script as admin privilete (e.g. sudo ./pull-printer-config.sh)" 1>&2
    exit 1
fi


echo "Copying printer configuration from ${SOURCE_HOST} to ${TARGET_HOST}."
echo "Enter the password for the user ${SOURCE_USER} on ${SOURCE_HOST} if requested."
echo "You may be requested for your password multiple times."
echo 

#
# On the target system take a copy of our cups config and set ourselves as the
# owner.
#
echo "Preparing config on source server..."
ssh -t "${SOURCE_USER}@${SOURCE_HOST}" \
    "sudo sh -c \
    \"rm -fr /tmp/cupstmp; cp -R /etc/cups/ /tmp/cupstmp; chown -R ${SOURCE_USER} /tmp/cupstmp\""

if [ "$?" -ne "0" ]; then
    echo "Error: Unable to source config of remote system" 1>&2
    exit 1
fi

#
# Use scp to copy our temp copy over to our local system.
#
echo "Copying config..."
if [ -d /etc/cupstmp ]; then
    rm -fr /etc/cupstmp >/dev/null 2>&1
fi

#
# Move old config
#
sudo scp -rpq "${SOURCE_USER}@${SOURCE_HOST}:/tmp/cupstmp/" "/etc/cupstmp"
if [ ! -d /etc/cupstmp  ]; then
    #
    # Error so restore our backup
    #
    echo "Error: Unable to copy files." 1>&2
    exit 1
fi

datestamp=`date +%y%m%d`
sudo mv /etc/cups "/etc/cups${datestamp}" && mv /etc/cupstmp /etc/cups

#
# Restart the CUPS server so it picks up our new config.
#
killall -HUP cupsd

echo "Copy complete."
