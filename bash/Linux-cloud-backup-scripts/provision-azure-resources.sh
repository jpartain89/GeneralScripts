#!/bin/sh

AFFINITYGROUP="backup-dulc"
VM="backup-vm01"
USERNAME="jpartain89"
USERPASSWORD="Ranger1992"
VNET="backup-vnet"
SUBNET="subnet-backup-01"
SERVICE="backup-vm"
STORAGE="backupstorage"

LOCATION="Central US"
IMAGENAME="b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-14_04-LTS-amd64-server-20140414-en-us-30GB"
HDD="https://${STORAGE}.blob.core.windows.net/vhds/${VM}-system"

# creating affinity group
azure account affinity-group create "$AFFINITYGROUP" -l "$LOCATION" -e "$AFFINITYGROUP"

# creating storage
azure storage account create --type LRS -a "$AFFINITYGROUP" "$STORAGE"

# creating vnet
azure network vnet create -e 10.0.0.0 -i 8 -p 10.0.0.0 -r 24 -n "$SUBNET" -a "$AFFINITYGROUP" "$VNET"

# creating service
azure service create --affinitygroup "$AFFINITYGROUP" "$SERVICE"

# creating vm
azure vm create "$SERVICE" "$IMAGENAME" "$USERNAME" "$USERPASSWORD" -n $VM -z Basic_A0 --ssh 22 -u "$HDD" -w "$VNET" -b "$SUBNET"

# creating smb file share
STORAGECONNECTIONSTRING="$(azure storage account connectionstring show $STORAGE | grep 'connectionstring:' | awk '{print $3}')"
azure storage share create -c "$STORAGECONNECTIONSTRING" --share backup --quota 1024
