##############################################
###                                        ###
###                                        ###
###            GENERAL FUNCTIONS           ###
###                                        ###
###                                        ###
##############################################

<#
VARIABLES
#>
$USERNAME = $env:USERNAME
$CREDENTIALPATH = "C:\Users\$USERNAME\Appdata\creds.txt"
$CONNECTIONURI = "http://ACEXCVM001/Powershell/"

<#
IMPORT MODULES
#>
Import-Module ActiveDirectory


<#
GET ADMIN CREDENTIALS
#>
function GetAdminCredentials() {
    if(Test-Path $CREDENTIALPATH) {
        $Password = Get-Content $CREDENTIALPATH | ConvertTo-SecureString 
    }
    else {
        $Password = Read-Host "Enter password from User $USERNAME" -AsSecureString | ConvertFrom-SecureString | Out-File $CREDENTIALPATH
    }
}
$Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $USERNAME,$Password

<#
EXCHANGE CONNECTION
#>
function MakeExchangeConnection() {
    Write-Host "...Opening Exchange PSSession...."
    GetAdminCredentials
    try {
        $ExchangeSession = New-PSSession -ConfigurationName Microsoft.EXCHANGE -ConnectionUri $CONNECTIONURI -Authentication Kerberos -Credential $Credentials
        Import-PSSession $ExchangeSession -DisableNameChecking
    }
    catch {
        "Error while opening Exchange PSSession!"
    }
    Write-Host "### Exchange PSSession succesfully opened ###`nYou can now use PS Exchange commands!"
}

<#
VCENTER CONNECTION
#>
function ConnectToVCenter(){
    Write-Host "Opening VCenter Connection...."
    GetAdminCredentials
    try {
        $VIConnection = Connect-VIServer "ACVCEVM001" -Credential $Credentials -WarningAction SilentlyContinue
    }
    Catch {
        "Error while opening VCenter connection"
    }
    Write-Host "VIConnection can now be used to check VM Servers"
}