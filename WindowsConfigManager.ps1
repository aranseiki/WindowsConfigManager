# Importing necessary modules for the script
Import-Module "$PSScriptRoot/src/Confirm-Parameter.psm1" -Force
Import-Module "$PSScriptRoot/src/Get-ConfigParameters.psm1" -Force
Import-Module "$PSScriptRoot/src/Get-UtilityFunctions.psm1" -Force
Import-Module "$PSScriptRoot/src/Manage-Access.psm1" -Force
Import-Module "$PSScriptRoot/src/Send-Notification.psm1" -Force

# Configuration file path and filename for storing configuration settings
$ConfigFilePath = "$PSScriptRoot/config"
$ConfigFileName = 'Config-WindowsConfigManager.ini'
$configFile = $ConfigFilePath, $ConfigFileName -join '/'
# Retrieves parameters from the configuration file using the imported function
$ConfigData = Get-ConfigParameters -ConfigFilePath $configFile

# Set configuration variables based on the data retrieved from the config file
Set-ConfigVariables -ConfigData $ConfigData -AppendSectionToVariableName $true

# Convert values for several variables to ensure they are in the correct format
# Configuration for microphone
$MicrophoneTask = Convert-Value -Value $MicrophoneTask
$MicrophoneVerbose = Convert-Value -Value $MicrophoneVerbose

# Configuration for camera
$CameraTask = Convert-Value -Value $CameraTask
$CameraVerbose = Convert-Value -Value $CameraVerbose

$AssetsData = @(
    @{
        'Name' = 'Microphone'
        'AssetPath' = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone'
        'NotificationData' = @{
            'Title' = 'Configuration Changed'
            'Message' = 'The microphone has been activated!'
            'Icon' = "$env:SystemRoot\System32\shell32.dll"
        }
    },
    @{
        'Name' = 'Camera'
        'AssetPath' = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam'
        'NotificationData' = @{
            'Title' = 'Configuration Changed'
            'Message' = 'The camera has been activated!'
            'Icon' = "$env:SystemRoot\System32\shell32.dll"
        }
    }
)

# Clear the console to make the output cleaner.
Clear-Host

foreach ($CurrentAsset in $AssetsData) {
    $CurrentTask = $(Get-Variable -Include "$($CurrentAsset.Name)Task").Value
    $CurrentVerbose = $(Get-Variable -Include "$($CurrentAsset.Name)Verbose").Value

    # Header for microphone section
    Write-Host `n "$($CurrentAsset.Name): " `n
    $microphonePath = $CurrentAsset.AssetPath
    $CurrentAccessValue = Get-AccessPropertyItem -Path $microphonePath -Verbose $CurrentVerbose
    $CurrentIconObj = [System.Drawing.Icon]::ExtractAssociatedIcon($CurrentAsset.NotificationData.Icon)

    if (
        (($CurrentAccessValue.ToUpper() -eq 'DENY') -and ($CurrentTask.ToUpper() -eq 'ALLOW')) -or
        (($CurrentAccessValue.ToUpper() -eq 'ALLOW') -and ($CurrentTask.ToUpper() -eq 'DENY'))
    ) {
        # Use the new function for the microphone
        Set-AccessForItem -Path $microphonePath -Action $CurrentTask -Verbose $CurrentVerbose
        Send-Notification `
            -Title $CurrentAsset.NotificationData.Title `
            -Message $CurrentAsset.NotificationData.Message `
            -Duration 3000 `
            -Icon $CurrentIconObj
    }
}
