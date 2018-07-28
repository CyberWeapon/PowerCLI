<#
.SYNOPSIS
	Short description
.DESCRIPTION
	Long description
.EXAMPLE
	PS C:\> Remove-MRSnapshot -VM $vm -Name "Testing" -Limit 5 -WaitTime 30
	Removes all snapshots named "Testing" from all the VMs provided limited to 5 tasks at a time with a 30 second wait between checking the queue.

	PS C:\> Get-VM -Name (Get-Content .\vm.list) | Remove-MRSnapshot -Name "Testing" -Limit 5 -WaitTime 30
	Removes all snapshots named "Testing" from all the VMs provided limited to 5 tasks at a time with a 30 second wait between checking the queue.

	PS C:\> Remove-MRSnapshot -VM (Get-VM -Name (Get-Content .\vm.list)) -Name "Testing" -Limit 5 -WaitTime 30
	Removes all snapshots named "Testing" from all the VMs provided limited to 5 tasks at a time with a 30 second wait between checking the queue.
.INPUTS
	Inputs (if any)
.OUTPUTS
	Output (if any)
.NOTES
	Case 1, there are no running snapshot removal tasks and there are snapshots to remove.
		Don't wait remove the snapshot.
	Case 2, there are no snapshots to remove.
	Case 3, there are less then the limit running removal tasks and there are snapshots to remove.
	Case 4, the number of running snapshot removal tasks equals the limit and there are snapshots to remove.
	Case 5, there are more running snapshot removal tasks than the limit and there are snapshots to remove.
	While a snapshot removal task is runninng, the VM still shows there is a snapshot.

	For each VM in the pipeline, add all snapshots for that VM to the queue
	check to see if there is a running snapshot removal task for any snapshots in the queue
		yes then dont' add it from the queue
		no add it to the queue
	while the queue is not empty
		Get the list of running snapshot removal tasks
		while the number of running tasks is equal or greater than the limit
			wait a while
			how many remove tasks are running now
		there are fewer running tasks than the limit
		remove a snapshot and remove it from the queue
	when a task is started for a VM, Add the name to the bucket
	where the datastores
	Create a new object for each VM with only it's Name, DS Name and Host name.
	Add the new object to a running array.
	Add the next VM,
	With the third VM, check to see if any running VMs have the same host.
	check if any running VMs have the same datastore.

	assuming 2 VM tasks can run at the same time on the same host.
	assuming 2 VM tasks can run at the same time on the same ds.

	first vm, cannot violate assumptions.
	second vm, cannot violate assumptions
	third to nth vm, may violate assumptions if any running task have the same host, datastore or both.
	Count up the totals for each array of datastores and hosts.
	If the next VM uses a datastore where the total for that datastore is 2, skip.
	If the next VM uses a host where the total for that host is 2, skip.
	else add to the bucket and update the totals.
