$ErrorActionPreference = 'SilentlyContinue'
import-module Active*
$computers = Get-ADComputer -Filter "Name -like 'TIM-*'" | select name
foreach ($computer in $Computers) {
if( (Test-Connection $computer.name -Quiet -count 1)) {
$lastlogon = (Get-WmiObject -Class win32_process -ComputerName $computer.name | Where-Object name -Match explorer).getowner().user
$hostname = (invoke-command -ComputerName $computer.name -ScriptBlock {hostname})
 $Obj = New-Object -TypeName PSObject -Property @{
		"Current user" = $lastlogon
		"Hostname" = $hostname		
}
Write-Output $Obj
}
}
else
{}

