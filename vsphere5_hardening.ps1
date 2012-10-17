# ==============================================================================================
# NAME: vsphere5_hardening.ps1
# AUTHOR: Eric Kiel eric<dot>kiel<at>collideoscope<dot>org
# DATE  : 10/17/2012
# COMMENT: This script will modify .vmx files to add parameters to increase VM security. Please
# read and understand the security guide found at
# http://www.vmware.com/support/support-resources/hardening-guides.html
# VERSION: 1.3 - removed "vm targeting" -it was flaky and kinda scary, I'll work on this in the
# next version. I've also updated to add every option mentioned in the hardening guide.
# USAGE: .\vsphere5_hardening.ps1
# REQUIREMENTS: VMware vSphere PowerCLI
# ==============================================================================================

#Add in VMware PS Snapin
#add-pssnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue

#connect-viserver <your-vcenter>

$ExtraOptions = @{
	# Disable virtual disk shrinking
	"isolation.tools.diskShrink.disable"="true";
	"isolation.tools.diskWiper.disable"="true";
	
	# 5.0 Prevent device removal-connection-modification of devices
	"isolation.tools.setOption.disable"="true";
	"isolation.tools.connectable.disable"="true";
	"isolation.device.edit.disable"="true";
		
	# Disable copy/paste operations to/from VM
	"isolation.tools.copy.disable"="true";
	"isolation.tools.paste.disable"="true";
	"isolation.tools.dnd.disable"="false";
	"isolation.tools.setGUIOptions.Enable"="false";

	# Disable VMCI
	"vmci0.unrestricted"="false";
	
	# Log Management
	"tools.setInfo.sizeLimit"="1048576";
	"log.keepOld"="10";
	"log.rotateSize"="100000";
	
	# Limit console connections - choose how many consoles are allowed
	#"RemoteDisplay.maxConnections"="1";
	"RemoteDisplay.maxConnections"="2";

	# Remove floppy device - hardware needs to be removed by some other method
	#"floppy0.present"="false";
	
	# Disable network boot option - not in hardening guide (no real fix for e1000; see 
	# http://virtualfoundry.blogspot.com/2009/05/secrets-of-e1000.html	
	"vlance.noOprom"="true";
	"vmxnet.noOprom"="true";
	
	# 5.0 Disable serial port
	"serial0.present"="false";
	
	# 5.0 Disable parallel port
	"parallel0.present"="false";
	
	# 5.0 Disable USB
	"usb.present"="false";
	
	# Disable CD/DVD Drive - hardware needs to be removed by some other method
	#"ide1:0.present"="true";
	
	# 5.0 Disable certain unexposed features [Fusion, Workstation]
	"isolation.tools.unity.push.update.disable"="true";
	"isolation.tools.ghi.launchmenu.change"="true";
	"isolation.tools.memSchedFakeSampleStats.disable"="true";
	"isolation.tools.getCreds.disable"="true";
	"isolation.tools.ghi.autologon.disable"="true";
	"isolation.bios.bbs.disable"="true";
	"isolation.tools.ghi.protocolhandler.info.disable"="true";
	"isolation.ghi.host.shellAction.disable"="true";
	"isolation.tools.dispTopoRequest.disable"="true";
	"isolation.tools.trashFolderState.disable"="true";
	"isolation.tools.ghi.trayicon.disable"="true";
	"isolation.tools.unity.disable"="true";
	"isolation.tools.unityInterlockOperation.disable"="true";
	"isolation.tools.unity.taskbar.disable"="true";
	"isolation.tools.unityActive.disable"="true";
	"isolation.tools.unity.windowContents.disable"="true";
	"isolation.tools.vmxDnDVersionGet.disable"="true";
	"isolation.tools.guestDnDVersionSet.disable"="true";

	# Disable VIX Messaging from VM
	"isolation.tools.vixMessage.disable"="true";
	
	# Disable logging
	#"logging"="false";	
	
	# 5.0 Disable HGFS file transfers [automated VMTools Upgrade]
	"isolation.tools.hgfsServerSet.disable"="true";

	# Disable tools auto-install; must be manually initiated.
	"isolation.tools.autoInstall.disable"="true";

	# 5.0 Disable VM Monitor Control - VM not aware of hypervisor
	#"isolation.monitor.control.disable"="true";

	# 5.0 Do not send host information to guests
	"tools.guestlib.enableHostInfo"="false";
	
}   # build our configspec using the hashtable from above.

$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec

# note we have to call the GetEnumerator before we can iterate through
Foreach ($Option in $ExtraOptions.GetEnumerator()) {
    $OptionValue = New-Object VMware.Vim.optionvalue
    $OptionValue.Key = $Option.Key
    $OptionValue.Value = $Option.Value
    $vmConfigSpec.extraconfig += $OptionValue
}
# Get all vm's not including templates
#$VMs = Get-View -ViewType VirtualMachine -Property Name -Filter @{"Config.Template"="false"}   # Do it!

# Only going to get test vm's for now
$VMs = Get-View -ViewType VirtualMachine -Property Name -Filter @{"name"="test-vm"}

foreach($VM in $VMs){
    $vm.ReconfigVM($vmConfigSpec)
}
