# Cloud Engineer Utility Scripts
This repository contains a collection of scripts to automate common cloud engineering tasks related to virtual machines (VMs), networking, billing, monitoring, and resource management.

## Features
### Snapshot / Clone Disk
- Create snapshots of specific VMs or clone their attached disks if needed.
- Useful for backup, disaster recovery, or VM duplication.

### Clone Network Security Group (NSG)
- Clone an existing NSG, including its security rules.
- Helps replicate network configurations across different environments.

### Create Virtual Machine (VM)
- Automate the creation of new VMs with predefined settings.
- Streamlines resource deployment.

### Gather Billing Data

- Collect billing usage and cost data over a specified period.
- Supports monthly reports, cost optimization, and budget tracking.

### Grep VM Utilization with Flexible Time Range

- Query and extract VM CPU, memory, and disk utilization metrics.
- Time range can be customized as needed (e.g., past 1 hour, 7 days).

### Create Monitoring Alerts

- Set up alert rules for critical metrics like CPU usage, disk space, or network activity.
- Supports proactive monitoring.

### Apply Tags to Disks Attached to VMs

- Identify disks attached only to standalone VMs (not VM Scale Sets).
- Add owner of disk and which service type of disk owner with keys "VM Name" and "Service Name Owner".
- Applied in add-disk-tag.sh.

## Requirements

- Azure CLI
- jq, grep, awk
- Python 3.x

Proper permissions for resource creation and modification.
