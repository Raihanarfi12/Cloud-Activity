#!/bin/bash

# Variables
tagKey1="VM Name"
tagKey2="Service Name Owner"

# List all resource groups in the subscription
resourceGroups=$(az group list --query "[].name" -o tsv)

# Iterate through each resource group
for resourceGroupName in $resourceGroups; do
    echo "Processing resource group: $resourceGroupName"

    # List all disks in the resource group and get their names, IDs, and managedBy resource IDs
    diskList=$(az disk list --resource-group $resourceGroupName --query "[].{name:name, id:id, managedBy:managedBy}" -o tsv)

    # Iterate through each disk
    while IFS=$'\t' read -r diskName diskId managedBy; do
        if [ -n "$managedBy" ]; then
            # Extract the VM name from the managedBy resource ID
            vmName=$(basename "$managedBy")

            # Extract the Service Name Owner (resource type) from managedBy
            serviceNameOwner=$(echo "$managedBy" | awk -F'/providers/' '{print $2}' | cut -d'/' -f1,2)
        else
            vmName="None"
            serviceNameOwner="None"
        fi

        # Update the disk tags with both VM Name and Service Name Owner
        az disk update --ids "$diskId" --set tags."$tagKey1"="$vmName" tags."$tagKey2"="$serviceNameOwner"

        # Print the updated disk information
        echo "Updated disk '$diskName' with tags '$tagKey1:$vmName' and '$tagKey2:$serviceNameOwner' in resource group '$resourceGroupName'"
    done <<< "$diskList"
done
