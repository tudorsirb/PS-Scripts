# Identify all the Bitlocker volumes.
$BitlockerVolumers = Get-BitLockerVolume
$hostname = hostname
# For each volume, get the RecoveryPassowrd and display it.
$BitlockerVolumers |
    ForEach-Object {
        $MountPoint = $_.MountPoint 
        $RecoveryKey = [string]($_.KeyProtector).RecoveryPassword       
		$id = [string]($_.KeyProtector).KeyProtectorId
        if ($RecoveryKey.Length -gt 5) {
            Write-Output ("$hostname ; The drive $MountPoint with ID $id has a recovery key $RecoveryKey.")
        }        
    }