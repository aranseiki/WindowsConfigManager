# Importing necessary modules for the script
Import-Module "$PSScriptRoot/src/Confirm-Parameter.psm1" -Force
Import-Module "$PSScriptRoot/src/Get-ConfigParameters.psm1" -Force
Import-Module "$PSScriptRoot/src/Get-UtilityFunctions.psm1" -Force
Import-Module "$PSScriptRoot/src/Manage-Access.psm1" -Force

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

# Clear the console to make the output cleaner.
Clear-Host

# Header for microphone section
Write-Host `n "Microphone: " `n

# Use the new function for the microphone
$microphonePath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone"
Set-AccessForItem -Path $microphonePath -Action $MicrophoneTask -Verbose $MicrophoneVerbose

# Header for Camera section
Write-Host `n "Camera: " `n

# Use the new function for the Camera
$CameraPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam"
Set-AccessForItem -Path $CameraPath -Action $CameraTask -Verbose $CameraVerbose

