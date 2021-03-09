start-Sleep -seconds 300
$services = Get-Service | where-object {$_.name -like '*canvas*' -or $_.name -like '*sustainalytics*'}
$textname = ".\serviceslogs\$(get-date -Format yyyyddmm_hhmmtt).txt﻿"
New-Item $textname
foreach ($services in $services) {
$arrService = Get-Service -Name $services.name
if ($arrService.Status -eq 'Running'){
write-host "$($services.name) is already $($arrService.status) - aborting"
add-Content -Path $textname "$($services.name) is already $($arrService.status) - aborting"}
else {
if ($arrService.Status -ne 'Running' -or 'Starting') {
    Start-Service $services.Name
    write-host "$($services.name) is $($arrService.status)"
    write-host "$($services.name) Service starting"
    Start-Sleep -seconds 30
    $arrService.Refresh()
    if ($arrService.Status -eq 'Running')
    {
        Write-Host "$($services.name) is now Running"
        Add-Content -Path $textname "$($services.name) is now Running"
    }
    else{
	Write-Host "$($services.name) is not Running"
	Add-Content -Path $textname "$($services.name) is not Running"}
}
}
}cd f: