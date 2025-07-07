function Switch-Membership {
    [CmdletBinding()]
    param (
        # List of parameters; can be
        [Parameter(Mandatory)]
        [array]$Usernames,
        [Parameter()]
        [string]$Server = "Wes07pwadc01",
        [Parameter()]
        [string]$Group1 = "GL_Intune_Mobile_Users",
        [Parameter()]
        [string]$Group2 = "GL_MAM-WE_Users"
    )
   $Succes = $false
   foreach($User in $Usernames){
        $MembersGroup1 = (Get-ADGroupMember -Identity $Group1 -Server $Server ).SamAccountName
        if($MembersGroup1 -contains $User){
            Remove-ADGroupMember $Group1 -Members $User -Confirm:$false -ErrorAction Stop ;$Succes = $true
        }
        if($Succes){
            Add-ADGroupMember $Group2 -Members $User
            Write-Output "removed $User from adgroup: $Group1`nAdded $User to adgroup: $Group2"
        }
   }
}

$ListOfUsers = @(

)

Switch-Membership -Usernames $ListOfUsers
