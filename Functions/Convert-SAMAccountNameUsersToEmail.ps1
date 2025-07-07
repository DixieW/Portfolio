function Convert-SAMAccountNameUsersToEmail {

    <#
    .DESCRIPTION
        Convert SAMaccountName by using Get-aduser function.
    .EXAMPLE
        convert-SAMAccountNameUsersToEmail -arrayUsers "DoeJ, MicrosoftS"
    #>

    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true,HelpMessage="Enter SAMaccountNames")]
        [Array]$arrayUsers
    )

    # Convert SAMaccountName to EmailAddress
    $EmailaddressesToAdd =@()
    foreach ($user in $arrayUsers){
        $EmailaddressesToAdd += (Get-ADUser -Filter "SamAccountName -like '$user'" -Properties Mail).Mail
    }
    return $EmailaddressesToAdd
}
