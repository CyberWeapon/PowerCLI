# Questions from other teams

1. What is the total socket count for KEDC, APDC and SSDC?

``` PowerShell
# Connect to APDC and KEDC.
$x = Get-View -ViewType HostSystem -Property Summary |
  select -ExpandProperty Summary |
  select -ExpandProperty Hardware |
  Measure-Object -Property NumCpuPkgs -Sum

# Connect to SSDC.
$y = Get-View -ViewType HostSystem -Property Summary |
  select -ExpandProperty Summary |
  select -ExpandProperty Hardware |
  Measure-Object -Property NumCpuPkgs -Sum

$x.Sum + $y.Sum
```

List all of the hostnames and the number of sockets they have.

``` PowerShell
# Connect to APDC and KEDC.
Get-View -ViewType HostSystem -Property Name,Summary |
  select -ExpandProperty Summary -Property Name |
  select -ExpandProperty Hardware -Property Name |
  select Name, NumCpuPkgs

# Connect to SSDC.
Get-View -ViewType HostSystem -Property Name,Summary |
  select -ExpandProperty Summary -Property Name |
  select -ExpandProperty Hardware -Property Name |
  select Name, NumCpuPkgs
```
