########
#
##Purpose:      Link an existing Group Policy to Specified Organizational Units (using a filter)
########
########

########
#Changelog:
########
#V1.0: First draft
<#v2.0: Added parameters 23-10-24 
        Cleaned up comments       
#>
#region Parameters
function LinkOU() {

    [cmdletbinding()]
    param(
        [Parameter(Mandatory, ParameterSetName = "ClientLink")]
        [Parameter(Mandatory, ParameterSetName = "UserLink")]
        [string]$GPOName,

        [Parameter(Mandatory, ParameterSetName = "ClientLink")]
        [switch]$OUFilterClient,

        [Parameter(Mandatory, ParameterSetName = "UserLink")]
        [switch]$OUFilterUser
    )

    switch ($PSCmdlet.ParameterSetName) {
        "ClientLink" {
            $OUFilter = "OU=Clients*"
            Write-Output "OU Filter for Clients: $OUFilter"
        }
        "UserLink"{
            $OUFilter = "OU=Users,OU=Accounts*"
            Write-Output "OU Filter for Users: $OUFilter"
        }
        Default {
            Write-Output "Invalid Parameter Set"
            break
        }
    }

    #endregion

    #region PREPERATION
    $Domain = "" # domain
    $OUList = Get-ADOrganizationalUnit -SearchBase "" -filter * | Where-Object { $_.Distinguishedname -like $OUFilter } # add OU searchbase

    #endregion

    #region EXECUTION
    Try {
        ForEach ($OU in $OUList) {
            New-GPLink -Name $GPOName -Target $OU -Domain $Domain -LinkEnabled Yes -ErrorAction Continue
        }
        write-host "De GPO '$GPOName' is gekoppeld aan de opgegeven OU's" -ForegroundColor Green
    }
    Catch {
        Write-Warning "Error message: $($_.Exception.Message)"
    }

    #endregion
}

##### Examples #####

# Client links
# LinkOU -GPOName "Great GPO Client Title" -OUFilterClient

# User Links
# LinkOU -GPOName "Great GPO User Title" -OUFilterUser

