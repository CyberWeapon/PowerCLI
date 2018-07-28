<#
.SYNOPSIS
	Create snapshots VMs listed
.DESCRIPTION
	Create a snapshot for each VM from the provided list, generally a file. Limit the number
	of running snapshots to a maximum value.
.EXAMPLE
	PS C:\> Start-Snapshots -Name 'Just Testing' -VMName vm01, vm02, vm03
	Create a snapshot for each of the three VMs. All of the snapshot names will be
	"Just Testing".
.INPUTS
	None
.OUTPUTS
	Output (if any)
.NOTES
	Get the list of names. This may come from a file or an array of names on the commandline.
	Create up to a maximum number of snapshots from the list. This is the running queue.
	Check to see if any tasks in the running queue have finished. If they have remove 
	the task from the queue and create another snapshot.
	Continue until the queue is empty.
#>
param (
	# Name to use for the snapshot.
	[Parameter()]
	[String]
	$Name,

	# An array of VM names.
	[Parameter()]
	[String[]]
	$VMName,

	# Description to use for the snapshot.
	[Parameter()]
	[string]
	$Description,

	# Maximum number of create snapshots tasks running at the same time.
	[Parameter()]
	[int16]
	$Limit
)

function update-queue () {
	$queue | ForEach-Object {
		Write-Output ("Get-Task {0}" -f $_)
		if ($queue[$_] -ne 'running') {
			$queue[$_]
		}

	}
}
$queue = @{}

if ($VMName.Count -eq 0) {
	Write-Error "There are no VMs specified."
}

$VMName | ForEach-Object {
	Write-Output ("`$task = Get-VM '{0}' | New-Snapshot -Name '{1}' -Description '{2}' -Memory -RunAsync" -f $_, $Name, $Description)
	$queue[$_] = 'running'
}

# vkewnapkin, vkewnarwal These are being decommissioned