# README

New cmdlets to provide batch processing to Remove-Snapshot and New-Snapshot. It provides functionality that limits the number of running tasks and allows specifying the polling rate. It's not clear to me how VMware determines scheduling if a large number of snapshot tasks are run with the `RunAsync` switch.
