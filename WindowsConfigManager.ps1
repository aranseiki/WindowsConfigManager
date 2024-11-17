# Clear the console to make the output cleaner.
Clear-Host

while ($true) {
    Import-Module "$PSScriptRoot/scripts/MainRules.ps1" -Force
}
