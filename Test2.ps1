 $PASSWORDPATH = "C:\ProgramData\credentials.txt"
$USER = $env:USERDOMAIN+"\"+$env:USERNAME

if (!(Test-Path $PASSWORDPATH)) {
    Read-Host "Geef uw paswoord op" -AsSecureString | ConvertFrom-SecureString | Out-File $PASSWORDPATH 
}

$password = Get-Content $PASSWORDPATH | ConvertTo-SecureString
$Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $USER, $password

<#
Make a connection with the VIServer and get a list of all hosts.
#>

$connection = Connect-VIServer "ACVCEVM001" -Credential $Credentials -WarningAction SilentlyContinue

$Names = Get-VM -Server $connection | select-object Name
$LijstVM = @{}
foreach ($name in $Names)
{
    $key = $name.Name
    $value = ""
    $date = Get-CimInstance -ClassName win32_operatingsystem -ComputerName $name.Name -ErrorAction SilentlyContinue | Select-Object LastBootuptime  
    if($date) { $value = $date.LastBootuptime }
    $lijstVM.Add($key, $value) 
}
$LijstVM