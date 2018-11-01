$ErrorActionPreference = 'SilentlyContinue'
ForEach ($system in Get-Content "computers.txt")
{if( (Test-Connection $system -Quiet -count 1)) {
Invoke-Command  -FilePath "e:\Get-BitlockerRecoveryKeys.ps1" -ComputerName $system
}
}