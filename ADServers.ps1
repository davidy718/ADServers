Import-Module ActiveDirectory

$ADcomp = Get-ADComputer -Filter { OperatingSystem -Like '*Windows Server*' } -Properties IPv4Address,OperatingSystem,OperatingSystemVersion
$DNSHostName = $ADcomp.DNSHostName 
$IPv4Adress = $ADcomp.IPv4Address
$OperatingSystem = $ADcomp.OperatingSystem
$YourConnection = @()
foreach ($name In $DNSHostName)
{
    $CPUUsage = Invoke-Command -ComputerName $DNSHostName -ScriptBlock {Get-Counter '\Processor(_Total)\% Processor Time' } -ErrorAction SilentlyContinue
    $MemoryUage = Invoke-Command -ComputerName $DNSHostName -ScriptBlock {Get-Counter '\Memory\Available MBytes' } -ErrorAction SilentlyContinue
    if(
    Invoke-Command -ComputerName $name -ScriptBlock {Test-Connection -ComputerName Google.com -Count 1} -ErrorAction SilentlyContinue
    )
    {
       $YourConnection += $name + " Internet Connection Is Good"
    }
    else
    {
       $YourConnection += $name + " Does Not Have Internet Connection"
    }
}

$Report = $DNSHostName,$IPv4Adress,$OperatingSystem,$CPUUsage,$MemoryUage,$YourConnection #| ConvertTo-Html -Property @{ l='Name'; e={ $_ } }| Out-File -FilePath c:\ps\Report.html
Write-Output $Report
