# Clear the console to make the output cleaner.
Clear-Host

# Set the root path for the project
$env:WindowsConfigManagerRootPath = $PSScriptRoot

# While loop to keep the script running
while ($true) {
    # Importing the main script
    Import-Module "$PSScriptRoot/scripts/MainRules.ps1" -Force
}
