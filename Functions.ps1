Function SendMail{
    # Data of body
    param(
        [Parameter(Mandatory = $true)]
        [System.Object[]]
        $Data
    )

    Send-MailMessage -To "Jeroen Van Dooren<jeroen.vandooren@meise.be>" -From "Server information<Serverinfo@meise.be>" -Subject "VM overview" -SmtpServer "GMEXCVM001" -Body $Data
}