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
GenerateOutput "Import AD"
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
    $Credentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $USERNAME,$Password
    return $Credentials
}

<#
EXCHANGE CONNECTION
#>
function MakeExchangeConnection() {
    GenerateOutput "Opening Exchange PSSession"
    $Credentials = GetAdminCredentials
    try {
        $ExchangeSession = New-PSSession -ConfigurationName Microsoft.EXCHANGE -ConnectionUri $CONNECTIONURI -Authentication Kerberos -Credential $Credentials
        $ExchangeImportedSession = Import-PSSession $ExchangeSession -DisableNameChecking
        GenerateOutput "Exchange PSSession succesfully opened! You can now use PS Exchange commands!"
    }
    catch {
        "Error while opening Exchange PSSession!"
    }
    
}

<#
Create output with #
#>
function GenerateOutput([string]$Value) {
    $Row = "#" * ($Value.Length + 8)
    $Tekst += "### "+ $Value + " ###"
    Write-Host $Row"`n"$Tekst"`n"$Row"`n"
}

<#
VCENTER CONNECTION
#>
function ConnectToVCenter(){
    Write-Host "Opening VCenter Connection...."
    $Credentials = GetAdminCredentials
    try {
        $VIConnection = Connect-VIServer "ACVCEVM001" -Credential $Credentials -WarningAction SilentlyContinue
    }
    Catch {
        "Error while opening VCenter connection"
    }
    Write-Host "VIConnection can now be used to check VM Servers"
}