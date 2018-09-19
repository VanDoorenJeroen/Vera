
#(Get-ADUser -Filter 'Enabled -eq $true -and Homedirectory -like "*"').Count
$users = Get-ADUSER -Filter 'Enabled -eq $true' -Properties *
$Count = 0
foreach ($user in $users)
{
    if($user.GivenName -like "*" -and $user.SN -like "*")
    {
        try {
            $shortname = $user.GivenName.Substring(0,1) + $user.SN.Replace(" ","")
            $shortname
            if($user.HomeDirectory -like "*$shortname*")
            {
                $count++
            }
        }
        catch {
            "Error"
        }

    }
}
$Count