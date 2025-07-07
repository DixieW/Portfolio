
function New-LocationString {

    <#
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .EXAMPLE
        Test-MyTestFunction -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>



    [cmdletbinding(DefaultParameterSetName)]
    param (

        [Hashtable]$COLocations = @{
            CO001 = "OU=CO001,OU=BeheerPartij5,OU=Productie,DC=intern,DC=ubnet,DC=nl"
            CO002 = "OU=CO002,OU=BeheerPartij5,OU=Productie,DC=intern,DC=ubnet,DC=nl"
            CO003 = "OU=CO003,OU=BeheerPartij5,OU=Productie,DC=intern,DC=ubnet,DC=nl"
            CO004 = "OU=CO004,OU=BeheerPartij5,OU=Productie,DC=intern,DC=ubnet,DC=nl"
            CO005 = "OU=CO005,OU=BeheerPartij5,OU=Productie,DC=intern,DC=ubnet,DC=nl"
        },

        [hashtable]$RULocations = @{
            RU269 = "OU=RU269,OU=BeheerPartij5,OU=Productie,DC=intern,DC=ubnet,DC=nl"
            RU285 = "OU=RU285,OU=BeheerPartij5,OU=Productie,DC=intern,DC=ubnet,DC=nl"
            RU460 = "OU=RU460,OU=BeheerPartij5,OU=Productie,DC=intern,DC=ubnet,DC=nl"
            RU485 = "OU=RU485,OU=BeheerPartij5,OU=Productie,DC=intern,DC=ubnet,DC=nl"
            RU490 = "OU=RU490,OU=BeheerPartij5,OU=Productie,DC=intern,DC=ubnet,DC=nl"
            RU663 = "OU=RU663,OU=BeheerPartij5,OU=Productie,DC=intern,DC=ubnet,DC=nl"
            RU710 = "OU=RU710,OU=BeheerPartij5,OU=Productie,DC=intern,DC=ubnet,DC=nl"
            RU726 = "OU=RU726,OU=BeheerPartij5,OU=Productie,DC=intern,DC=ubnet,DC=nl"
        },

        [hashtable]$SubLocationName = @{
            001 = "OU=001,"
            002 = "OU=002,"
            003 = "OU=003,"
            004 = "OU=004,"
            005 = "OU=005,"
            006 = "OU=006,"
            007 = "OU=007,"
            008 = "OU=008,"
            009 = "OU=009,"
            010 = "OU=010,"
            011 = "OU=011,"
            012 = "OU=012,"
            013 = "OU=013,"
            014 = "OU=014,"
            015 = "OU=015,"
            016 = "OU=016,"
            017 = "OU=017,"
            018 = "OU=018,"
            019 = "OU=019,"
            020 = "OU=020,"
            021 = "OU=021,"
            022 = "OU=022,"
            023 = "OU=023,"
            024 = "OU=024,"
            025 = "OU=025,"
            026 = "OU=026,"
            027 = "OU=027,"
            028 = "OU=028,"
            029 = "OU=029,"
            030 = "OU=030,"
        },

        [parameter(ParameterSetName = "Clients")]
        [switch]$ClientSelection,

        [parameter(ParameterSetName = "Accounts")]
        [string]$DefaultSelection = "OU=Users,OU=Accounts,",

        [parameter(Mandatory=$true)]
        [ValidateSet("CO001","CO002","CO003","CO004","CO005","RU285","RU460","RU485","RU490","RU663","RU710","RU726")]
        [string]$PrimaryLocation,

        [parameter(Mandatory=$true)]
        [ValidateSet("001","002","003","004","005","006","007","008","009","010","011","012","013","014","015","016","017","018","019","020","021","022","023","024","025","026","027","028","029","030")]
        [string]$SubLocation
        )

        if($ClientSelection){
            $DefaultSelection = "OU=Laptop,OU=Clients,"
        }

        $LocationResult = switch ($PrimaryLocation) {
            "CO001" { $COlocations.CO001 }
            "CO002" { $COlocations.CO002 }
            "CO003" { $COlocations.CO003 }
            "CO004" { $COlocations.CO004 }
            "CO005" { $COlocations.CO005 }
            "RU269" { $RULocations.RU269 }
            "RU285" { $RULocations.RU285 }
            "RU460" { $RULocations.RU460 }
            "RU485" { $RULocations.RU485 }
            "RU490" { $RULocations.RU490 }
            "RU663" { $RULocations.RU663 }
            "RU710" { $RULocations.RU710 }
            "RU726" { $RULocations.RU726 }
        }

        $SubLocationResult = switch ($SubLocation) {
            "001" { $SubLocationName.001 }
            "002" { $SubLocationName.002 }
            "003" { $SubLocationName.003 }
            "004" { $SubLocationName.004 }
            "005" { $SubLocationName.005 }
            "006" { $SubLocationName.006 }
            "007" { $SubLocationName.007 }
            "008" { $SubLocationName.008 }
            "009" { $SubLocationName.009 }
            "010" { $SubLocationName.010 }
            "011" { $SubLocationName.011 }
            "012" { $SubLocationName.012 }
            "013" { $SubLocationName.013 }
            "014" { $SubLocationName.014 }
            "015" { $SubLocationName.015 }
            "016" { $SubLocationName.016 }
            "017" { $SubLocationName.017 }
            "018" { $SubLocationName.018 }
            "019" { $SubLocationName.019 }
            "020" { $SubLocationName.020 }
            "021" { $SubLocationName.021 }
            "022" { $SubLocationName.022 }
            "023" { $SubLocationName.023 }
            "024" { $SubLocationName.024 }
            "025" { $SubLocationName.025 }
            "026" { $SubLocationName.026 }
            "027" { $SubLocationName.027 }
            "028" { $SubLocationName.028 }
            "029" { $SubLocationName.029 }
            "030" { $SubLocationName.030 }
        }

        $finalResult = $DefaultSelection + $SubLocationResult + $LocationResult
        return $finalResult
}

