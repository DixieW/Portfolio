function Test-Connection() {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$True)]
        [array] $Computers
    )

    [array]$ActiveDevices = @()

    foreach ($Computer in $Computers){
        $test = Test-NetConnection -ComputerName $Computer -Hops 1 -ErrorAction SilentlyContinue
        if($test.PingSucceeded -eq "True"){
            $ActiveDevices += $computer
        }
    }

    return $ActiveDevices
}
