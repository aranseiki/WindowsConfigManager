# Importing necessary modules for the script
Import-Module "$PSScriptRoot/src/Confirm-Parameter.psm1" -Force
Import-Module "$PSScriptRoot/src/Get-ConfigParameters.psm1" -Force
Import-Module "$PSScriptRoot/src/Get-UtilityFunctions.psm1" -Force
Import-Module "$PSScriptRoot/src/Manage-Access.psm1" -Force
Import-Module "$PSScriptRoot/src/Send-Notification.psm1" -Force

# Configuration file path and filename for storing user configuration settings
$UserConfigFilePath = "$PSScriptRoot/config"
$UserConfigFileName = 'UserConfig-WindowsConfigManager.ini'
$UserConfigFile = $UserConfigFilePath, $UserConfigFileName -join '/'

# Configuration file path and filename for storing assets configuration settings
$AssetsConfigFilePath = "$PSScriptRoot/config"
$AssetsConfigFileName = 'AssetsConfig-WindowsConfigManager.ini'
$AssetsConfigFile = $AssetsConfigFilePath, $AssetsConfigFileName -join '/'

# Retrieves parameters from the configuration file using the imported function
$UserConfigData = Get-ConfigParameters -ConfigFilePath $UserConfigFile

# Set configuration variables based on the data retrieved from the config file
$VariableList = Set-ConfigVariables -ConfigData $UserConfigData -AppendSectionToVariableName $true

foreach ($Variavel in $VariableList) {
    # Convert values for several variables to ensure they are in the correct format
    Set-Variable $Variavel -Value $(
        Convert-Value (Get-Variable $Variavel).Value
    )
}

# Retrieves parameters from the configuration file using the imported function
$AssetsConfigData = Get-Content -Path $AssetsConfigFile -Raw | ConvertFrom-Json

# Clear the console to make the output cleaner.
Clear-Host

foreach ($CurrentAsset in $AssetsConfigData) {
    try {
        $CurrentTask = $(Get-Variable -Include "$($CurrentAsset.Name)Task").Value
        $CurrentVerbose = $(Get-Variable -Include "$($CurrentAsset.Name)Verbose").Value
        $IconPath = [string] $CurrentAsset.NotificationData.Icon

        if ($CurrentVerbose) {
            Write-Host `n "$($CurrentAsset.Name): " `n
        }

        $CurrentPath = $CurrentAsset.AssetPath
        $CurrentAccessValue = Get-AccessPropertyItem -Path $CurrentPath -Verbose $CurrentVerbose

        if (
            (($CurrentAccessValue.ToUpper() -eq 'DENY') -and ($CurrentTask.ToUpper() -eq 'ALLOW')) -or
            (($CurrentAccessValue.ToUpper() -eq 'ALLOW') -and ($CurrentTask.ToUpper() -eq 'DENY'))
        ) {
            Set-AccessForItem -Path $CurrentPath -Action $CurrentTask -Verbose $CurrentVerbose
            Send-Notification `
                -Title $CurrentAsset.NotificationData.Title `
                -Message $CurrentAsset.NotificationData.Message `
                -Duration 3000 `
                -Icon $IconPath
        }
    } catch {
        Return $($error[0].InvocationInfo)
    }
}
