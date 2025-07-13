<#
.SYNOPSIS
    Logs messages to specific log files depending on the parameter set provided.

.DESCRIPTION
    The Write-Log function logs messages to a log file based on the selected parameter set.
    - If the "TempScriptLog" parameter set is used, the log is written to "C:\temp\PowershellScriptLogs.txt".
    - Otherwise, the log is written to "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\PowershellScriptLogs.txt" by default.

.PARAMETER Message
    The message string that you want to log. This parameter is mandatory in both parameter sets.

.PARAMETER TestLogPath
    A switch that specifies if the message should be logged to a temporary file path located at "C:\temp\PowershellScriptLogs.txt".
    This parameter is part of the "TempScriptLog" parameter set and is optional.

.PARAMETER PARAMETERSETNAME IntuneScriptLog
    This parameter set is the default and logs messages to the Intune Management Extension log path:
    "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\PowershellScriptLogs.txt".

.PARAMETER PARAMETERSETNAME TempScriptLog
    This parameter set logs messages to the temporary path: "C:\temp\PowershellScriptLogs.txt".

.EXAMPLE
    Write-Log -Message "This is a test log message"
    This command logs the message to the Intune Management Extension log path by default.

.EXAMPLE
    Write-Log -Message "Temporary log message" -TestLogPath
    This command logs the message to the temporary log file located at "C:\temp\PowershellScriptLogs.txt".

.NOTES
    Author: Dixie Wanner
    Version: 1.2
    Date: 23-10-2024
    The log entries are timestamped with the format "dd-MM-yyyy HH:mm:ss".
    Ensure the script has appropriate permissions to write to the specified log locations.
#>


function Write-LogUpdate {
    param (
        [Parameter(mandatory, ParameterSetName = "IntuneScriptLog")]
        [Parameter(mandatory, ParameterSetName = "TempScriptLog")]
        [string]$Message,
        [Parameter(ParameterSetName = "TempScriptLog")]
        [switch]$TestLogPath
        )
    switch ($PSCmdlet.ParameterSetName) {
        "TempScriptLog"{
            $LogPath = "C:\temp\PowershellScriptLogs.txt"
        }
        Default {
            $LogPath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\PowershellScriptLogs.txt"
        }
    }

    $timestamp = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
    $logEntry = "$timestamp - $Message"
    Add-Content -Path $logpath  -Value $logEntry
}

