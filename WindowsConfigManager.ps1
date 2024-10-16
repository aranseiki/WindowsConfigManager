# Importing necessary modules for the script
Import-Module "$PSScriptRoot/src/Confirm-Parameter.psm1"
Import-Module "$PSScriptRoot/src/Get-ConfigParameters.psm1"
Import-Module "$PSScriptRoot/src/Get-UtilityFunctions.psm1"
Import-Module "$PSScriptRoot/src/Manage-Access.psm1"

# Configuration file path and filename for storing configuration settings
$ConfigFilePath = "$PSScriptRoot/config"
$ConfigFileName = 'Config-WindowsConfigManager.ini'
$configFile = $ConfigFilePath, $ConfigFileName -join '/'
# Retrieves parameters from the configuration file using the imported function
$ConfigData = Get-ConfigParameters -ConfigFilePath $configFile

# Set configuration variables based on the data retrieved from the config file
Set-ConfigVariables -ConfigData $ConfigData

# Convert values for several variables to ensure they are in the correct format
$Task = Convert-Value -Value $Task
$Verbose = Convert-Value -Value $Verbose

# Clear the console to make the output cleaner.
Clear-Host

# Header for microphone section
Write-Host `n "Microphone: " `n

# Use the new function for the microphone
$microphonePath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone"
Set-AccessForItem -Path $microphonePath -Action $Task -Verbose $Verbose

# Header for webcam section
Write-Host `n "Webcam: " `n

# Use the new function for the webcam
$webcamPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam"
Set-AccessForItem -Path $webcamPath -Action $Task -Verbose $Verbose
