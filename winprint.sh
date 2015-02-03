#!/bin/sh

# This is a modification of the samba provided smbprint script
# changed to work under AIX as the backend for a queue. It does
# not read a config file.
#
# Variables below define the server and service. They are
# the content of the .config file when printing from
# /etc/printcap.
#
server=$1
service=$2
user="domain-user"
password="domain-user-password"
#
# Debugging log file, change to /dev/null if you like.
#
logfile=/tmp/${USER}-print.log
echo "server $server, service $service" >> $logfile

shift; shift
(
# NOTE You may wish to add the line `echo translate' if you want automatic
# CR/LF translation when printing.
        echo translate
        echo "print -"
        echo 'ESC&k2SESC(s0TESC&l8D'
        cat $*
        echo ^L
) | /usr/local/samba/bin/smbclient "\\\\$server\\$service" $password \
        -U "$user" -N -P  >> $logfile
