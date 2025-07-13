<#
.SYNOPSIS
    Creating CSV account
.DESCRIPTION
    Use this script to add one CSV account with the proper attributes on the proper location.
.NOTES
    This script only works in powershell 5.1 - Reason is the password generation which uses powershell 5.1 attributes.
.EXAMPLE
    Run the script in the console like shown below:
    New-CSVAccount -$CSVAccountname "CSV_TEST_T" -$CSVO365=$true -$Requester "DoeJ" -$CSVAccountPurpose "To give an example"
    Remember to change the path of your console to the location where the script is placed in order to run it.
#>


. .\New-StrongPassword.ps1

function New-CSVAccount(){

    <#
    .SYNOPSIS
        Creating CSV account
    .DESCRIPTION
        Use this script to add one CSV account with the proper attributes on the proper location.
    .NOTES
        This script only works in powershell 5.1 - Reason is the password generation which uses powershell 5.1 attributes.
    .EXAMPLE
        Run the script in the console like shown below:
        New-CSVAccount -$CSVAccountname "CSV_TEST_T" -$CSVO365=$true -$Requester "TankH" -$CSVAccountPurpose "To give an example"
        Remember to change the path of your console to the location where the script is placed in order to run it.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,HelpMessage="Enter name of CSV Account, must start with CSV_ and end with either _P or _T:")]
        [ValidateLength(7,19)]
        [String]
        $CSVAccountName,
        [Parameter(Mandatory=$false,HelpMessage="Enter custom SMTP adress")]
        [String]
        $CSVAccountMail = $CSVAccountName + "@Domain.com",
        [Parameter(Mandatory=$false,HelpMessage="Does the CSV account need an O365 licence")]
        [switch]
        $CSVO365,
        [Parameter(Mandatory=$true,HelpMessage="Who made the change request and is responsible for the account? Enter a SamAccountName")]
        [String]
        $Requester,
        [Parameter(Mandatory=$true,HelpMessage="Enter change number starting with W.")]
        [String]
        $ChangeID,
        [Parameter(Mandatory=$false,HelpMessage="Enter employeeID requested.")]
        [String]
        $EmployeeID = "",
        [Parameter(Mandatory=$true,HelpMessage="Enter the reason this account is being created.")]
        [String]
        $Description,
        [Parameter(Mandatory=$false,HelpMessage="Enter the AccountExpirationDate when this account is being expired.")]
        [Datetime]
        $AccountExpirationDate,
        [Parameter(Mandatory=$false)]
        [String]
        $CSVAccountPurpose = $Description + " - " + $ChangeID,
        [Parameter(Mandatory=$false,HelpMessage="Enter custom RU location if needed.")]
        [String]
        $Location = "" # OU location,
        [Parameter(Mandatory=$false,HelpMessage="Enter custom RU location if needed.")]
        [String]
        $LocationO365 = "" # OU location with licence
    )


    <# Preperation #>
    Write-Debug $PSBoundParameters.GetEnumerator()
    Import-Module "ActiveDirectory"
    Write-Output "Preperation"
    # Check if account exists
    try {
        $ObjectName = Get-ADObject -Filter "SamAccountName -eq '$CSVAccountName'" -ErrorAction 'Stop' -Properties SamAccountName | Select-Object SamAccountName -ExpandProperty SamAccountName -ErrorAction Continue
        if ($null -eq $ObjectName) { Write-Host "$CSVAccountName not found in AD. Continuing process"}
    }
    catch {
        Write-Error $($_.Exception.Message)
        throw "$_"
    }

    if(-not $AccountExpirationDate){
        $CurrentTime = Get-Date
        [Datetime]$AccountExpirationDate = $CurrentTime.AddMonths(6).ToLocalTime()
    }
    # Create a strong 21 character password. This is within the minimal requirements for the creation of a CSV account. Password NEEDS to be reset after.

    Write-Output "creating strong password as secure string"

    <# Execution #>
    Write-Output "Execution"
    try{
        if (!($ObjectName)){
            if ($CSVO365) {
                #Account receives a licence for Office365
                try {
                    New-ADUser `
                    -Name $CSVAccountName `
                    -SamAccountName $CSVAccountName `
                    -EmailAddress $CSVAccountMail `
                    -Manager $Requester `
                    -Description $CSVAccountPurpose `
                    -Enabled $true `
                    -ChangePasswordAtLogon $false `
                    -PasswordNeverExpires $true `
                    -Path $LocationO365 `
                    -AccountPassword (CreatePass) `
                    -AccountExpirationDate $AccountExpirationDate `
                    -Server "" # Domain controller`
                    -OtherAttributes @{"extensionattribute2"="O365_YES"; "extensionattribute6"="NPA"; "employeeID"=$EmployeeID}
                    Write-Verbose "$CSVAccountName`r`n$CSVAccountMail`r`n$Requester`r`n$CSVAccountPurpose`r`n$LocationO365"
                    Write-Host "$CSVAccountName`r`nAangemaakt op locatie:`r`n$LocationO365`r`nMet sterk tijdelijk wachtwoord.`r`nDescription: $CSVAccountPurpose`r`nManager: $Requester`r`nAccountExpirationDate: $AccountExpirationDate" -ForegroundColor Green
                }
                catch {
                    Write-Warning "Error message: $($_.Exception.Message)"
                }
            }else {
                try {
                    New-ADUser `
                    -Name $CSVAccountName `
                    -SamAccountName $CSVAccountName `
                    -EmailAddress $CSVAccountMail `
                    -Manager $Requester `
                    -Description $CSVAccountPurpose `
                    -Enabled $true `
                    -ChangePasswordAtLogon $false `
                    -PasswordNeverExpires $true `
                    -Path $Location `
                    -AccountPassword (CreatePass) `
                    -AccountExpirationDate $AccountExpirationDate `
                    -Server "" # domain controller`
                    -OtherAttributes @{"extensionattribute2"="O365_NO"; "extensionattribute6"="NPA"; "employeeID"=$EmployeeID}
                    Write-Verbose "$CSVAccountName`r`n$CSVAccountMail`r`n$Requester`r`n$CSVAccountPurpose`r`n$Location"
                    Write-Host "$CSVAccountName`r`nAangemaakt op locatie:`r`n$Location`r`nMet sterk tijdelijk wachtwoord.`r`nDescription: $CSVAccountPurpose`r`nManager: $Requester`r`nAccountExpirationDate: $AccountExpirationDate" -ForegroundColor Green
                }
                catch {
                    Write-Warning "Error message: $($_.Exception.Message)"
                }
            }
        }
    }catch{
        Write-Error $($_.Exception.Message)
    }
    ### Change password after creation
}


