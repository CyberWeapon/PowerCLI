$vmlist = './pay-vms.txt';

Get-Content $vmlist | foreach {
  Get-View -ViewType VirtualMachine -Property Summary -Filter @{"Name" = $_} `
  | select @{Name = "Name"; Expression = {$_.Summary.Config.Name}},
    @{Name = "GuestOS"; Expression = {$_.Summary.Config.GuestFullName}},
    @{Name = "PowerState"; Expression = {$_.Summary.Runtime.PowerState}},
    @{Name = "MemorySizeMB"; Expression = {$_.Summary.Config.MemorySizeMB}},
    @{Name = "NumCpu"; Expression = {$_.Summary.Config.NumCpu}};
}

