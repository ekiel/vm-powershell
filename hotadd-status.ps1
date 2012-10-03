# ==============================================================================================
# NAME: hotadd-status.ps1
# AUTHOR: Eric Kiel eric<dot>kiel<at>collideoscope<dot>org
# Originally found @ http://ict-freak.nl/2009/10/05/powercli-check-cpumemory-hot-add/
# DATE  : 10/02/2012
# COMMENT: This script will connect to a VMware Virtual Center server and get VM status on 
# CPUAddEnagbled, CPUHotRemoveEnabled, and MemoryHotAddEnabled.
# VERSION: 1.0 - Original Code
# USAGE: .\hotadd-status.ps1
# Variables: 
# $date - date in Month/Day/year format
# $vcenter - vCenter host name
# REQUIREMENTS: VMware vSphere PowerCLI
# ==============================================================================================

# Add in VMware PS Snapin
add-pssnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue

# Comment out if hard coding a vCenter below
$vcenter = Read-Host "Please enter the the vCenter you would like to connect to"

# Uncomment to hard code a vCenter server in
#$vcenter = "your-vcenter"

# Connect to vCenter and get the date...
connect-viserver $vcenter
$date = get-date -format MM-dd-yyyy

# Get VM status on CPUAddEnagbled, CPUHotRemoveEnabled, and MemoryHotAddEnabled
Get-VM | Get-View | Select Name, `
@{N="CpuHotAddEnabled";E={$_.Config.CpuHotAddEnabled}}, `
@{N="CpuHotRemoveEnabled";E={$_.Config.CpuHotRemoveEnabled}}, `
@{N="MemoryHotAddEnabled";E={$_.Config.MemoryHotAddEnabled}} | `
Export-Csv -NoTypeInformation $date-$vcenter-hot-add_status.csv
write-host "Your report has been saved as" $date-$vcenter-hot-add_status.csv
