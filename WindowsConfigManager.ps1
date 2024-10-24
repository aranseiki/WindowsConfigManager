# Importing necessary modules for the script
Import-Module "$PSScriptRoot/src/Confirm-Parameter.psm1" -Force
Import-Module "$PSScriptRoot/src/Get-ConfigParameters.psm1" -Force
Import-Module "$PSScriptRoot/src/Get-UtilityFunctions.psm1" -Force
Import-Module "$PSScriptRoot/src/Manage-Configuration.psm1" -Force
Import-Module "$PSScriptRoot/src/Send-Notification.psm1" -Force

# Configuration file path and filename for storing user configuration settings
$UserConfigFilePath = "$PSScriptRoot/config"
$UserConfigFileName = 'UserConfig-WindowsConfigManager.ini'
$UserConfigFile = $UserConfigFilePath, $UserConfigFileName -join '/'

# Configuration file path and filename for storing assets configuration settings
$AssetsConfigFilePath = "$PSScriptRoot/config"
$AssetsConfigFileName = 'AssetsConfig-WindowsConfigManager.json'
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
            Write-Host `n "$($CurrentTask) " `n
        }
        
        $CurrentPath = $CurrentAsset.AssetPath

        # Verifica se existe uma função correspondente ao nome do asset
        $FunctionName = "Set-$($CurrentAsset.Name)Configuration"
        $returnFunction = $false
        
        # Confirma se a função existe
        if (Get-Command -Name $FunctionName -CommandType Function) {
            # Executa a função diretamente usando & (call operator)
            $returnFunction = & $FunctionName `
                -CurrentPath $CurrentPath `
                -CurrentTask $CurrentTask `
                -CurrentVerbose $CurrentVerbose

            if ($returnFunction) {
                Send-Notification `
                    -Title $CurrentAsset.NotificationData.Title `
                    -Message $CurrentAsset.NotificationData.Message `
                    -Duration 3000 `
                    -Icon $IconPath
        
                if ($CurrentVerbose) {
                    Write-Host "The function $FunctionName was executed successfully."
                }
            }
        } else {
            $messageErrorValue = "Function $FunctionName not found."

            if ($CurrentVerbose) {
                Write-Host $messageErrorValue -ForegroundColor Red
            }

            Throw $messageErrorValue
        }
    } catch {
        Return $($error[0].InvocationInfo)
    }
}
