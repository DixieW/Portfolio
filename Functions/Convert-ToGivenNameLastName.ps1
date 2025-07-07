function Convert-ToGivenNameLastName {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true)]
        [array]$samAccountNames
    )

    $listOfNames = @()

    foreach ($Name in $samAccountNames){
        $user = Get-aduser -Filter "SAMAccountName -like '$Name'" -Properties givenName, sn, samAccountName | Select-Object -Property givenName, sn
        $listOfNames += $user.givenName + " " + $user.sn + ";"
    }

    return $listOfNames
}

