$SearchBase = "OU=Servers,OU=1. Administratief Centrum,DC=gmmeise,DC=local"
$Computers = @{}
$ListServers = @()
$AppOU = Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase $SearchBase -SearchScope OneLevel
foreach ($ou in $AppOU)
{
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
   

$Computers.GetEnumerator() | Sort-Object -Property Value