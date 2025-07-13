
function Get-ADuserSamAccountName() {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true,HelpMessage="Enter Givenname/Surname/emailadress")]
        [array]$Names,
        [parameter(Mandatory=$false,HelpMessage="Show admin accounts skipped")]
        [switch]$displayBEHAccount
        )

    Import-Module "ActiveDirectory"

    # Main return array
    [array]$NamesArray = @()

    # Optional return array
    [array]$BEHNames = @()


    foreach ($name in $Names){
        # Check if the $name == an email adres
        if($name -match '^[\w\.\-]+@[\w\.\-]+\.\w+$'){
            $userObject  = Get-ADUser -Properties samAccountName, mail -Filter "mail -like '$name'"  | Select-Object -Property SamAccountName -ExpandProperty SamAccountName
        }else{
            $nameParts = $name -split '\s+'

            switch ($nameParts.Count) {
                1 {
                    # One part provided, search by either first or last name
                    $filter = "GivenName -like '*$($nameParts[0])*' -or Surname -like '*$($nameParts[0])*'"
                }
                2 {
                    # Two parts, assume first and last name
                    $filter = "GivenName -like '*$($nameParts[0])*' -and Surname -like '*$($nameParts[1])*'"
                }
                3 {
                    # Three parts, assume first name, infix, and last name
                    $filter = "GivenName -like '*$($nameParts[0])*' -and Surname -like '*$($nameParts[2])*'"
                }
                4 {
                    # Four parts, assume first name, infix, and last name
                    $filter = "GivenName -like '*$($nameParts[0])*' -and Surname -like '*$($nameParts[3])*'"
                }
                default {
                    Write-Host "Name '$name' has an unexpected format with more than four parts."
                    continue
                }
            }
            try {
                # Perform the AD query using the constructed filter
                $userObject = Get-ADUser -Filter $filter -Properties SamAccountName | Select-Object -ExpandProperty SamAccountName
            }
            catch {
                Write-Host "No user found for name: $name"
                continue
            }
        }

        if($userObject.count -eq 2 -or $userObject.count -gt 2){
            foreach ($Item in $userObject){
                if ($Item -and $Item.EndsWith('Beh')) {
                    if ($Item.Length -ge 3) {
                    # Remove "Beh" from the end of SamAccountName
                    $BEHNames += $Item + ";"
                    $Item = $Item.Substring(0, $Item.Length - 3)
                    $NamesArray += $Item + ";"
                    }
                }
            }
            # If SamAccountName ends with "Beh", remove it but only if it's long enough
        }
        # Add the userObject to the list, ensuring it's not $null
        elseif ($userObject) {
            $NamesArray += $userObject + ";"
        }
    }

    # If parameter is true display skipped BEH accounts
    if($displayBEHAccount){
        $NamesArray += "BEH accounts that were skipped: "
        $NamesArray += $BEHNames
    }
    # Return only unique SamAccountNames
    return $NamesArray | Select-Object -Unique
}

