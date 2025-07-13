<#
.NOTES
    Creation Date   : 10-1-2025
    Author          : Dixie Wanner
    Edit Date       : 10-1-2025
    Script version  : 1.0.1
#>

function Clear-SCCMCache{
<#
.SYNOPSIS
    Clear SCCM caching
.DESCRIPTION
    Function that collects all SCCM cache files and removes them one by one.
.EXAMPLE
    foreach ($i in $computers){
        Clear-SCCMCache
    }
#>
    # Initialize the CCM resource manager com object
    [__comobject]$CCMComObject = New-Object -ComObject 'UIResource.UIResourceMgr'

    try {
        # Get the CacheElementIDs to delete
        $CacheInfo = $CCMComObject.GetCacheInfo().GetCacheElements()
        # Remove cache items
        ForEach ($CacheItem in $CacheInfo) {
            $null = $CCMComObject.GetCacheInfo().DeleteCacheElement([string]$($CacheItem.CacheElementID))
        }
        Write-Output "Clearing SCCM cache Completed."
    }
    catch [System.ServiceProcess.ServiceControllerException]{
        Write-Error "Unable to clear SCCM Cache : $_"
    }
    catch{
        Write-Error "An unexpected error occurred : $_"
    }

}

function Clear-SCCMCompletionState {
<#
.SYNOPSIS
    Clear SCCM pending completion cache
.DESCRIPTION
    Use Get-WMIObject to gather the latest stats of the SCCM completionstate.
    If objects are found with status 'Completed' and CompletionState 'Failure'.
    Remove the object with .delete().
.PARAMETER Force
    When -force is used during execusion restarts the CcmExec service.
.EXAMPLE
    Clear-SCCM-CompletionState -force
#>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [bool]$force
    )

    # Retrieve WMI objects where State is 'Completed' and CompletionState is 'Failure'
    $completionState = Get-WmiObject `
        -Namespace "root\ccm\SoftMgmtAgent"`
        -Filter "State = 'Completed' And CompletionState = 'Failure'"`
        -force


    try{

        if ($completionState){
            Write-Output "Object found with CompletionState 'failure'"
            foreach ($state in $completionState) {
                $state.Delete()
                Write-Output "Object removed."
            }
        }

        if($force){
            $service = Get-Service -Name "CcmExec" -ErrorAction SilentlyContinue
            if($service) {
                Restart-Service CcmExec -Force
                Write-Output "Service 'CcmExec' restarted."
            }else{
                Write-Output "Service 'CcmExec' not found."
            }

        }

    }catch [System.Management.ManagementException]{
        Write-Error "Unable to remove object : $_"
    }catch [System.ServiceProcess.ServiceControllerException]{
        Write-Error "Unable to restart the Service : $_"
    }catch {
        Write-Error "An unexpected error occurred : $_"
    }

}

function Install-SCCMClient {
<#
.SYNOPSIS
    Install SCCM client.
.DESCRIPTION
    Install or reinstall the SCCM client on a users device.
    This function connects to the SCCM server and executes the ccmsetup.exe to install a new client.
.PARAMETER SiteCode
    SiteCode has a default value "UMS". This code is needed when performing SCCM operations. You can manually change this if needed.
.PARAMETER ManagementPoint
    ManagementPoint has a default value of "<Name of SCCM server>". This is our default SCCM server. You can manually change this if needed.
.PARAMETER Force
    This Parameter force removes left over registry values and configs of the old installation
.EXAMPLE
    Install-SCCMClient -force
    1. This clears out old installations.
    Optional (force) this force removes older config data.
    2. Installs a new client.
#>
    param (
        [string]$SiteCode = "UMS",                  # The SCCM site code (e.g., 'ABC')
        [string]$ManagementPoint = "<Name of SCCM server>",    # The FQDN or IP of the Management Point (e.g., 'sccmserver.domain.com')
        [bool]$Force
    )

    try {
    # Step 1: Uninstall the SCCM client if it's installed
        $ccmSetupPath = "C:\Windows\ccmsetup\ccmsetup.exe"
        if (Test-Path $ccmSetupPath) {
            Write-Host "Uninstalling SCCM client..."
            Start-Process -FilePath $ccmSetupPath -ArgumentList "/uninstall" -Wait
            Write-Host "SCCM client uninstalled."
        } else {
            Write-Host "SCCM client is not installed, proceeding with installation..."
        }

    }
    catch [System.Management.ManagementException]{
        Write-Error "Ran into an error while uninstalling SCCM client : $_"
    }
    catch{
        Write-Error "Unexpected Error : $_"
    }

    # Optional: Force remove old SCCM
    if ($Force) {
        try {
            Write-Host "Forcing removal of old SCCM client configurations..."
            # Remove SCCM client folders and registry entries
            Remove-Item -Path "C:\Windows\CCM" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "C:\Windows\CCMSetup" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "C:\ProgramData\Microsoft\Configuration Manager" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "C:\Program Files\Microsoft Configuration Manager" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "C:\Windows\ccmsetup" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\SMS\*" -Recurse -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\SMS" -Force -ErrorAction SilentlyContinue
            Write-Host "Old SCCM client configurations removed."
        }
        catch [System.Management.ManagementException]{
            Write-Error "Unable to remove item : $_"
        }
        catch{
            Write-Error "Unexpected Error : $_"
        }
    }

    # Step 2: Reinstall the SCCM client with the specified Site Code and Management Point
    Write-Host "Installing SCCM client..."
    $arguments = "/mp:$ManagementPoint SMSSITECODE=$SiteCode"
    Start-Process -FilePath $ccmSetupPath -ArgumentList $arguments -Wait
    Write-Host "SCCM client installed and configured with Site Code $SiteCode and Management Point $ManagementPoint."

}
