$scopes = @("User.Read.All", "Group.ReadWrite.All", "Directory.Read.All", "DeviceManagementManagedDevices.Read.All", "DeviceManagementManagedDevices.ReadWrite.All", "DeviceManagementManagedDevices.PrivilegedOperations.All", "DeviceManagementRBAC.Read.All", "DeviceManagementRBAC.ReadWrite.All")

$subscription = "" # subscription ID

connect-mggraph -scopes $scopes -NoWelcome

connect-azAccount -Subscription $subscription

function Get-AllManagedDevices {
    [CmdletBinding()]
    param(
        [switch]$Lean
    )

    $baseUri = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices"

    # Add $select for lightweight retrieval if -Lean is specified
    if ($Lean) {
        $uri = $baseUri + "?`$select=id,deviceName,userPrincipalName,userDisplayName,userId"
    } else {
        $uri = $baseUri
    }

    $allDevices = @()

    do {
        $response = Invoke-MgGraphRequest -Method GET -Uri $uri
        $allDevices += $response.value
        $uri = $response.'@odata.nextLink'
    } while ($uri)

    # Display the total
    $allDevices.Count

    return $allDevices
}

function Get-ManagedDeviceByDeviceID {
    [cmdletbinding()]
    param (
        [parameter(Mandatory)]
        [string]$DeviceID
    )

    $SpecificDevice = Get-AllManagedDevices | Where-Object {$_.id -eq $DeviceID}
    return $SpecificDevice
}

function Get-ManagedDeviceByDeviceName {
    [cmdletbinding()]
    param (
        [parameter(Mandatory)]
        [string]$DeviceName
    )

    $SpecificDevice = Get-AllManagedDevices | Where-Object {$_.DeviceName -eq $DeviceName}
    return $SpecificDevice
}

function Get-EntraIDUserByUPN {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$UPN
    )

    $user = Get-MgUser -filter "userPrincipalName eq '$UPN'"
    return $user
}

function Get-EntraIDUserByUserID {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [string]$UserID
    )

    $user = Get-MgUser -userid $UserID
    return $user
}

function Set-PrimaryUserIntuneDevice {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$userID,
        [Parameter(Mandatory)]
        [string]$deviceID
    )

    $assignUri = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices('$deviceID')/users/`$ref"
    $body = @{"@odata.id" = "https://graph.microsoft.com/v1.0/users/$userID"} | ConvertTo-Json
    Write-Output "Setting userID '$userID' as PrimaryUser on DeviceID '$deviceID'"
    Invoke-MgGraphRequest -Method POST -Uri $assignUri -Body $body -ContentType "application/json"
    Write-Output "POST executed."
}

function Set-LastLogonUserAsPrimaryUser {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string] $DeviceID
    )

    $device = Get-FilteredManagedDeviceByDeviceID -DeviceID $DeviceID
    $UPN = $device.userPrincipalName
    $UserID = $device.userId

    $LastLoggedOnUser = Get-EntraIDUserPrincipalByUPN -UPN $UPN
    $PrimaryUser = Get-EntraIDUserPrincipalByUserID -UserID $UserID

    if($LastLoggedOnUser.UserPrincipalName -ne $PrimaryUser.UserPrincipalName){
        $assignUri = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices('$($device.id)')/users/`$ref"
        $body = @{"@odata.id" = "https://graph.microsoft.com/v1.0/users/$($PrimaryUser.Id)"} | ConvertTo-Json
        Write-Output "Setting user '$($PrimaryUser.UserPrincipalName)' as PrimaryUser on DeviceID '$($device.deviceName)'"
        Invoke-MgGraphRequest -Method POST -Uri $assignUri -Body $body -ContentType "application/json"
    }
}

function Set-ScopeTag {
    [CmdletBinding()]
    param (
        [parameter(Mandatory)]
        [string]$deviceID
    )

    $assignUri = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices('$deviceID')/`$ref"
    $body = @{"@odata.id" = "https://graph.microsoft.com/beta/deviceManagement/roleScopeTags/0/"} | ConvertTo-Json -Compress
    Invoke-MgGraphRequest -Method POST -Uri $assignUri -Body $body -ContentType "application/json"
}
$scopeTags = Invoke-MgGraphRequest GET "https://graph.microsoft.com/beta/deviceManagement/roleScopeTags/"
