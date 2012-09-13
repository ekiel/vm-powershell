 ==============================================================================================
# NAME: vmwaresnapreport.ps1
# AUTHOR: Eric Kiel eric<dot>kiel<at>collideoscope<dot>org
# DATE  : 9/9/2012
# COMMENT: This script will connect to a VMware Virtual Center server and report on VMs with snapshots
# that are older than 1 day.
# VERSION: 1.1 - Now sends an HTML formatted email.
# USAGE: .\vmwaresnapreport.ps1
# Variables: 
# $vcenter - vCenter host name
# $vcenterdomain - domain that vCenter resides in; yourdomain.com
# $mailserver - SMTP Mail relay
# $email1 - Distribution list or email address to send report to
# $email2 - 2nd distribution list or email address for reporting
# REQUIREMENTS: VMware vSphere PowerCLI
# ==============================================================================================
#add VMware Snapin
add-pssnapin VMware.VimAutomation.Core

#Initialize Variables
$vcenter = "yourvcenter"
$vcenterdomain = "yourdomain.com"
$email1 = "email address 1"
$email2 = "email address 2"
$mailserver = "smtp.relay"

#Set email output style
$style = "<style>BODY{font-family: Arial; font-size: 10pt;}"
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>"

$date = get-date -format MM-dd-yyyy
connect-viserver $vcenter

# Find VMs with snapshots...
$message = Get-VM | Get-Snapshot | Where { $_.Created -lt (Get-Date).AddDays(-1)} | select VM, Name, Description, Created, PowerState, SizeMB | convertto-html -head $style
# Send email with findings...
send-mailmessage –BodyasHtml -from "$vcenter@$vcenterdomain" -to "$email1", "$email2" -subject "$vcenter Snapshot Report for $date" -body "$message" -smtpserver $mailserver
