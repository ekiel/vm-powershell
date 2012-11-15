# ==============================================================================================
# NAME: vmware_view_report.ps1
# AUTHOR: Eric Kiel eric<dot>kiel<at>collideoscope<dot>org
# DATE : 11/14/2012
# COMMENT: This script will connect to a VMware View Connection Server and report on changes
# made in the past 24 hours and Pool status with desktop count.
# VERSION: 1.1 - Updated to include changes in past 72 hours.
# USAGE: .\vmware_view_report.ps1 [Must be run on connection server; user running script must
# have administrator rights assigned in View Manager]
# Variables:
# $domain - domain that View resides in; yourdomain.com
# $mailserver - SMTP Mail relay
# $email1 - Distribution list or email address to send report to
# $email2 - 2nd distribution list or email address for reporting
# REQUIREMENTS: VMware View CLI [Installed by default on View Connection Servers]
# ==============================================================================================
#add VMware View Snapin
Add-PSSnapin vmware.view.broker -ErrorAction SilentlyContinue

#Initialize Variables
$domain = "yourdomain.com"
$email1 = "email1@yourdomain.com"
$email2 = "email2@yourdomain.com"
$mailserver = "mailrelay.yourdomain.com"

$viewconnectionserver = hostname

#Set email output style
$style = "<style>BODY{font-family: Arial; font-size: 10pt;}"
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>"

$date = get-date -format MM-dd-yyyy

# Generate report on changes in the past 72 hours
$changes = get-eventreport -viewname config_changes -startdate (get-date).AddDays(-3) | select time, moduleandeventtext, userdisplayname, desktopid | convertto-html -head $style
#Clean up the style... need to figure out why this loops
clear-variable style
# Generate Pool Report...
$pools = get-pool | select Pool_ID, DisplayName, Description, DeliveryModel, Enabled, Persistence, MaximumCount, MinimumCount | convertto-html -head $style

# Send email with findings...
send-mailmessage –BodyasHtml -from "$viewconnectionserver@$domain" -to "$email1", "$email2" -subject "VMware View Report for $date" -body "View Changes in the Past 72 Hours $changes Pool Report $pools " -smtpserver $mailserver
