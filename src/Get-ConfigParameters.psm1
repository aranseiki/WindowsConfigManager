# Function that reads a configuration file and returns the parameters organized in a hashtable.
function Get-ConfigParameters {
    <#
        .SYNOPSIS
        Reads a configuration file and extracts its parameters into a structured hashtable.

        .PARAMETER ConfigFilePath
        The path to the configuration file to be read.

        .DESCRIPTION
        This function processes a configuration file that follows a section-based format. 
        Each section is defined within square brackets, and parameters within those sections 
        are specified in the format of name=value. It returns a hashtable where each key 
        corresponds to a section, and the value is another hashtable containing the parameters.

        .EXAMPLE
        $config = Get-ConfigParameters -ConfigFilePath "C:\path\to\config.ini"
        This example reads the specified configuration file and stores the parameters in the $config variable.
    #>
    param (
        [string] $ConfigFilePath
    )

    $ConfigFileContent = Get-Content -Path $ConfigFilePath
    $ConfigParameterList = @{}
    $CurrentSection = ""

    foreach ($Row in $ConfigFileContent) {
        $Row = $Row.Trim()
        # Replace backslashes with forward slashes
        $Row = $Row -replace '\\', '/'

        # Ignore empty lines or comments
        if (-not $Row -or $Row.StartsWith(";")) {
            continue
        }

        # Check if it's a section
        if ($Row.StartsWith("[") -and $Row.EndsWith("]")) {
            $CurrentSection = $Row.Trim('[', ']')
            $ConfigParameterList[$CurrentSection] = @{}
        }
        else {
            # Process the name=value format
            $ConvertedText = ConvertFrom-StringData -StringData $Row

            # Add parameters to the current section
            if ($CurrentSection) {
                $ConfigParameterList[$CurrentSection] += $ConvertedText
            }
        }
    }

    return $ConfigParameterList
}

# Function that dynamically creates global variables from configuration data in a hashtable.
function Set-ConfigVariables {
    <#
        .SYNOPSIS
        Sets global variables based on the provided configuration data.

        .PARAMETER ConfigData
        A hashtable containing configuration data with sections and parameters.

        .PARAMETER AppendSectionToVariableName
        A boolean value indicating whether to append the section name to the variable name 
        if a variable with the simple name already exists. Default is false.

        .DESCRIPTION
        This function iterates through a hashtable of configuration data, creating global 
        variables dynamically. The variable names can be based solely on the parameter keys 
        or can include the section name if specified. If a variable with the same name already 
        exists and the option to append the section name is enabled, the new variable will 
        be named by combining the section and the key.

        .EXAMPLE
        Set-ConfigVariables -ConfigData $config -AppendSectionToVariableName $true
        This example sets global variables based on the $config hashtable and appends the 
        section name to the variable names if necessary.
    #>
    param (
        [hashtable] $ConfigData, 
        [bool] $AppendSectionToVariableName = $false
    )

    $VariableList = @()
    # Dynamic variable creation based on keys and values
    foreach ($Section in $ConfigData.Keys) {
        foreach ($Key in $ConfigData[$Section].Keys) {
            # Simple variable name, just the key
            $VariableName = $Key

            # Check if $AppendSectionToVariableName is enabled
            if ($AppendSectionToVariableName) {
                # Add section name in the variable name
                $VariableName = $Section + $Key
            }

            $ConfigDataValue = $ConfigData[$Section][$Key]
            # Setting the variable value dynamically
            Set-Variable -Name $VariableName -Value $ConfigDataValue -Scope Global
            $VariableList += $VariableName
        }
    }

    return $VariableList
}

Export-ModuleMember -Function `
    Get-ConfigParameters, `
    Set-ConfigVariables
