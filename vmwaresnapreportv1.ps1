# ==============================================================================================
# NAME: vmwaresnapreport.ps1
# AUTHOR: Eric Kiel
# DATE  : 4/27/2012
# COMMENT: This script will connect to a VMware Virtual Center server and report on VMs with snapshots
# that are older than 1 day.
# VERSION: 1.0 - Original Code
# USAGE: .\vmwaresnapreport.ps1
# Variables: 
# $date - date in Month/Day/year format
# $vcenter - vCenter host name
# $vcenterdomain - domain that vCenter resides in; yourdomain.com
# $mailserver - SMTP Mail relay
# $email1 - Distribution list or email address to send report to
# $email2 - 2nd distribution list or email address for reporting
# REQUIREMENTS: VMware vSphere PowerCLI
# ==============================================================================================

#Initialize Variables
$vcenter = "YOUR VCENTER HOST NAME"
$vcenterdomain = "VCENTER DOMAIN"
$mailserver = "YOUR SMTP SERVER"
$email1 = "YOUR DISTRIBUTION LIST OR EMAIL ADDRESS"
$email2 = "DISTRIBUTION LIST 2 OR ANOTHER EMAIL ADDRESS"

# Enable VMware Snap-in
add-pssnapin VMware.VimAutomation.Core

$date = get-date -format MM-dd-yyyy
connect-viserver $vcenter
Get-VM | Get-Snapshot | Where { $_.Created -lt (Get-Date).AddDays(-1)} | select VM, Name, Description, Created, PowerState, SizeMB | export-csv $date-$vcenter-snapshots.csv -notypeinformation
send-mailmessage -from "$vcenter@$vcenterdomain" -to "$email1", "$email2" -subject "$vcenter Snapshot Report for $date" -attachment "$date-$vcenter-snapshots.csv" -body "Snapshot report for $vcenter generated on $date" -smtpserver $mailserver
