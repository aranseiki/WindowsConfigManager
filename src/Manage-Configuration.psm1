
Import-Module "$PSScriptRoot/Manage-Access.psm1" -Force
Import-Module "$PSScriptRoot/Set-SystemVolume.psm1" -Force

function Set-MuteAudioConfiguration {
    param(
        [string]$CurrentTask
    )

    if ($CurrentTask.ToUpper() -eq 'ALLOW') {
        return Set-MuteSystemAudio
    }
}

function Set-CameraConfiguration {
    param (
        [string]$CurrentPath,
        [string]$CurrentTask,
        [bool]$CurrentVerbose
    )

    $CurrentAccessValue = Get-AccessPropertyItem -Path $CurrentPath -Verbose $CurrentVerbose

    if (Test-CurrentAccessValue -CurrentAccessValue $CurrentAccessValue -CurrentTask $CurrentTask) {
        Set-AccessForItem -Path $CurrentPath -Action $CurrentTask -Verbose $CurrentVerbose
        return $true
    }

    return $false
}

function Set-LocationConfiguration {
    param (
        [string]$CurrentPath,
        [string]$CurrentTask,
        [bool]$CurrentVerbose
    )

    $CurrentAccessValue = Get-AccessPropertyItem -Path $CurrentPath -Verbose $CurrentVerbose

    if (Test-CurrentAccessValue -CurrentAccessValue $CurrentAccessValue -CurrentTask $CurrentTask) {
        Set-AccessForItem -Path $CurrentPath -Action $CurrentTask -Verbose $CurrentVerbose
        return $true
    }

    return $false
}

function Set-MicrophoneConfiguration {
    param (
        [string]$CurrentPath,
        [string]$CurrentTask,
        [bool]$CurrentVerbose
    )

    $CurrentAccessValue = Get-AccessPropertyItem -Path $CurrentPath -Verbose $CurrentVerbose

    if (Test-CurrentAccessValue -CurrentAccessValue $CurrentAccessValue -CurrentTask $CurrentTask) {
        Set-AccessForItem -Path $CurrentPath -Action $CurrentTask -Verbose $CurrentVerbose
        return $true
    }

    return $false
}

Export-ModuleMember -Function `
    Set-MuteAudioConfiguration, `
    Set-CameraConfiguration, `
    Set-LocationConfiguration, `
    Set-MicrophoneConfiguration
