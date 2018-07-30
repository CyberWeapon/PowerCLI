# Snippets

``` Powershell
(Get-View -Property Guest -Filter @{'Name' = 'vkew-bronze'} -ViewType VirtualMachine).Guest.Disk | %{$_.Capacity / (1024 * 1024 * 1024)}
```
