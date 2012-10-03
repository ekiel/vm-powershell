# ==============================================================================================
# NAME: vmware_inventory.ps1
# AUTHOR: Eric Kiel eric<dot>kiel<at>collideoscope<dot>org
# Originally found @ 
# http://ict-freak.nl/2009/11/17/powercli-one-liner-to-get-vms-clusters-esx-hosts-and-datastores/
# DATE  : 10/02/2012
# COMMENT: This script will connect to a VMware Virtual Center server and generate a CSV that 
# Maps VMs to Cluster, Resource Pool, Host and Datastore.
# VERSION: 1.0 - Original Code
# USAGE: .\vmware_inventory.ps1
# Variables: 
# $date - date in Month/Day/year format
# $vcenter - vCenter host name
# REQUIREMENTS: VMware vSphere PowerCLI
# ==============================================================================================

# Add in VMware PS Snapin
add-pssnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue

# Comment out if hard coding a vCenter below
$vcenter = Read-Host "Please enter the the vCenter you would like to inventory"

# Uncomment to hard code a vCenter server in
#$vcenter = "your-vcenter"

# Connect to vCenter and get the date...
connect-viserver $vcenter
$date = get-date -format MM-dd-yyyy

#Map Virtual machines to Cluster, Resource Pool, Host and Datastore
Get-VM | Select Name, @{N="Cluster";E={Get-Cluster -VM $_}}, `
@{N="Resource Pool";E={Get-ResourcePool -VM $_}}, `
@{N="ESX Host";E={Get-VMHost -VM $_}}, `
@{N="Datastore";E={Get-Datastore -VM $_}} | `
Export-Csv -NoTypeInformation $date-$vcenter-vm_inventory.csv

write-host "Your report has been saved as" $date-$vcenter-vm_inventory.csv
