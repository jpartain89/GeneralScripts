#!/bin/sh

VM="reserve-vm01"
SERVICE="reserve-vm"
USERNAME="azureuser"

# send start vm command
azure vm start $VM

# wait until vm start
VMSTATUS="Unknown"
while [ "$VMSTATUS" != "ReadyRole" ]
do
    echo "sleeping…"
    sleep 10s
    $VMSTATUS="$(azure vm show $VM | grep 'InstanceStatus' | awk '{print $3}' | sed -e 's/\W//g')"
    echo "vm status: $VMSTATUS"
done

# backup files
echo "syncing…"
rsync -avzhe ssh /var/www/html $USERNAME@$SERVICE.cloudapp.net:/media/cloud/backup

# send shotdown vm command
azure vm shutdown $VM