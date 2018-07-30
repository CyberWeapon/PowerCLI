function Get-VMDetails {
    [CmdletBinding(
        SupportsShouldProcess,
        DefaultParameterSetName = 'List')]
    param (
        # Path to a file containing a list of VM names.
        [Parameter(
            ParameterSetName = 'List'
        )]
        [string]
        $Path,

        #    [parameter()]
        # Get all VMs in a specific data center.
        [Parameter(
            ParameterSetName = 'Category'
        )]
        [alias('dc')]
        [ValidateSet('ADC', 'BDC', 'CDC')]
        [string]$DataCenter = 'ADC',

        # All VM for a specific app.
        [Parameter(
            ParameterSetName = 'Category'
        )]
        [alias('app')]
        [ValidateSet('APP1', 'APP2')]
        [string]$AppName = 'APP1',

        [switch]$LogNotFound,

        [alias('WithHD')]
        [switch]$WithHardDrives
    )

    begin {
        Write-Verbose "Now for some fun and games!"
        $vmdetails = "./$DataCenter-$listname-details.csv";
        $vmhddetails = "./$DataCenter-$listname-hd-details.csv";
        $notfound = "./$DataCenter-$listname-notfound.txt";

        Remove-Item -ErrorAction SilentlyContinue $vmdetails;
        Remove-Item -ErrorAction SilentlyContinue $vmhddetails;
        Remove-Item -ErrorAction SilentlyContinue $notfound;

        if (($null -eq $Path) -and (-not (Test-Path -Path $Path -IsValid))) { 
            # ThrowError -errorId 1234 -errorCategory InvalidArgument `
            #   -ExceptionName System.IO.FileNotFoundException -ExceptionMessage "The path for the VM list was not found."
            $e = New-Object -TypeName System.IO.FileNotFoundException
            throw $e
        }
    }

    process {
      if ($Path -ne "") {
        Get-Content $Path | ForEach-Object {
            Write-Verbose $_
            # $vm = Get-VM -ErrorAction SilentlyContinue -Name $_;
            # if ($vm -ne $null) {
            #     $vm | Select-Object @{Name = "DC"; Expression = {$DataCenter}}, Name, PowerState, NumCpu, MemoryGB `
            #         | Export-CSV -NoTypeInformation -Append -Path $vmdetails;
            #     if ($WithHardDrives) {
            #         Get-HardDisk -VM $vm | ForEach-Object {
            #             $_ | Select-Object @{Name = "VMName"; Expression = {$vm.Name}}, Name, CapacityGB `
            #                 | Export-CSV -NoTypeInformation -Append -Path $vmhddetails;
            #         }
            #     }
            # }
            # else {
            #     if ($LogNotFound) {
            #         "$_ was not found in $DataCenter!" | Out-File -Append -Encoding ascii -Path $notfound;
            #     }
            # }
        }
      }
    }

    end {
        Write-Verbose "We are outta here!"
    }
}

