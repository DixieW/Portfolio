function Disable-CSVAccount {
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true)]
        [array]$Accounts,
        [parameter(Mandatory=$false)]
        [string]$Description,
        [parameter(Mandatory=$true)]
        [string]$ChangeNumber
        )

    $currentDate = Get-Date -Format "dd-MM-yyyy"
    $dateToBeDelete = (get-date).AddDays(7).ToString("dd-MM-yyyy")
    $CSVDescriptionMSG = "disabled $currentDate ivm $ChangeNumber wordt verwijderd op $dateToBeDelete"

    try{
        foreach($CSVName in $Accounts){
            $SetCSVObject = Get-ADUser -Filter "Name -eq '$CSVName'" -ErrorAction Stop

            if($SetCSVObject.Enabled){
            Set-ADUser -Identity $SetCSVObject -Enabled $false -Description $CSVDescriptionMSG -ErrorAction Stop ; $CSVAccountProppertySet = $true
            if($CSVAccountProppertySet){
                Write-Host $SetCSVObject.Name "set to Disabled" -ForegroundColor Green
                $CSVAccountProppertySet = $false
                }
            }
        }
    }catch{
        Write-Warning "Error message: $($_.Exception.Message)"
    }
}

function Remove-CSVAccount {
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true)]
        [array]$Accounts
    )

    $SucceededtoDelete = [System.Collections.Generic.List[string]]::new()
    $FailedtoDelete = [System.Collections.Generic.List[string]]::new()


    try{
        foreach($CSVName in $Accounts){
            $SetCSVObject = Get-ADUser -Filter "Name -eq '$CSVName'"
            if(!$SetCSVObject.Enabled){
                Write-Warning "$SetCSVObject is being permanently deleted."
                [string]$DeletedObject = $SetCSVObject.SamAccountName
                $SetCSVObject | Remove-ADUser
                $SucceededtoDelete.Add($DeletedObject)
            }
            if(!$SetCSVObject){
                Write-Warning "Account is not disabled. No action was taken."
                $FailedtoDelete.Add($CSVName)
            }
        }
    }catch{
        Write-Warning "Error message: $($_.Exception.Message)"
    }

    if($SucceededtoDelete){
        $cleanerList = $SucceededtoDelete -split " "
    $cleanerList -join ";"
        Write-Host "`rVerwijderd uit Active Directory" -ForegroundColor Green
    }
    if($FailedtoDelete){
        Write-Host "$FailedtoDelete `nNot deleted"
    }

}


