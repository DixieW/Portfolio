function Switch-Membership {
    [CmdletBinding()]
    param (
        # List of parameters; can be
        [Parameter(Mandatory)]
        [array]$Usernames,
        [Parameter()]
        [string]$Server = "" # domain controller,
        [Parameter()]
        [string]$Group1 = "" # adgroup 1,
        [Parameter()]
        [string]$Group2 = "" # adgroup 2
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
