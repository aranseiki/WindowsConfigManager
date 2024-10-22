# To set the access value for a specific registry path.
Function Set-AccessItem {
    <#
        .SYNOPSIS
        Sets the access value ("Allow" or "Deny") for a given registry path.

        .PARAMETER Path
        The registry path where the access value will be set.

        .PARAMETER AccessValue
        The access value to be set ("Allow" or "Deny").

        .PARAMETER Verbose
        Controls whether detailed output will be displayed.
    #>
    Param(
        [string]$Path,
        [ValidateSet("Allow", "Deny")]
        [string]$AccessValue,
        [bool]$Verbose
    )

    # Check if the specified path exists
    if (-not (Test-Path $Path)) {
        if ($Verbose) {
            # Warn if path does not exist
            Write-Warning "Path not found: $($Path)"
        }
        # Exit the function if the path is not found
        return
    }

    try {
        # Create or update the access value in the registry
        New-ItemProperty -Path $Path `
            -Name "Value" -Value $AccessValue -PropertyType String -Force | Out-Null

        if ($Verbose) {
            # Confirm successful setting
            Write-Host "Access set to '$AccessValue' for path: $Path" -ForegroundColor Green
        }
    } catch {
        # Handle any errors that occur during the registry update
        if ($Verbose) {
            # Display error message
            Write-Error "Failed to set access for $($Path): $_"
        }
    }
}

# To enable access by setting the value to "Allow".
Function Enable-AccessItem {
    <#
        .SYNOPSIS
        Enables access for a given registry path by setting its value to "Allow".

        .PARAMETER Path
        The registry path where access will be enabled.

        .PARAMETER Verbose
        Controls whether detailed output will be displayed.
    #>
    Param(
        [string]$Path,
        [bool]$Verbose
    )
    # Call the Set-AccessItem function to set access to "Allow"
    Set-AccessItem -Path $Path -AccessValue "Allow" -Verbose $Verbose
}

# To disable access by setting the value to "Deny".
Function Disable-AccessItem {
    <#
        .SYNOPSIS
        Disables access for a given registry path by setting its value to "Deny".

        .PARAMETER Path
        The registry path where access will be disabled.

        .PARAMETER Verbose
        Controls whether detailed output will be displayed.
    #>
    Param(
        [string]$Path,
        [bool]$Verbose
    )
    # Call the Set-AccessItem function to set access to "Deny"
    Set-AccessItem -Path $Path -AccessValue "Deny" -Verbose $Verbose
}

# To get the current access value from the specified registry path.
Function Get-AccessPropertyItem {
    <#
        .SYNOPSIS
        Retrieves the current access value from the specified registry path.

        .PARAMETER Path
        The registry path from which the value will be retrieved.

        .PARAMETER Verbose
        Controls whether detailed output will be displayed.
    #>
    Param(
        [string]$Path,
        [bool]$Verbose
    )

    # Check if the specified path exists
    if (-not (Test-Path $Path)) {
        if ($Verbose) {
            # Warn if path does not exist
            Write-Warning "Path not found: $($Path)"
        }
        return  # Exit the function if the path is not found
    }

    try {
        # Retrieve the current access value from the registry
        $ValueResult = Get-ItemProperty -Path $Path | Select-Object -ExpandProperty "Value"
        
        if ($Verbose) {
            # Display current value
            Write-Host "Current value for $($Path): $ValueResult" -ForegroundColor Cyan
        }
        return $ValueResult  # Return the current value
    } catch {
        # Handle any errors that occur during the value retrieval
        if ($Verbose) {
            # Display error message
            Write-Error "Failed to get value for $($Path): $_"
        }
    }
}

# Function to change access based on the provided action.
Function Set-AccessForItem {
    <#
        .SYNOPSIS
        Changes the access for a registry item based on the provided action.

        .PARAMETER Path
        The registry path where the access will be changed.

        .PARAMETER Action
        The action to perform ("Allow" or "Deny").

        .PARAMETER Verbose
        Controls whether detailed output will be displayed.
    #>
    Param(
        [string]$Path,
        [ValidateSet("Allow", "Deny")]
        [string]$Action,
        [bool]$Verbose
    )

    # Retrieve the current access value
    $CurrentValue = Get-AccessPropertyItem -Path $Path -Verbose $Verbose

    # Check if the action needs to be applied
    if (
        ($Action.ToUpper() -eq 'DENY' -and $CurrentValue.ToUpper() -eq 'ALLOW') -or
        ($Action.ToUpper() -eq 'ALLOW' -and $CurrentValue.ToUpper() -eq 'DENY')
    ) {
        # Call the corresponding function to change the access
        if ($Action -eq 'Allow') {
            Enable-AccessItem -Path $Path -Verbose $Verbose
        } else {
            Disable-AccessItem -Path $Path -Verbose $Verbose
        }
        
        # Inform the new value
        $CurrentValue = Get-AccessPropertyItem -Path $Path -Verbose $Verbose
        if ($Verbose) {
            Write-Host "Changed value for $($Path): $($CurrentValue)" `n
        }
    }
}

Export-ModuleMember -Function Disable-AccessItem, Enable-AccessItem, Get-AccessPropertyItem, Set-AccessForItem, Set-AccessItem
