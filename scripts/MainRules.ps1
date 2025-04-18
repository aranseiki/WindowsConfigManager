# Importing necessary modules for the script
Import-Module "$PSScriptRoot/../src/Confirm-Parameter.psm1" -Force
Import-Module "$PSScriptRoot/../src/Get-ConfigParameters.psm1" -Force
Import-Module "$PSScriptRoot/../src/Get-UtilityFunctions.psm1" -Force
Import-Module "$PSScriptRoot/../src/Manage-Configuration.psm1" -Force
Import-Module "$PSScriptRoot/../src/Send-Notification.psm1" -Force

# Configuration file path and filename for storing user configuration settings
$UserConfigFilePath = "$PSScriptRoot/../config"
$UserConfigFileName = 'UserConfig-WindowsConfigManager.ini'
$UserConfigFile = $UserConfigFilePath, $UserConfigFileName -join '/'

# Configuration file path and filename for storing assets configuration settings
$AssetsConfigFilePath = "$PSScriptRoot/../config"
$AssetsConfigFileName = 'AssetsConfig-WindowsConfigManager.json'
$AssetsConfigFile = $AssetsConfigFilePath, $AssetsConfigFileName -join '/'

# Root path for notifications message icon settings
$AssetsPath = "$PSScriptRoot/../assets"

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

# Set the IconPath configuration variable for each asset in the configuration file.
foreach ($IconTypeData in $AssetsConfigData) {

    # Access each individual notification configuration entry within the current asset.
    foreach ($IconNotification in $IconTypeData.NotificationData) {

        # Store the asset name, which is used as a folder name in the icon path structure.
        [string] $IconName = $IconTypeData.Name

        # Store the notification message type, which determines the icon file name.
        [string] $IconType = $IconNotification.MessageType

        # Create the expected full path to the icon file based on the asset name and type.
        $IconPathValue = "$AssetsPath/$IconName/$IconType.ico"

        # Filter the notification entries to match the current message type.
        # Then add or update the 'IconPath' property with the constructed path.
        $IconTypeData.NotificationData | `
            Where-Object { $_.MessageType -eq $IconType } | `
            Add-Member NoteProperty -Name 'IconPath' -Value $IconPathValue -Force
    }
}

# Clear the console to make the output cleaner.
Clear-Host

foreach ($CurrentAsset in $AssetsConfigData) {
    try {
        $CurrentTask = $(Get-Variable -Include "$($CurrentAsset.Name)Task").Value
        $CurrentVerbose = $(Get-Variable -Include "$($CurrentAsset.Name)Verbose").Value
        # Set the icon path for the current asset
        $IconPath = $CurrentAsset.NotificationData.IconPath

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
