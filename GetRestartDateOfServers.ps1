$SearchBase = "OU=Servers,OU=1. Administratief Centrum,DC=gmmeise,DC=local"
$Computers = @{}
$AppOU = Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase $SearchBase -SearchScope OneLevel
foreach ($ou in $AppOU)
{
    $ListServers = Get-ADComputer -Filter * -Properties Name, MemberOf -SearchBase $ou | Select-Object Name, @{Name="Restart";E={$_.MemberOf.Value}} | Sort-Object MemberOf
    foreach ($Server in $ListServers) 
    {
        $key = $Server.Name
        $value = $Server.Restart
        $Computers.Add($key, $value)
    }   
}

foreach ($Computer in @($Computers.keys)) 
{
    $member = $Computers[$Computer]
    if ($member -match 'GG_S_WSUS')
    {
        $value = $member.Substring($member.IndexOf("GG_S_WSUS"),16)
        switch ($value)
        {
            "GG_S_WSUS_Zat_VM" {$Computers[$Computer] = "Zaterdag Voormiddag"}
            "GG_S_WSUS_Zat_NM" {$Computers[$Computer] = "Zaterdag Namiddag"}
            "GG_S_WSUS_Zon_VM" {$Computers[$Computer] = "Zondag Voormiddag"}
            "GG_S_WSUS_Zon_NM" {$Computers[$Computer] = "Zondag Namiddag"}
            default {$Computers[$Computer] = ""}
        }
    }
    else {$Computers[$Computer] = "" }
}   

$Computers | Sort-Object -Descending