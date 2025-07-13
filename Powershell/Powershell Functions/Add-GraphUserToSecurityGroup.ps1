function Add-CloudDeviceMember {

    <#
    .SYNOPSIS
        Add users to clouddevice security group.
    .DESCRIPTION
        Use userprincipalname to add user to "<Name of Entra ID group>" and give access to FullTunnel through Active Directory "<Security Group>".
    .NOTES
        This function expects a list of email adresses.
        This function works with version powershell 7.
    .EXAMPLE
        Add-CloudDeviceMember -userList "John.Doe@domain.com"
    #>

    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$true, HelpMessage="Enter email adress of user.")]
        [Array]$userList,
        [parameter()]
        [string]$server = "<Domain Controler>"
    )
    # Connecting to Azure tenant.
    $connected = Connect-MgGraph -Scopes "User.Read.All", "Group.ReadWrite.All", "Directory.Read.All" | Out-Null

    $groupID = Get-MgGroup -Filter "displayName eq 'All Autopilot Users'"

    # add user to 'Entra ID group'.
    foreach($user in $userList){
        $userID = Get-MgUser -UserId $user
        $adUser = (Get-ADUser -Filter "mail -like '$user'" -Properties Mail).SamAccountName
        $existingMember = Get-MgGroupMember -GroupId $groupID.Id -Filter "ID eq '$($userID.Id)'"
        if(-not ($existingMember)){
            Write-Output "User with mailadress : '$($userID.Mail)' not found as a member of '$($groupID.DisplayName)'"
            New-MgGroupMember -GroupId $groupID.Id -DirectoryObjectId $userID.Id
            Write-Output "$adUser was added to $($groupID.DisplayName)"
        }else{
            Write-Output "User with Userprincipalname : '$($userID.UserPrincipalName)' is already a member of the group '$($groupID.DisplayName)'"
        }
    }
}

### Example ### Add-CloudDeviceMember -userList "John.Doe@Domain.com"
function convert-SAMAccountNameUsersToEmail {

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
