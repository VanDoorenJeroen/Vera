$PASSWORDPATH = "C:\ProgramData\credentials.txt"
$USER = $env:USERDOMAIN+"\"+$env:USERNAME

if (!(Test-Path $PASSWORDPATH)) {
    Read-Host "Geef uw paswoord op" -AsSecureString | ConvertFrom-SecureString | Out-File $PASSWORDPATH 
}

$password = Get-Content $Credentials | ConvertTo-SecureString
$Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $USER, $password

