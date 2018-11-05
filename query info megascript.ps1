$ErrorActionPreference = 'SilentlyContinue'
import-module Active*
$computers = Get-ADComputer -Filter "Name -like 'TIM-*'" | select name #apply filter for naming convention. works better than OU filter due to possible mistakes in AD schema. Also a bit slower.
foreach ($computer in $Computers)
{if( (Test-Connection $computer.name -Quiet -count 1)) { #if condition to ping before executing. seems to be faster
$model = Get-CimInstance Win32_ComputerSystem -ComputerName $computer.name | select Model
$disk = Get-CimInstance Win32_diskdrive -ComputerName $computer.name | select Model
$bios = Get-CimInstance Win32_BIOS -ComputerName $computer.name | select SMBIOSBIOSVersion, SerialNumber, Manufacturer
$lastlog = Get-ADComputer -Identity $computer.name -Properties *
$lastpatch = get-hotfix -ComputerName $computer.name | sort installedon -desc | select -First 1 installedon
$buildno = (invoke-command -ComputerName $computer.name -ScriptBlock {(Get-Item "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion").GetValue('ReleaseID')})
$uptime =  ((get-date) - (gcim -computername $computer.name Win32_OperatingSystem).LastBootUpTime).ToString("d' days, 'hh':'mm':'ss")
$currentuser = (Get-WmiObject -Class win32_process -ComputerName $computer.name | Where-Object name -Match explorer).getowner().user #dirty way to get current user. get the process owner of an exlorer instance. there's no oficial way to get this value, so only workarounds are available. USER NEEDS TO BE LOGGED IN FOR THIS TO WORK. The windows event method, while more reliable, take about 15 minutes/pc after applying filters.
$hostname = (invoke-command -ComputerName $computer.name -ScriptBlock {hostname})
$BDE = Manage-BDE -ComputerName $Computer.Name -Status C: #for key recovery there's another script that invokes get-bitlockerstatus commend. unnecesarry to be included in this megascript. 
   If ($BDE -Like "*An error occurred while connecting*") {$Status = "Unable to connect"} 
   If ($BDE -Like "*Protection On*") {$Status = "Protected"} 
   If ($BDE -Like "*Protection Off*") {$Status = "Not protected"} 
    $Obj = New-Object -TypeName PSObject -Property @{
		"Computer" = $computer.name #computer obj in AD
		"Hostname" = $hostname #hostname - output invoked on remote computer to double check if there are dns issues
		"Manufacturer" = $bios.manufacturer
		"Bios" =  $Bios.SMBIOSBIOSVersion
		"Model" = $model.model
		"Serial" = $bios.SerialNumber
		"Disk" = $disk.model -join ','
		"Last Logon" = $lastlog.LastLogonDate
		"BitLocker status" = $Status 
		"Last Patch date" = $lastpatch.installedon
		"Build No." = $buildno
		"Current User" = $currentuser -join ','
		"System uptime" = $uptime -join ','
}
Write-Output $Obj | select Computer, Hostname, Manufacturer, Model, Bios, Serial, Disk, "BitLocker status", "Build No.", "Last Patch date", "Current User", "System uptime", "Last Logon" # new select needed for a correct output order and to correctly pipe into export-csv
}
    else {
    }
}