$Server = "GMFILVM001"

#Test Connectie
if (-not (Test-Connection $Server -Count 2 -quiet)) {
    "Machine $server is niet bereikbaar"
    Exit 
}

#Full name
Write-Host "`n---Full Name---"
$ServerFQDN = [System.Net.Dns]::GetHostByName($Server)
Write-Host "Servernaam:"$ServerFQDN.Hostname

#OS
Write-Host "`n---OS---"
(Get-WmiObject win32_operatingsystem -computerName $Server).caption
(Get-WmiObject win32_operatingsystem -computerName $Server).OSArchitecture 

#MAC address
Write-Host "`n---MAC Address---"
$MAC = Get-WmiObject win32_networkadapterconfiguration -ComputerName $Server
Write-Host "MAC: "$MAC.macaddress

#IP Address
Write-Host "`n---IPv4 Address---"
Write-Host "IP address:"$ServerFQDN.AddressList

#VM
$PW = Read-Host "PW?"
$connection = Connect-VIServer "ACVCEVM001" -User gmmeise\jvandooren -Password $PW -WarningAction SilentlyContinue
$VM = Get-VM $Server 
Disconnect-VIServer $connection -Confirm:$false

#Processor
Write-Host "`n---Get # Processors---"
$VM.NumCpu

#RAM
Write-Host "`n---RAM---"
$VM.MemoryGB

#HD
Write-Host "`n---Space on HD---"
Get-WmiObject -Class Win32_LogicalDisk -ComputerName $SERVER -Filter "Size > 0" | Select-Object Name,@{n='TotalSize';e={($_.Size/1GB).ToString('#.#')+' GB'}}| Format-Table -Property *

#Datastore
$vm | Get-Datastore | Format-Table @{L="---Datastore---";E={$_.Name}}

#Wait to continue
Read-Host "Alles genoteerd?"

#Roles
if($OS -like "*2008*") { Get-WmiObject -Class win32_Serverfeature -ComputerName $server | Format-Table @{L="---Roles Installed---";E={$_.Name }} }
else { Invoke-Command -ComputerName $Server {Get-WindowsFeature} | Where-Object Installed | Format-Table @{L="---Roles Installed---";E={$_.DisplayName }} }

#Software
#Get-WmiObject -Class win32_product -ComputerName $Server | Where-Object {$_.Name -notlike "Microsoft*" -and $_.Name -notlike "SQL*" -and $_.Name -notlike "VM*" -and $_.Name -notlike "Visual*"} | Format-Table @{L="---Software installed---";E={$_.Name}}
Invoke-Command -ComputerName $server -ScriptBlock { Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -notlike "VM*" -and $_.DisplayName -notlike "Visual*" -and $_.DisplayName -notlike "Update*" -and $_.DisplayName -notlike "Security*"} | Select-Object DisplayName | Format-Table}

#Services
Get-WmiObject Win32_Service -ComputerName $Server | Where-Object { $_.State -eq "Running" } | Format-Table @{L="---Service Running---";E={$_.DisplayName}}, StartName

