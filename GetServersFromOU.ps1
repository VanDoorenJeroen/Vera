$SearchBase = "OU=Servers,OU=1. Administratief Centrum,DC=gmmeise,DC=local"
#Get-ADComputer -Filter * -SearchBase $SearchBase | FT Name
$Computers = @()
$AppOU = Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase $SearchBase -SearchScope OneLevel
foreach ($ou in $AppOU)
{
    #Get-ADComputer -Filter * -SearchBase $ou | Format-Table @{L=$ou.Name;E={$_.Name}}
    $Computers += Get-ADComputer -Filter * -Properties Name -SearchBase $ou | Select-Object Name | Sort-Object Name
}
$Computers
$Computers.Count
#$AppOU | ForEach-Object { Get-ADComputer -Filter * -SearchBase $_ } | Select-Object Name