reagentc /disable
$partition = (get-partition -disknumber 0).PartitionNumber
if ($partition -like 4)
{Remove-Partition -PartitionNumber 4 -DiskNumber 0 -confirm:$false}
if ($partition -like 5)
{Remove-Partition -PartitionNumber 5 -DiskNumber 0 -confirm:$false}
$MaxSize = (Get-PartitionSupportedSize -DriveLetter c).sizeMax
$Size = $MaxSize-576716800
Resize-Partition -DiskNumber 0 -PartitionNumber 3 -Size $Size
New-Partition -DiskNumber 0 -UseMaximumSize -GptType '{de94bba4-06d1-4d40-a16a-bfd50179d6ac}' -AssignDriveLetter
Format-Volume -DriveLetter D -FileSystem NTFS
reagentc /enable