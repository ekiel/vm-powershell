# Eric Kiel Powershell Profile
# Microsoft.PowerShell_profile.ps1
# last updated 9/13/12

#start clean!
cls

#Add in MS Active Directory Module
import-module activedirectory -ErrorAction SilentlyContinue 

#Add in VMware PS Snapin
add-pssnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue 

#Add in Quest Active Roles Snapin
Add-PSSnapin Quest.ActiveRoles.ADManagement -ErrorAction SilentlyContinue 

#working directory
Set-Location c:\ps

#alias
set-alias grep select-string;

#Fancy prompt
function prompt {
"[$env:username@$([System.Net.Dns]::GetHostName()) $(Get-Location)]$ "
}

#save history! - remember to use bye to exit shell
$MaximumHistoryCount = 13KB

if (!(Test-Path c:\ps -PathType Container))
{   New-Item c:\ps -ItemType Directory
}

function bye 
{   Get-History -Count 13KB | Export-CSV c:\ps\history.csv
    exit
}

if (Test-path c:\ps\history.csv)
{   Import-CSV c:\ps\history.csv | Add-History
}

function sh
{   Get-History -Count 13KB | Export-CSV c:\ps\history.csv
}
