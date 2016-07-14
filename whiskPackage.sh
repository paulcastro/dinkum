#!/bin/sh

source local.env

PAYLOAD=$(<payload.json)

function uninstall() {
    echo "Disabling rule"
    wsk rule disable backupFromTrigger
    echo "Deleting trigger"
    wsk trigger delete backupTrigger
    echo "Updating actions"
    wsk action delete getApiToken 
    wsk action delete getServers
    wsk action delete createBackup 
    wsk action delete authorizedBackup 
    echo "creating rules"
    wsk rule delete backupFromTrigger 
}

function install() {
    echo "Creating trigger feed"
wsk trigger create backupTrigger --feed /whisk.system/alarms/alarm -p cron '0 0 23 * * *' -p trigger_payload '$PAYLOAD'
    echo "Creating actions"
    wsk action create getApiToken getApiToken.js -p host $IDENTITY_HOST -p port $IDENTITY_PORT -p endpointName $ENDPOINT_NAME -p userId $USERID -p password $PASSWORD -p projectId $PROJECT_ID
    wsk action create getServers getServers.js
    wsk action create createBackup createBackup.js
    wsk action create --sequence authorizedBackup getApiToken,getServers,createBackup
    echo "creating rules"
    wsk rule create --enable backupFromTrigger backupTrigger authorizedBackup
}

function usage() {
    echo 'whiskPackage.sh with options --install, --uninstall, --update'
}

case "$1" in
"--install" )
install
;;
"--uninstall" )
uninstall
;;
* )
usage
;;
esac
