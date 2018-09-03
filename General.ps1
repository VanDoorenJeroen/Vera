##############################################
###                                        ###
###                                        ###
###            GENERAL FUNCTIONS           ###
###                                        ###
###                                        ###
##############################################
$USERNAME = $env:USERNAME
$CREDENTIALPATH = "C:\Users\$USERNAME\Appdata\creds.txt"
#$CREDENTIALFILE = "creds.txt"


<#
GET ADMIN CREDENTIALS
#>
if(Test-Path $CREDENTIALPATH)
{
    $Password = Get-Content $CREDENTIALPATH | ConvertTo-SecureString 
}
else
{
    $Password = Read-Host "Enter password from User $USERNAME" -AsSecureString | ConvertFrom-SecureString | Out-File $CREDENTIALPATH
}

$Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $USERNAME,$Password

<#
EXCHANGE CONNECTION
#>
Write-Host "Opening Exchange PSSession...."
$ExchangeSession = New-PSSession -ConfigurationName Microsoft.EXCHANGE -ConnectionUri http://ACEXCVM001/Powershell/ -Authentication Kerberos -Credential $Credentials

Import-PSSession $ExchangeSession -DisableNameChecking
Write-Host "Exchange PSSession succesfully opened"

<#
IMPORT ACTIVE DIRECTORY
#>
Import-Module ActiveDirectory

<#
VCENTER CONNECTION
#>
Write-Host "Opening VCenter Connection...."
$VIConnection = Connect-VIServer "ACVCEVM001" -Credential $Credentials -WarningAction SilentlyContinue
Write-Host "VIConnection can now be used to check VM Servers"