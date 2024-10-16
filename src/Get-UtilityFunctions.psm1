# Function that converts a string to its appropriate type.
function Convert-Value {
    <#
        .SYNOPSIS
        Converts a string value to its appropriate type based on specific rules.

        .PARAMETER Value
        The string value to be converted. The value can represent various types 
        including boolean, integer, decimal, date, URL, directory path, or list.

        .DESCRIPTION
        This function takes a string input and attempts to convert it into an 
        appropriate type based on the content of the string. The function 
        checks for boolean, integer, decimal, date, URL, valid directory path, 
        and lists (delimited by semicolons). If none of these conditions are met, 
        the input string is returned as-is, with single quotes removed if present.

        .EXAMPLE
        $result = Convert-Value "true"
        This example converts the string "true" to its boolean representation, 
        resulting in the boolean value $true.

        .EXAMPLE
        $result = Convert-Value "42"
        This example converts the string "42" to its integer representation, resulting 
        in the integer value 42.

        .EXAMPLE
        $result = Convert-Value "2024/10/16"
        This example converts the string "2024/10/16" to a DateTime object.
    #>
    param (
        [string] $Value
    )

    switch ($Value) {
        # Checks if the value is a boolean
        { $_ -eq 'true' -or $_ -eq 'false' } {
            return [bool]::Parse($Value)
        }

        # Attempts to convert to an integer
        { [int]::TryParse($_, [ref]$null) } {
            return [int]$Value
        }

        # Attempts to convert to a decimal
        { [decimal]::TryParse($_, [ref]$null) } {
            return [decimal]$Value
        }

        # Attempts to convert to a date
        { 
            # Normalizes the date string
            $normalizedValue = $_ -replace '/', '-'
            $dateValue = [datetime]::MinValue
            [datetime]::TryParse($normalizedValue, [ref]$dateValue) -and $dateValue -ne [datetime]::MinValue
        } {
            return $dateValue
        }

        # Checks if the value is a URL
        { $_ -match '^(http|https|ws)://' } {
            return [uri]$Value
        }

        # Checks if the value is a valid directory path
        {
            [System.IO.Path]::IsPathRooted($_)
        } {
            return [System.IO.DirectoryInfo]::new($Value)
        }

        # Checks if the value is a list (semicolon-delimited)
        { $_ -match ';' } {
            return $Value -split ';'
        }

        # Returns as string by default, removing single quotes if present
        default {
            return $Value.Trim("'")
        }
    }
}

function Get-File {
    param (
        [string]$FilePath,
        [string]$Filter
    )

    return $(
        Get-ChildItem `
            -Path $FilePath `
            -Filter $Filter | `
        Sort-Object {
            [version]($_.Name -replace '^[^\d]*|[^\d]*$', '')
        } -Descending | `
        Select-Object `
            -First 1 `
            -ExpandProperty 'FullName'
    )
}


Export-ModuleMember -Function Convert-Value, Get-File
