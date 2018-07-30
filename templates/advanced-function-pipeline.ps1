<#
.SYNOPSIS
    This cmdlet doesn't do anything, it's just an example.
.DESCRIPTION
    It outputs the text it was provided as input.
.EXAMPLE
    PS C:\> Test-Pipeline -Text "Hello world!"
    Print the text to the console.

    PS C:\> Test-Pipeline "Hello world!"
    Print the text to the console. Since it is the first and only parameter,
    it is also the first positional parameter. So it doesn't need the parameter
    name to work.

    PS C:\> "Hello World!" | Test-Pipeline
    Print the text to the console.
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
    If a value can be passed as a parameter and from the pipeline, it must only
    be one or the other. If both are used, the parameter will be used and a
    ParameterBindingException will be thrown with an error of pipeline cannot
    be bouned to any parameter.

    If the value can be from the pipeline or in a parameter the $_ variable is
    equal to $NULL (unset) using the parameter and an object using the pipeline.
#>
function Test-Pipeline {
    [CmdletBinding()]
    param (
        # Sample parameter
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true)]
        [string]
        $Text,

        # Sample text array parameter
        [string[]]
        $TextList
    )
    
    begin {
        $prefix = "Test-Pipeline: "
        Write-Verbose "In the beginning."
        switch ($Text) {
            $NULL { Write-Output "Big NULL"; break }
            $null { Write-Output "Little NULL"; break }
            "" { Write-Output "Empty String"; break }
            Default {Write-Output "I don't get it, it must be valid!"}
        }

        if ($TextList -ne $NULL) {
            Write-Output $prefix, $TextList
        } else {
            Write-Output $prefix, "Nothing in the TextList parameter!"
        }
    }
    
    process {
        Write-Verbose "Processing, processing, all I do is processing!"
        switch ($_) {
            $NULL { Write-Output "Big NULL"; break }
            $null { Write-Output "Little NULL"; break }
            "" { Write-Output "Empty String"; break }
            Default {Write-Output "I don't get it, it must be valid!"}
        }
        Write-Output $prefix $Text
        Write-Output $prefix $TextList
    }
    
    end {
        Write-Verbose "And then there was nothing."
        $PSCmdlet | fl *
    }
}