# MRIS fields
# - Memory in MB,
# - vCPU and vCore
# - IP addresses and subnet/network
# - Disks and mount points
#
# MRIS nice to have details
# - NIC MAC

$MRIS_System_Object_Def = @{
  Name = '';
  Hostname = '';
  MemoryMB = 0;
  vCPU = 0;
  vCores = 0;
};


Get-View -ViewType VirtualMachine | foreach {
  $system = New-Object -Properties $MRIS_System_Object_Def;
  $system.Name = $_.Name;
  $system.
