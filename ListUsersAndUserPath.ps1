Import-Module ActiveDirectory
$Users = Get-ADUser -Filter {(enabled -eq $true) -and (homedirectory -like "*username*")} -Properties homedrive, homedirectory
$Users | Sort-Object -Property homedirectory | FT homedrive, homedirectory, Name, GivenName 
foreach ($user in $users) 
{
    $sam = $user.SamAccountName
    $hd = "\\gmmeise.local\UserProfiles\Win10Users\" + $sam
    $hd
    #Set-ADUser -Identity $user -HomeDirectory $hd -HomeDrive U:
}