#>
function Remove-MRSnapshot {
	[CmdletBinding()]
	param (
		# An array of VM objects.
		[Parameter(
			Mandatory=$true,
			ValueFromPipeline=$true)]
		[VMware.VimAutomation.ViCore.Types.V1.Inventory.VirtualMachine[]]
		$VM,

		# The name of the snapshot to remove.
		[Parameter()]
		[string]
		$Name,

		# The maximum number of running tasks.
		[Parameter()]
		[int]
		$Limit = 5,

		# The time in seconds to wait before checking the queue
		[Parameter()]
		[int]
		$WaitTime = 30
	)
	
	begin {
		Write-Verbose "Now we can being!"
		$snap = New-Object -TypeName System.Collections.Queue
		$runningTask = @()
	}
	
	process {
		if ($VM.Count -gt 1) {
			$q = $true
			$runningTask = Get-Task -Status Running | Where-Object -FilterScript {$_.Name -eq 'RemoveSnapshot_Task'}
			Write-Verbose ("Building the Queue: These [{0}] VMs have snapshots being removed" `
				-f (($runningTask | Foreach-Object {$_.ExtensionData.Info.EntityName}) -join ', '))
			Get-Snapshot -VM $vm -Name $Name -ErrorAction SilentlyContinue | ForEach-Object {
				$s = $_
				$runningTask | Foreach-Object {if ($_.ExtensionData.Info.EntityName -eq $s.VM.Name) {$q = $false}}
				if ($q) {
					Write-Verbose ("{0} is being queued." -f $_.VM.Name)
					$snap.Enqueue($_)
				}
				else {
					Write-Verbose ("{0} already has a snapshot task running." -f $_.VM.Name)
					$q = $true
				}
			}
			Write-Verbose ("{0} snapshots have been queued." -f $snap.Count)
			Write-Verbose ("Given {0} VMs and found {1} snapshots." -f $VM.Count, $snap.Count)
			while ($snap.Count -ne 0) {
				Write-Verbose ("Checking the running tasks, found [{0}] with a limit of [{1}]. [{2}] snapshots left." -f $runningTask.Count, $Limit, $snap.Count)
				$runningTask = Get-Task -Status Running | Where-Object -FilterScript {$_.Name -eq 'RemoveSnapshot_Task'}
				while ($runningTask.Count -ge $Limit) {
					Write-Verbose ("There are {0} snapshot removal tasks in the queue" -f $runningTask.Count)
					Write-Verbose "Sleeping for $WaitTime seconds"
					Start-Sleep -Seconds $WaitTime
					$runningTask = Get-Task -Status Running | Where-Object -FilterScript {$_.Name -eq 'RemoveSnapshot_Task'}
					$v = ($runningTask | Foreach-Object {$_.ExtensionData.Info.EntityName}) -join ', '
					Write-Verbose ("These [{0}] VMs have snapshots being removed" -f $v)
				}
				Write-Verbose ("Removing snapshot [{0}] for VM [{1}]." -f $snap.Peek().Name, $snap.Peek().VM.Name)
				$blackhole = Remove-Snapshot $snap.Dequeue() -RunAsync -Confirm:$false -ErrorAction SilentlyContinue
				Write-Verbose ("Created a task to remove a snapshot from [{0}]" -f $blackhole.Name)
			}
		} else {
			Write-Verbose ("Processing VM {0}." -f $VM.Name)
			Get-Snapshot -VM $_ -Name $Name -ErrorAction SilentlyContinue | ForEach-Object {$snap.Enqueue($_)}
			Write-Verbose ("The wait queue has {0} snapshots." -f $snap.Count)
			$runningTask = Get-Task -Status Running | Where-Object -FilterScript {$_.Name -eq 'RemoveSnapshot_Task'}
			Write-Verbose ("There are {0} snapshot removal tasks in the queue" -f $runningTask.Count)
			while ($runningTask.Count -lt $Limit -and $snap.Count -ne 0) {
				Write-Verbose ("Removing snapshot [{0}] for VM [{1}]." -f $snap.Peek().Name, $snap.Peek().VM.Name)
				$blackhole = Remove-Snapshot $snap.Dequeue() -RunAsync -Confirm:$false
				$runningTask = Get-Task -Status Running | Where-Object -FilterScript {$_.Name -eq 'RemoveSnapshot_Task'}
				Write-Verbose ("There are {0} snapshot removal tasks in the queue" -f $runningTask.Count)
				Start-Sleep -Seconds $WaitTime
			}
		}
	}
	
	end {
		Write-Verbose "End of line!"
	}
}


<#
 # Looking for a way to run asyncronus commands and monitor them. Keeping only a
 # specific number running at one time.
 #
 # New-Snapshots returns a task. This task is not compatible with Get-Task.
 # To get the create snapshot tasks current status use Get-Task -Id taskobj.Id
 # When you get a snapshot, the PowerState is the state the VM will start if the 
 # snapshot is reverted to.
 #>

function theoldway () {
	$vm = Get-VMHost -Name 'pale-booboo-vc.itsso.gc.ca'| Get-VM | Where-Object {$_.PowerState -eq 'PoweredOn'}
	$snap = New-Object -TypeName System.Collections.Queue
	Get-Snapshot -VM $vm -Name 'Testing' -ErrorAction SilentlyContinue | ForEach-Object {$snap.Enqueue($_)}
	
	
	$limit = 2
	$waittime = 5
	$runningTask = @()
	
	# while there are snapshots to delete
	# check how many are running
	# - if it's less than the limit and there are snapshots left, start another one and remove it from the snapshot list.
	# - If it at the limit, wait for some time.
	# check again.
	
	while ($snap.Count -ne 0) {
		while ($runningTask.Count -lt $limit -and $snap.Count -ne 0) {
			Write-Output "Removing a snapshot"
			$blackhole = Remove-Snapshot $snap.Dequeue() -RunAsync -Confirm:$false
			$runningTask = Get-Task -Status Running | Where-Object -FilterScript {$_.Name -eq 'RemoveSnapshot_Task'}
		}
		Get-Task | Where-Object -Property State -Value 'Success' -NE
		Write-Output ("There are {0} snapshots being removed." -f $runningTask.Count)
		Write-Output ("{0} snapshots left to delete." -f $snap.Count)
		Write-Output "Sleeping"
		Start-Sleep -Seconds $waittime
		$runningTask = Get-Task -Status Running | Where-Object -FilterScript {$_.Name -eq 'RemoveSnapshot_Task'}
		Write-Output "Waking"
	}	
}
