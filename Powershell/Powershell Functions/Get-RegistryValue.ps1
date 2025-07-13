<#
.SYNOPSIS
    This function checks whether a specific registry key exists on a list of remote computers.

.DESCRIPTION
    The `Get-RegistryValue` function reads a TXT file containing a list of computer names, then connects to each computer's registry to check if a specified registry subkey exists under the 'LocalMachine' root.
    It outputs whether the registry key is found or not on each of the remote computers.

.PARAMETER computerFilePath
    The path to a TXT file that contains a list of computer names, each on a new line.
    This parameter is mandatory.

.PARAMETER registrySUBPath
    The registry subkey path to be checked on each remote computer, relative to the 'HKEY_LOCAL_MACHINE' root.
    This parameter is mandatory.

.EXAMPLE
    Get-RegistryValue -computerCSVPath "C:\computers.csv" -registrySUBPath "SOFTWARE\Microsoft\Windows\CurrentVersion"

    This example checks if the registry subkey `SOFTWARE\Microsoft\Windows\CurrentVersion` exists on each computer listed in the `computers.csv` file.

.EXAMPLE
    $computers = "C:\computers.txt"
    $subKey = "SOFTWARE\MyCompany\Settings"
    Get-RegistryValue -computerCSVPath $computers -registrySUBPath $subKey

    This example checks if the registry subkey `SOFTWARE\MyCompany\Settings` exists on the computers listed in `computers.txt`.

.NOTES
    - This function only works on remote computers where you have the necessary permissions.
    - Ensure the registry paths and remote computers are accessible from your machine.

.INPUTS
    [string] - Path to the file containing computer names.
    [string] - Registry subkey path to check.

.OUTPUTS
    [string] - A message indicating whether the registry key is found or not on each computer.

#>


function Get-RegistryValue {
    param (
        [Parameter(Mandatory=$true)]
        [array]$computerToCheck,
        [Parameter(Mandatory=$true)]
        [string]$registrySUBPath,
        [string]$registryValue
    )
    $listValueFound = [System.Collections.Generic.List[string]]::new()
    $listValueFound.Add("Value found on:")
    $listValueMissing = [System.Collections.Generic.List[string]]::new()
    $listValueMissing.Add("Value missing on:")

    try {

            foreach ($computer in $computerToCheck) {

                    try {
                        $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computer)
                    }
                    catch {
                        Write-Warning "Failed to connect or access the registry on $computer"
                        continue
                    }
                    if($reg){
                        $regKey = $reg.OpenSubKey($registrySUBPath)
                        if ($null -eq $regKey){
                            Write-Output "registry sub key not found on $computer"
                        } else {
                            Write-Output "registry sub key found on $computer"
                        }
                        if($registryValue){
                            $regValue= $regKey.GetValue($registryValue)
                            if ($null -eq $regValue){
                                Write-Output "Value $registryValue not found on $computer"
                                $listValueMissing.Add($computer.ToString())
                                Invoke-Command -ComputerName $computer -ScriptBlock {Write-Output "N" | gpupdate /force}
                            } else {
                                Write-Output "Value $registryValue found on $computer"
                                $regValue
                                $listValueFound.Add($computer.ToString())
                            }
                        }
                    }
                }

        }


    catch {
        Write-Error $($_.Exception.Message)
        Write-Output "Failed to connect or access the registry on $computer : $_"
    }

    Write-output $listValueFound
    Write-output $listValueMissing

}

. .\Test-Connection.ps1

function DeviceStatus() {
    param (
        [array]$DevicesToTest
        )

        $DevicesOnline = [System.Collections.Generic.List[string]]::new()

        foreach($i in $DevicesToTest){
            $connectionResult = Test-NetConnection $i
            if($connectionResult.PingSucceeded){
                [void]$DevicesOnline.add($i)
            }
    }
    return $DevicesOnline
}



