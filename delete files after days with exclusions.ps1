$path = 'e:\testfiles'
$exclusions = @(Get-Content -LiteralPath E:\exclude\exclude.txt) 
$CurrentDate = Get-Date
$Daysback = "-30"
$DatetoDelete = $CurrentDate.AddDays($Daysback)
$filestodelete = Get-ChildItem $path -recurse -Exclude $exclusions |
Where-Object {$_.LastWriteTime -lt $DatetoDelete } |
Where-Object {
    $valid = $True
    foreach ($exclusion in $exclusions) {
            If ($_.FullName -match "^$([regex]::Escape($exclusion))") {
            $valid = $False
            Break
        }
    }   
    $valid
} | select -expandproperty fullName
Write-Host $filestodelete
Remove-Item -Path $filestodelete -recurse | Where { ! $_.PSIsContainer }
