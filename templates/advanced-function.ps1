<#
.SYNOPSIS
    This cmdlet doesn't do anything, it's just an example.
.DESCRIPTION
    It outputs the text it was provided as input.
.EXAMPLE
    PS C:\> New-AdvancedFunction -Text "Hello world!"
    Print the text to the console.

    PS C:\> New-AdvancedFunction "Hello world!"
    Print the text to the console. Since it is the first and only parameter,
    it is also the first positional parameter. So it doesn't need the parameter
    name to work.
.INPUTS
    Text
.OUTPUTS
    Text
.NOTES
    Because of the Mandatory=$true, if an empty string ("" or '') is given,
    a ParameterBindingValidationException is thrown. If Mandatory is not
    specified, an empty string is fine.
    When writing to the console using Write-Host, string variables can be
    concatinated by listing them separated with a space.
#>
function New-AdvancedFunction {
    [CmdletBinding()]
    param (
        # Sample parameter
        [Parameter(
            Mandatory=$false)]
        [string]
        $Text
    )
    
    begin {
        $prefix = "New-AdvancedFunction: "
        Write-Verbose "In the beginning."
        Write-Host $prefix, $Text
    }
    
    process {
        Write-Verbose "Processing, processing, all I do is processing!"
    }
    
    end {
        Write-Verbose "And then there was nothing."
    }
}