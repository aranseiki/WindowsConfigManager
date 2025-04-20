# Importing necessary modules for the script

# Define the root path according this script location
$RootPath = "$PSScriptRoot/.."
# Check if the script is running in a different environment, if it exists:
if ($env:WindowsConfigManagerRootPath) {
    # Set the root path to the environment variable
    $RootPath = $env:WindowsConfigManagerRootPath
}

# Importing necessary modules for the script
Import-Module "$RootPath/src/Confirm-Parameter.psm1" -Force
Import-Module "$RootPath/src/Get-ConfigParameters.psm1" -Force
Import-Module "$RootPath/src/Get-UtilityFunctions.psm1" -Force
Import-Module "$RootPath/src/Manage-Access.psm1" -Force
Import-Module "$RootPath/src/Manage-Configuration.psm1" -Force
Import-Module "$RootPath/src/Send-Notification.psm1" -Force
Import-Module "$RootPath/src/Set-SystemVolume.psm1" -Force

# Configuration file path and filename for storing user configuration settings
$UserConfigFilePath = "$RootPath/config"
$UserConfigFileName = 'UserConfig-WindowsConfigManager.ini'
$UserConfigFile = $UserConfigFilePath, $UserConfigFileName -join '/'

# Configuration file path and filename for storing assets configuration settings
$AssetsConfigFilePath = "$RootPath/config"
$AssetsConfigFileName = 'AssetsConfig-WindowsConfigManager.json'
$AssetsConfigFile = $AssetsConfigFilePath, $AssetsConfigFileName -join '/'

# Root path for notifications message icon settings
$AssetsPath = "$RootPath/assets"

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

# Loop through each asset in the configuration data (JSON data file)
foreach ($CurrentAsset in $AssetsConfigData) {
    try {
        # Set the current asset main variables
        $CurrentTask = $(
            Get-Variable -Include "$($CurrentAsset.Name)Task"
        ).Value
        $CurrentVerbose = $(
            Get-Variable -Include "$($CurrentAsset.Name)Verbose"
        ).Value

        # Set the current asset notification data variables
        $InformationNotificationData = $CurrentAsset.NotificationData | `
            Where-Object { $_.MessageType -eq 'Information' }
        $WarningNotificationData = $CurrentAsset.NotificationData | `
            Where-Object { $_.MessageType -eq 'Warning' }
        $ErrorgNotificationData = $CurrentAsset.NotificationData | `
            Where-Object { $_.MessageType -eq 'Error' }

        # Check if the verbose mode is enabled,
        #   if the verbose mode is enabled:
        if ($CurrentVerbose) {
            # Display the current asset name and task in the console
            Write-Host `n "$($CurrentAsset.Name): " `n
            Write-Host `n "$($CurrentTask) " `n
        }
        
        # Get the current asset path and access value
        $CurrentPath = $CurrentAsset.AssetPath

        # Get the current asset access value
        $CurrentAccessValue = Get-AccessPropertyItem `
            -Path $CurrentPath `
            -Verbose $CurrentVerbose

        # Check if the current access value is valid,
        #   if the access value is valid:
        if (Test-CurrentAccessValue `
                -CurrentAccessValue $CurrentAccessValue `
                -CurrentTask $CurrentTask
        ) {
            # Set the configuration function name
            $FunctionName = "Set-$($CurrentAsset.Name)Configuration"
            # Define default value to return function
            $returnFunction = $false

            # Check if the function exists in the current session,
            #  if the function exists:
            $FunctionCommandInfo = Get-Command `
                -Name $FunctionName `
                -CommandType 'Function' `
                -ErrorAction 'Ignore'
            
            # Check if the function was found, 
            #   if the function was not found:
            if (-not $FunctionCommandInfo) {
                # Set message to return function was not found
                $messageErrorValue = "Function $FunctionName not found."
                $ReturnFunctionColor = 'Red'
                
                # Check if the verbose mode is enabled,
                #   if the verbose mode is enabled:
                if ($CurrentVerbose) {
                    # Display the verbose message in the console
                    Write-Host $ReturnFunctionMessage `
                    -ForegroundColor $ReturnFunctionColor
                }

                # Throw error message to the user
                Throw $messageErrorValue
            }

            # Execute the function directly using & (call operator)
            $returnFunction = & $FunctionName `
                -CurrentPath $CurrentPath `
                -CurrentTask $CurrentTask `
                -CurrentVerbose $CurrentVerbose

            # Set the notification error values by default
            $NotificationIconPath = $ErrorgNotificationData.IconPath
            $NotificationMessageTitle = $ErrorgNotificationData.Title
            $NotificationMessageBody = $ErrorgNotificationData.Message
            $ReturnFunctionMessage = (
                "The function $FunctionName has failed to execute."
            )
            $ReturnFunctionColor = 'Red'
                
            # Check if the function was executed successfully,
            #   if the function was executed successfully:
            if($returnFunction) {                    
                # Set the notification success values as new values
                $NotificationIconPath = (
                    $InformationNotificationData.IconPath
                )
                $NotificationMessageTitle = (
                    $InformationNotificationData.Title
                )
                $NotificationMessageBody = (
                    $InformationNotificationData.Message
                )
                $ReturnFunctionMessage = (
                    "The function $FunctionName " +
                    "was executed successfully."
                )
                $ReturnFunctionColor = 'Green'

                # Get the current access value again
                $CurrentAccessValue = Get-AccessPropertyItem `
                    -Path $CurrentPath `
                    -Verbose $CurrentVerbose

                # Check if the current access value is valid,
                #   if the access value is valid:
                if (Test-CurrentAccessValue `
                        -CurrentAccessValue $CurrentAccessValue `
                        -CurrentTask $CurrentTask
                ) {
                    # Set the notification warning as new values
                    $NotificationIconPath = (
                        $WarningNotificationData.IconPath
                    )
                    $NotificationMessageTitle = (
                        $WarningNotificationData.Title
                    )
                    $NotificationMessageBody = (
                        $WarningNotificationData.Message
                    )
                    $ReturnFunctionMessage = (
                        "The function $FunctionName was" +
                        "executed successfully, but with warnings."
                    )
                    $ReturnFunctionColor = 'Yellow'
                }
            }

            # Check if the current access value is valid,
            #   if is not valid, throw an error message
            Confirm-Parameter `
                -ParamValue $NotificationMessageTitle `
                -ParamName -Title

            Confirm-Parameter `
                -ParamValue $NotificationMessageBody `
                -ParamName -Message

            Confirm-Parameter `
                -ParamValue $NotificationIconPath `
                -ParamName -Icon

            # Send a Windows notification message to the user
            Send-Notification `
                -Title $NotificationMessageTitle `
                -Message $NotificationMessageBody `
                -Duration 3000 `
                -Icon $NotificationIconPath
                
            # Check if the verbose mode is enabled,
            #   if the verbose mode is enabled:
            if ($CurrentVerbose) {
                # Display the verbose message in the console
                Write-Host $ReturnFunctionMessage `
                    -ForegroundColor $ReturnFunctionColor
            }
        }
    } catch {
        # Return the error message to the user
        Return $($error[0].InvocationInfo)
    }
}
