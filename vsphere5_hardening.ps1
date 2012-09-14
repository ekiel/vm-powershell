# ==============================================================================================
# NAME: vsphere5_hardening.ps1
# AUTHOR: Eric Kiel eric<dot>kiel<at>collideoscope<dot>org
# DATE  : 4/27/2012
# COMMENT: This script will modify .vmx files to add parameters to increase VM security. Please
# read and understand the security guide found at
# http://www.vmware.com/support/support-resources/hardening-guides.html
# VERSION: 1.2 - Updated for safety
# USAGE: .\vmwaresnapreport.ps1
# Optional Variables: 
# $vcenter : Target vCenter server
# $targetvms : VMs to be modified; please test selection by using get-vm VMNAME*
# REQUIREMENTS: VMware vSphere PowerCLI
# ==============================================================================================

# Please be sure to understand what you are doing when uncommenting the following lines.
# Also see lines 107-108
#$vcenter = Read-Host "Please enter your vCenter Server"
#connect-viserver $vcenter
#$targetvms = Read-Host "Please enter the target VMs (wild card * allowed)"
#get-vm $targetvms

$ExtraOptions = @{
# Disable virtual disk shrinking
	"isolation.tools.diskShrink.disable"="true";
	"isolation.tools.diskWiper.disable"="true";
	"isolation.tools.setOption.disable"="true";
	"isolation.tools.connectable.disable"="true";

# Disable copy/paste operations VM - default in 4.1+
	"isolation.tools.copy.disable"="true";
	"isolation.tools.paste.disable"="true";
	"isolation.tools.setGUIOptions.Enable"="false";
	
# Disable VMCI
	"vmci0.unrestricted"="FALSE";
	
# Limit VMX File size to 1MB
	"tools.setInfo.sizeLimit"="1048576";
	"log.keepOld"="10";
	"log.rotateSize"="100000";

# Limit console connections
	"RemoteDisplay.maxConnections"="1";
	
# Remove floppy device
	"floppy0.present"="false";
	"vlance.noOprom"="true";
	"vmxnet.noOprom"="true";
	
# 5.0 Disable serial port
	"serial0.present"="false";
	
# 5.0 Disable parallel port
	"parallel0.present"="false";
	
# 5.0 Disable USB
	"usb.present"="false";
	
# Disable CD/DVD Drive
	#"ide1:0.present"="false";
	
# 5.0 Prevent device removal-connection-modification of devices
	#"isolation.device.connection.disable"="true";
	#"isolation.device.edit.disable"="true";
	
# 5.0 Disable certain unexposed features [Fusion, Workstation]
	"isolation.tools.unity.push.update.disable"="true";
	"isolation.tools.ghi.launchmenu.change"="true";
	"isolation.tools.memSchedFakeSampleStats.disable"="true";
	"isolation.tools.getCreds.disable"="true";
	"isolation.tools.ghi.autologon.disable"="true";
	"isolation.bios.bbs.disable"="true";
	
# 5.0 Disable HGFS file transfers [automated VMTools Upgrade]
	#"isolation.tools.hgfsServerSet.disable"="true";
	
# 5.0 Disable VM Monitor Control
	#"isolation.monitor.control.disable"="true";
	
# 5.0 Disable tools auto-install
	#"isolation.tools.autoInstall.disable"="true";
	
# 5.0 Do not send host information to guests
	#"tools.guestlib.enableHostInfo."="false";
	
}   
# build our configspec using the hashtable from above. 

$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec

# note we have to call the GetEnumerator before we can iterate through
Foreach ($Option in $ExtraOptions.GetEnumerator()) {
    $OptionValue = New-Object VMware.Vim.optionvalue
    $OptionValue.Key = $Option.Key
    $OptionValue.Value = $Option.Value
    $vmConfigSpec.extraconfig += $OptionValue
}
# Get ALL VMs in vCenter - be sure you want to do this!
#$VMs = Get-View -ViewType VirtualMachine -Property Name -Filter @{"Config.Template"="false"}

# Uncomment the line below for Question/Response functionality
#$VMs = Get-View -ViewType VirtualMachine -Property Name -Filter @{"name"="$targetvms"}

# Or use some sanity and hardcode your selection!
$VMs = Get-View -ViewType VirtualMachine -Property Name -Filter @{"name"="dev*"}

foreach($VM in $VMs){
    $vm.ReconfigVM($vmConfigSpec)
}
