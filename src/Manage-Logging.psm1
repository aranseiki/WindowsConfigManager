function Write-LogFile {
    param (
        [System.Array]$Data,
        [string]$LogFile,
        [string]$Delimiter = ';'
    )

    $Data = $Data -join $Delimiter
    $Data | Out-File -Append -FilePath $LogFile
}

function New-LogFile {
    param (
        [string]$LogName = 'log.csv',
        [string]$LogPath,
        [System.Array]$Head,
        [string]$Delimiter = ';'
    )

    $Data = $Head -join $Delimiter
    $LogFile = $LogPath, $LogName -join '/'

    $Data | Out-File -Force -FilePath $LogFile
}
