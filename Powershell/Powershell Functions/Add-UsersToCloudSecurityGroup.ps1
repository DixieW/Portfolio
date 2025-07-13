function Add-UsersToCloudSecurityGroup {

    <#
    .SYNOPSIS
        Add users to clouddevice security group.
    .DESCRIPTION
        Use userprincipalname to add user to "<Entra ID group name>".
    .NOTES
        This function expects a list of email adresses.
        This function works with version powershell 7.
    .EXAMPLE
        Add-UsersToCloudSecurityGroup -UserList "John.Doe@Domain.com" -SecurityGroup "NameOfYourSecurityGroupDisplayname"
    #>

    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$true, HelpMessage="Enter email adress of user.")]
        [Array]$UserList,
        [parameter(Mandatory=$true, HelpMessage="Enter Security Group DisplayName.")]
        [string]$SecurityGroup,
        [parameter()]
        [string]$server = "" # domain controller
    )
    # Connecting to Tenant
    Connect-MgGraph -Scopes "User.Read.All", "Group.ReadWrite.All", "Directory.Read.All"

    $groupID = Get-MgGroup -Filter "displayName eq '$SecurityGroup'"

    foreach($user in $userList){
        $userID = Get-MgUser -UserId $user
        $existingMember = Get-MgGroupMember -GroupId $groupID.Id -Filter "ID eq '$($userID.Id)'" -erroraction SilentlyContinue
        if(-not ($existingMember)){
            New-MgGroupMember -GroupId $groupID.Id -DirectoryObjectId $userID.Id
            Write-Output "User with Userprincipalname : '$($userID.UserPrincipalName)' Added to '$SecurityGroup'"
        }else{
            Write-Output "User with Userprincipalname : '$($userID.UserPrincipalName)' is already a member of the group '$SecurityGroup'"
        }
    }
}
