<#
.NOTES
    Creation Date   : 20-1-2025
    Author          : Dixie Wanner
    Edit Date       : 06-02-2025
    Script version  : 1.0.5
#>

class SCCMClient {

    # Properties of object
    [string]$SiteCode = "" # sitecode;
    [string]$ManagementPoint = "" # SCCM servername;
    [string]$Arguments = "/mp:$($this.ManagementPoint) SMSSITECODE=$($this.SiteCode)"


    # empty constructor
    SCCMClient(){}

    # Constructor for other sitecode & managementpoint
    SCCMClient([string]$SiteCode, [string]$ManagementPoint){
        $this.SiteCode = $SiteCode
        $this.ManagementPoint = $ManagementPoint
    }

    ### Methodes ###

    [string] CheckSCCMInstallation(){
        $ccmDefaultPath = "C:\Windows\ccmsetup\ccmsetup.exe"
        if (Test-Path $ccmDefaultPath) {
            return $ccmDefaultPath
        }
        return "No Client Found."
    }

    [string] RepairSCCMClient(){
        if ($this.CheckSCCMInstallation -ne "No Client Found."){
            Stop-Process -Name "SCClient" -Confirm:$false -Force
            Start-Process -filePath $this.CheckSCCMInstallation() -ArgumentList $this.Arguments -Wait
            return "SCCM client repaired."
        }
        return "Could not start repair."
    }

    [void] ClearSCCMClientCache(){
        if ($this.CheckSCCMInstallation -ne "No Client Found."){
            [__comobject]$CCMComObject = New-Object -ComObject 'UIResource.UIResourceMgr'
            $CacheInfo = $CCMComObject.GetCacheInfo().GetCacheElements()
            try {
                ForEach ($CacheItem in $CacheInfo) {
                    $null = $CCMComObject.GetCacheInfo().DeleteCacheElement([string]$($CacheItem.CacheElementID))
                }
            }
            catch {
                Write-Error "Unable to clear SCCM Cache : $_"
            }
            Write-Output "Clearing SCCM cache Completed."
        }
    }

    [void] ClientConfigManagerActions(){
        $controlPanelAppletManager = New-Object -ComObject CPApplet.CPAppletMgr
        $clientActions = $controlPanelAppletManager.GetClientActions()
        $clientActions | ForEach-Object {
            $_.Name
            $_.PerformAction()
        }
    }

    <#

    Value:	 State:
        0	     ciNotPresent
        1	     ciPresent
        2	     ciPresenceUnknown (also used for not applicable)
        3	     ciEvaluationError
        4	     ciNotEvaluated
        5	     ciNotUpdated
        6	     ciNotConfigured

    #>

    # Get pending updates

    [Microsoft.Management.Infrastructure.CimInstance[]] GetSCCMClientfailedUpdates(){
        $failedUpdates = Get-CimInstance -Namespace "root\ccm\ClientSDK" -Query "SELECT * FROM CCM_SoftwareUpdate WHERE EvaluationState = 3 OR EvaluationState = 5"
        if($null -ne $failedUpdates){
            return $failedUpdates
        }
        return $null
    }

    # Clear pending updates
    [void] PurgeSCCMClientWindowsUpdate(){
        if($this.GetSCCMClientfailedUpdates()){

            $arch = Get-CimInstance -Class Win32_Processor -ComputerName LocalHost | Select-Object AddressWidth
            try{
                Write-Output "1. Stopping Windows Update Services..."

                Stop-Service -Name BITS
                Stop-Service -Name wuauserv
                Stop-Service -Name appidsvc
                Stop-Service -Name cryptsvc

                Write-Output "2. Remove QMGR Data file..."

                Remove-Item "$env:allusersprofile\Application Data\Microsoft\Network\Downloader\qmgr*.dat" -ErrorAction SilentlyContinue

                Write-Output "3. Renaming the Software Distribution and CatRoot Folder..."

                Rename-Item $env:systemroot\SoftwareDistribution SoftwareDistribution.bak -ErrorAction SilentlyContinue
                Rename-Item $env:systemroot\System32\Catroot2 catroot2.bak -ErrorAction SilentlyContinue

                Write-Output "4. Removing old Windows Update log..."

                Remove-Item $env:systemroot\WindowsUpdate.log -ErrorAction SilentlyContinue

                Write-Output "5. Resetting the Windows Update Services to defualt settings..."

                "sc.exe sdset bits D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"
                "sc.exe sdset wuauserv D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)"

                Set-Location $env:systemroot\system32

                Write-Output "6. Registering some DLLs..."

                regsvr32.exe /s atl.dll
                regsvr32.exe /s urlmon.dll
                regsvr32.exe /s mshtml.dll
                regsvr32.exe /s shdocvw.dll
                regsvr32.exe /s browseui.dll
                regsvr32.exe /s jscript.dll
                regsvr32.exe /s vbscript.dll
                regsvr32.exe /s scrrun.dll
                regsvr32.exe /s msxml.dll
                regsvr32.exe /s msxml3.dll
                regsvr32.exe /s msxml6.dll
                regsvr32.exe /s actxprxy.dll
                regsvr32.exe /s softpub.dll
                regsvr32.exe /s wintrust.dll
                regsvr32.exe /s dssenh.dll
                regsvr32.exe /s rsaenh.dll
                regsvr32.exe /s gpkcsp.dll
                regsvr32.exe /s sccbase.dll
                regsvr32.exe /s slbcsp.dll
                regsvr32.exe /s cryptdlg.dll
                regsvr32.exe /s oleaut32.dll
                regsvr32.exe /s ole32.dll
                regsvr32.exe /s shell32.dll
                regsvr32.exe /s initpki.dll
                regsvr32.exe /s wuapi.dll
                regsvr32.exe /s wuaueng.dll
                regsvr32.exe /s wuaueng1.dll
                regsvr32.exe /s wucltui.dll
                regsvr32.exe /s wups.dll
                regsvr32.exe /s wups2.dll
                regsvr32.exe /s wuweb.dll
                regsvr32.exe /s qmgr.dll
                regsvr32.exe /s qmgrprxy.dll
                regsvr32.exe /s wucltux.dll
                regsvr32.exe /s muweb.dll
                regsvr32.exe /s wuwebv.dll

                Write-Output "7) Removing WSUS client settings..."

                Remove-ItemProperty -Path "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" -Name "AccountDomainSid" -Force
                Remove-ItemProperty -Path "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" -Name "PingID" -Force
                Remove-ItemProperty -Path "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate" -Name "SusClientId" -Force

                Write-Output "8) Resetting the WinSock..."

                netsh winsock reset
                netsh winhttp reset proxy

                Write-Output "9) Delete all BITS jobs..."

                Get-BitsTransfer | Remove-BitsTransfer

                Write-Output "10) Attempting to install the Windows Update Agent..."

                if($arch -eq 64){
                    wusa Windows8-RT-KB2937636-x64 /quiet
                }
                else{
                    wusa Windows8-RT-KB2937636-x86 /quiet
                }

                Write-Output "11) Starting Windows Update Services..."

                Start-Service -Name BITS
                Start-Service -Name wuauserv
                Start-Service -Name appidsvc
                Start-Service -Name cryptsvc

                Write-Output "12) Forcing discovery..."

                wuauclt /resetauthorization /detectnow

                Write-Output "Process complete. Please reboot your computer."
            }catch{
                Write-Warning "Unable to complete update purge."
            }
        }
    }
}


