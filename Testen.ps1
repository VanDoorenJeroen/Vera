$SearchBase = "OU=Servers,OU=1. Administratief Centrum,DC=gmmeise,DC=local"
#Get-ADComputer -Filter * -SearchBase $SearchBase | FT Name
$Computers = @()
$AppOU = Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase $SearchBase -SearchScope OneLevel
foreach ($ou in $AppOU)
{
    #Get-ADComputer -Filter * -SearchBase $ou | Format-Table @{L=$ou.Name;E={$_.Name}}
    $Computers += Get-ADComputer -Filter * -Properties Name, MemberOf -SearchBase $ou | Select-Object Name, @{Name="Restart";E={$_.MemberOf.Value}} | Sort-Object MemberOf
}
#$Computers @{Name="Status";E={$_.Summary.Runtime.PowerState}}
#$Computers.Count
#$AppOU | ForEach-Object { Get-ADComputer -Filter * -SearchBase $_ } | Select-Object Name

$Computers | ForEach-Object {
    $cu = $_
    $member = $_.Restart
    if ($member -match 'GG_S_WSUS')
    {
        $value = $member.Substring($member.IndexOf("GG_S_WSUS"),16)
        switch ($value)
        {
            "GG_S_WSUS_Zat_VM" {$cu.Restart = "Zaterdag Voormiddag"}
            "GG_S_WSUS_Zat_NM" {$cu.Restart = "Zaterdag Namiddag"}
            "GG_S_WSUS_Zon_VM" {$cu.Restart = "Zondag Voormiddag"}
            "GG_S_WSUS_Zon_NM" {$cu.Restart = "Zondag Namiddag"}
            default {$cu.Restart = ""}
        }
    }
    else { $cu.Restart = "" }
}   
$Computers | Sort-Object -Property Restart