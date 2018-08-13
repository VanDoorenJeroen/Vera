<#Variables#>
$PASSWORDPATH = "C:\ProgramData\credentials.txt"
$USER = $env:USERDOMAIN+"\"+$env:USERNAME
$SEARCHBASE = "OU=Servers,OU=1. Administratief Centrum,DC=gmmeise,DC=local"

<#
Store password in a txt file
If file not yet created, create one.
If file already exists, read password from that file.
#>
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
    else { 
        $date = Get-WmiObject win32_operatingsystem -ComputerName GMSQLVM002 -ErrorAction SilentlyContinue | Select-Object @{LABEL='LastBootUpTime';EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
        if($date) { $value = $date.Lastbootuptime }
    }
    $lijstVM.Add($key, $value) 
}

<#Lookup the servers in specified OU
Foreach OU, get a list of servers/computers
Foreach server, check the group it's in and define restart day
#>
$Computers = @{}
$ListServers = @()
$AppOU = Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase $SearchBase -SearchScope OneLevel
foreach ($ou in $AppOU){
    $ListServers += Get-ADComputer -Filter * -Properties Name, MemberOf -SearchBase $ou | Select-Object Name, @{Name="Restart";E={$_.MemberOf.Value}} | Sort-Object MemberOf
}

foreach ($server in $ListServers) {
    $key = $server.Name
    $restartValue = $server.Restart
    $value = ""
    if ($restartValue.Count -ge 2) {
        $restartValue | ForEach-Object `
        {
            if($_ -match 'GG_S_WSUS') {
                $value = $_
            }
        }
    }
    else {
        $value = $restartValue
    }
    if ($value -match 'GG_S_WSUS') {
        $value = $value.Substring($value.IndexOf("GG_S_WSUS"),16)
        switch ($value)
        {
                "GG_S_WSUS_Zat_VM" {$value = "Zaterdag Voormiddag"}
                "GG_S_WSUS_Zat_NM" {$value = "Zaterdag Namiddag"}
                "GG_S_WSUS_Zon_VM" {$value = "Zondag Voormiddag"}
                "GG_S_WSUS_Zon_NM" {$value = "Zondag Namiddag"}
                default {$value = ""}
        }
    }
    else {
        $value = ""
    }
    $Computers.Add($key,$value)
}

$Data = Get-VM -Server $connection | Get-View | Select-Object Name, @{Name="Status";E={$_.Summary.Runtime.PowerState}}, @{Name="LastBootTime";E={$LijstVM[$_.Name]}}, @{Name="Restart";E={$Computers[$_.Name]}}
[xml]$html = $Data | Sort-Object LastBootTime -Descending | ConvertTo-Html -Fragment

<#
Title with some CSS
#>

$ReportTitle = "Server status"
$head = @"
<Title>$ReportTitle</Title>
<style>
body { background-color:#FFFFFF;
font-family:Tahoma;
font-size:12pt; }
td, th { border:1px solid black;
border-collapse:collapse; }
th { color:white;
background-color:black; }
table, tr, td, th { padding: 2px; margin: 0px }
table { width:95%;margin-left:5px; margin-bottom:20px;}
.poweredOff {color: Red }
.poweredOn {color: Green }
.pending {color: #DF01D7 }
.paused {color: #FF8000 }
.other {color: Black }
</style>
<br>
<H1>$ReportTitle</H1>
"@

<#
Fill the table
#>

1..($html.table.tr.count-1) | ForEach-Object {
    #enumerate each TD
    $td = $html.table.tr[$_]
    #create a new class attribute
    $class = $html.CreateAttribute("class")
     
    #set the class value based on the item value
    Switch ($td.childnodes.item(1).'#text') {
        "poweredOn" { $class.value = "poweredOn"}
        "poweredOff" { $class.value = "poweredOff"}
        Default { $class.value = "other"}
    }
    #append the class
    $td.childnodes.item(1).attributes.append($class) | Out-Null
}   

[string]$body = ConvertTo-HTML -Head $head -Body $html.InnerXml -PostContent "<h6>Created $(Get-Date)</h6>"

$mailParams=@{
    To = "jeroen.vandooren@meise.be"
    From = "no-reply@meise.be"
    Subject = "Server status report"
    SmtpServer = "GMEXCVM001"
    Body = $body
    BodyAsHTML = $true
}

$Data

Send-MailMessage @mailParams
