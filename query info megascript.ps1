$ErrorActionPreference = 'SilentlyContinue'
import-module Active*
$computers = Get-ADComputer -Filter "Name -like 'TIM-*'" | select name
foreach ($computer in $Computers)
{if( (Test-Connection $computer.name -Quiet -count 1)) {
$model = Get-CimInstance Win32_ComputerSystem -ComputerName $computer.name | select Model
$disk = Get-CimInstance Win32_diskdrive -ComputerName $computer.name | select Model
$bios = Get-CimInstance Win32_BIOS -ComputerName $computer.name | select SMBIOSBIOSVersion, SerialNumber, Manufacturer
$lastlog = Get-ADComputer -Identity $computer.name -Properties *
$lastpatch = get-hotfix -ComputerName $computer.name | sort installedon -desc | select -First 1 installedon
$buildno = (invoke-command -ComputerName $computer.name -ScriptBlock {(Get-Item "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion").GetValue('ReleaseID')})
$currentuser = (Get-WmiObject -Class win32_process -ComputerName $computer.name | Where-Object name -Match explorer).getowner().user
$BDE = Manage-BDE -ComputerName $Computer.Name -Status C: 
   If ($BDE -Like "*An error occurred while connecting*") {$Status = "Unable to connect"} 
   If ($BDE -Like "*Protection On*") {$Status = "Protected"} 
   If ($BDE -Like "*Protection Off*") {$Status = "Not protected"} 
    $Obj = New-Object -TypeName PSObject -Property @{
		"Computer" = $computer.name 
		"Manufacturer" = $bios.manufacturer
		"Bios" =  $Bios.SMBIOSBIOSVersion
		"Model" = $model.model
		"Serial" = $bios.SerialNumber
		"Disk" = $disk.model -join ','
		"Last Logon" = $lastlog.LastLogonDate
		"BitLocker status" = $Status 
		"Last Patch date" = $lastpatch.installedon
		"Build No." = $buildno
		"Current User" = $currentuser
}
Write-Output $Obj
}
    else {
    }
}