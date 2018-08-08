$Server = "GMFILVM001"

#Test Connectie met PC
#Niet bereikbaar - geef melding
if (-not (Test-Connection $Server -Count 2 -quiet)) {
    "Machine $server is niet bereikbaar"
    Exit 
}

#Full name
#Geef de FQDN weer
Write-Host "`n---Full Name---"
$ServerFQDN = [System.Net.Dns]::GetHostByName($Server)
Write-Host "Servernaam:"$ServerFQDN.Hostname

#OS
#Geef het besturingssysteem weer met 32/64-bit
Write-Host "`n---OS---"
(Get-WmiObject win32_operatingsystem -computerName $Server).caption
(Get-WmiObject win32_operatingsystem -computerName $Server).OSArchitecture 

#MAC address
#Geef de MAC addressen weer
Write-Host "`n---MAC Address---"
$MAC = Get-WmiObject win32_networkadapterconfiguration -ComputerName $Server
Write-Host "MAC: "$MAC.macaddress

#IP Address
#Toon het IP adres.
Write-Host "`n---IPv4 Address---"
Write-Host "IP address:"$ServerFQDN.AddressList

#VM
#Maak connectie met de VI Server en steek de VM server informatie in $VM
$PW = Read-Host "PW?"
$connection = Connect-VIServer "ACVCEVM001" -User gmmeise\jvandooren -Password $PW -WarningAction SilentlyContinue
$VM = Get-VM $Server 
Disconnect-VIServer $connection -Confirm:$false

#Processor
#Geef het aantal processors weer van de VM
Write-Host "`n---Get # Processors---"
$VM.NumCpu

#RAM
#Geef het aantal RAM geheugen weer in GB van de VM
Write-Host "`n---RAM---"
$VM.MemoryGB

#HD
#Geef de schijven weer met hun capaciteit
Write-Host "`n---Space on HD---"
Get-WmiObject -Class Win32_LogicalDisk -ComputerName $SERVER -Filter "Size > 0" | Select-Object Name,@{n='TotalSize';e={($_.Size/1GB).ToString('#.#')+' GB'}}| Format-Table -Property *

#Datastore
#Geef de datastore weer waarop de VM staat
$vm | Get-Datastore | Format-Table @{L="---Datastore---";E={$_.Name}}

#Wait to continue
Read-Host "Alles genoteerd?"

#Roles
#Geef alle geinstalleerde roles weer
if($OS -like "*2008*") { Get-WmiObject -Class win32_Serverfeature -ComputerName $server | Format-Table @{L="---Roles Installed---";E={$_.Name }} }
else { Invoke-Command -ComputerName $Server {Get-WindowsFeature} | Where-Object Installed | Format-Table @{L="---Roles Installed---";E={$_.DisplayName }} }

#Software
#Geef de lijst weer van geinstalleerde software
Invoke-Command -ComputerName $server -ScriptBlock { Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -notlike "VM*" -and $_.DisplayName -notlike "Visual*" -and $_.DisplayName -notlike "Update*" -and $_.DisplayName -notlike "Security*"} | Select-Object DisplayName | Format-Table}

#Services
#Geef de lijst weer van actieve services
Get-WmiObject Win32_Service -ComputerName $Server | Where-Object { $_.State -eq "Running" } | Format-Table @{L="---Service Running---";E={$_.DisplayName}}, StartName

