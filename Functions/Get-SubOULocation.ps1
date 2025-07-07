function Get-SubOULocations {
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true, HelpMessage="Enter Parent OU Name.")]
        [string]$OUName,
        [parameter()]
        [string]$ParentOU = "OU=$OUName,OU=BeheerPartij5,OU=Productie,DC=intern,DC=ubnet,DC=nl",
        [parameter()]
        [string]$server = "Wes07pwadc01"
    )
    Get-ADOrganizationalUnit -Server $server -SearchBase $ParentOU -Filter * -SearchScope OneLevel | Where-Object {$_.Name -ne "Shares" -and $_.Name -ne "Langdurig afwezig" -and $_.Name -ne "Groups" -and $_.Name -ne "ClientImport" -and $_.Name -ne "Uitdienst"}
}
(Get-SubOULocations -OUName "RU269").Name
