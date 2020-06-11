#! /bin/bash

# This script helps automate the configurations of local rsyslog logging
# This script is strictly created for SuSE Linux Enterprice 12
# This script requires disc insterted in the system already as /dev/sr0

# creating mount point for /dev/sr0
echo 'Creating mount point for /dev/sr0...'
mkdir /SLE-12
echo 'Mount point created successfully...'
sleep 1

# adding repository for the above created mount point
# first we disable all other repositories to avoid conflicts
zypper mr -d -a

# syntax zypper ar <mount point> <repo name>
echo 'Adding new repository to the system...'
zypper ar /SLE-12 SLE-12

# updating repo priority
zypper mr -p 1 SLE-12

# refreshing repositories' list
zypper ref
echo 'Repo is successfully added to the system...'
sleep 1

# re-enabling previously disabled repos and refreshing them as well
zypper mr -e -a
zypper ref

# installing rsyslog-diag-tools, rsyslog-doc and rsyslog (who might be installed by default)
echo 'Installing rsyslog packages...'
zypper --non-interactive  in rsyslog-d*
zypper --non-interactive in rsyslog
echo 'Packages installed successfully..'

# configuring rsyslog by editing the configuration file
# as a precaution we need to back up the configuration so we can fallback in case of error
echo 'Configuring rsyslog...'
cp /etc/rsyslog.conf /etc/rsyslog.conf.backup

# as for this demostration the script will log debug priority logs to a local.debug file, info priority
# logs to a local.info file and all logs to local.logs file
echo '' >> /etc/rsyslog.conf
echo '' >> /etc/rsyslog.conf
echo 'local4.=debug			-/var/log/local4.debug' >> /etc/rsyslog.conf
echo 'local4.=info			-/var/log/local4.info' >> /etc/rsyslog.conf
echo 'local4.*				-/var/log/local4.logs' >> /etc/rsyslog.conf

echo 'Done configuring the rsyslog...'

# creating log file to ensure the service won't cause errors logging on non-existing files
echo 'Creating log files...'
touch /var/log/local4.{debug,info,logs}

# enable the service to start at boot time
echo 'Enabling rsyslog service...'
systemctl enable rsyslog.service

# so the service can re-read the configuration file 
echo 'Restarting rsyslog service...'
systemctl restart rsyslog.service

# testing
# logger -p local.info 'Message info' to log into local.info file
# if you can see the contents of the three files as per commands below, the logging is functioning
# otherwise, you better restart the system:
echo 'Testing the configurations...'
logger -p local4.info "Message information"
logger -p local4.debug "Message debug"
clear

echo 'Contents of local.info: '
cat /var/log/local4.info

echo ''
echo 'Contents of local.debug: '
cat /var/log/local4.debug

echo ''
echo 'Contents of local.logs: '
cat /var/log/local4.logs
