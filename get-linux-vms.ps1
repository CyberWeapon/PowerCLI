$filter = @{"Guest.GuestFamily" = "linuxGuest"};
$vmv = Get-View -ViewType VirtualMachine -Filter $filter;
Write-Output ("Found {0}" -f $vmv.Count);
$vmv | `
  select Name,
  @{Name = "GuestOS"; Expression = {$_.Guest.GuestFullName}},
  @{Name = "PowerState"; Expression = {$_.Runtime.PowerState}} | `
    Export-Csv -Path ./apdc-kedc-linux-vms.csv -NoTypeInformation;