function Move-ObjectsToNewLocation {

    <#
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .LINK
        Specify a URI to a help page, this will show when Get-Help -Online is used.
    .EXAMPLE
        Test-MyTestFunction -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>



    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true)]
        [ValidateSet("CO001","CO002","CO003","CO004","CO005","RU285","RU460","RU485","RU490","RU663","RU710","RU726")]
        [string] $PrimaryLocation,
        [parameter(Mandatory=$true)]
        [ValidateSet("001","002","003","004","005","006","007","008","009","010","011","012","013","014","015","016","017","018","019","020","021","022","023","024","025","026","027","028","029","030")]
        [string] $SubLocation,
        [parameter(Mandatory=$true)]
        [ValidateSet("CO001","CO002","CO003","CO004","CO005","RU285","RU460","RU485","RU490","RU663","RU710","RU726")]
        [string] $PrimaryDestinationLocation,
        [parameter(Mandatory=$true)]
        [ValidateSet("001","002","003","004","005","006","007","008","009","010","011","012","013","014","015","016","017","018","019","020","021","022","023","024","025","026","027","028","029","030")]
        [string] $SubDestinationLocation,
        [parameter()]
        [PSObject] $FromLocation = (New-LocationString -PrimaryLocation $PrimaryLocation -SubLocation $SubLocation),
        [Parameter()]
        [PSObject] $ToLocation = (New-LocationString -PrimaryLocation $PrimaryDestinationLocation -SubLocation $SubDestinationLocation),
        [parameter()]
        [string] $Server = "Wes07pwadc01",
        [parameter()]
        [switch] $laptop
        )
        #  Choose location: "CO001","CO002","CO003","CO004","CO005","RU285","RU460","RU485","RU490","RU663","RU710","RU726"
        #  Choose sublocation: "001","002","003","004","005","006","007","008","009","010","011","012","013","014","015","016","017","018","019","020","021","022","023","024","025","026","027","028","029","030"

    if($laptop){
        $FromLocation = (New-LocationString -PrimaryLocation $PrimaryLocation -SubLocation $SubLocation -ClientSelection)
        $ToLocation = (New-LocationString -PrimaryLocation $PrimaryDestinationLocation -SubLocation $SubDestinationLocation -ClientSelection)
    }

    if($FromLocation -match "OU=Clients"){
        $filter = "Name -notlike 'Users'"
    }else{
        $filter = "Name -notlike 'Laptop'"
    }

    $ADObjects = Get-ADObject -Filter $filter -SearchBase "$FromLocation"

    foreach($Object in $ADObjects | Where-Object ObjectClass -eq computer){

        Move-ADObject -Identity $Object -TargetPath $ToLocation -Server $Server -WhatIf
        Write-Output "Performing `"move`" operation on target : $($object.Name)`n Moving from location : $FromLocation`n To location: $ToLocation"
    }

}

### EXAMPLE ### Move-ObjectsToNewLocation -PrimaryLocation CO001 -SubLocation 001 -PrimaryDestinationLocation CO002 -SubDestinationLocation 002
Move-ObjectsToNewLocation -PrimaryLocation RU285 -SubLocation 011 -PrimaryDestinationLocation RU285 -SubDestinationLocation 001 -laptop
