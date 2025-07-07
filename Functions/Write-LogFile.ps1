<#
.SYNOPSIS
    Logs messages to specific log files depending on the parameter set provided.

.DESCRIPTION
    The Write-Log function logs messages to a log file based on the selected parameter set.
    - If the "TempScriptLog" parameter set is used, the log is written to "C:\temp\PowershellScriptLogs.txt".
    - Otherwise, the log is written to "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\PowershellScriptLogs.txt" by default.

.PARAMETER Message
    The message string that you want to log. This parameter is mandatory in both parameter sets.

.PARAMETER TempScriptLog
    A switch that specifies if the message should be logged to a temporary file path located at "C:\temp\PowershellScriptLogs.txt".
    This parameter is part of the "TempScriptLog" parameter set and is optional.
.PARAMETER PARAMETERSETNAME TempScriptLog
    This parameter set logs messages to the temporary path: "C:\temp\PowershellScriptLogs.txt".

.EXAMPLE
    Write-Log -Message "This is a test log message"
    This command logs the message to the Intune Management Extension log path by default.

.EXAMPLE
    Write-Log -Message "Temporary log message" -TempScriptLog
    This command logs the message to the temporary log file located at "C:\temp\PowershellScriptLogs.txt".

.NOTES
    Author: Dixie Wanner
    Version: 1.4
    Date: 07-07-2025
    The log entries are timestamped with the format "dd-MM-yyyy HH:mm:ss".
    Ensure the script has appropriate permissions to write to the specified log locations.
#>

function Write-LogFile {
    param (
        [String]$Message = "No log received.",
        [String]$ScriptName,
        [Switch]$ExitLine,
        [Parameter(ParameterSetName = "TempScriptLog")]
        [Switch]$TempScriptLog
        )
    switch ($PSCmdlet.ParameterSetName) {
        "TempScriptLog"{
            $LogPath = "C:\temp\PowershellScriptLogs.txt"
            if(-not(Test-Path "C:\temp\")){
                New-Item -ItemType Directory -Path "C:\" -Name "temp"
            }
        }
        Default {
            $LogPath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\PowershellScriptLogs.txt"
        }
    }

    $timestamp = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
    $logEntry = "$timestamp - $Message"
    if($ScriptName){
        $logEntry = "----- $scriptName -----`n"
    }
    if ($ExitLine) {
        $logEntry = "-----------------------------------------------------------------------------------"
    }

    try{
        Add-Content -Path $logpath -Value $logEntry -ErrorAction Stop
    }catch {
        Write-Warning "Unable to log at set destination : $($_.Exception.Message).`n New logpath location `"C:\temp\PowershellScriptLogs.txt`""
        if(-not(Test-Path "C:\temp\")){
                New-Item -ItemType Directory -Path "C:\" -Name "temp"
            }
        $LogPath = "C:\temp\PowershellScriptLogs.txt"
        Add-Content -Path $logpath -Value $logEntry
    }
    return $LogPath
}
