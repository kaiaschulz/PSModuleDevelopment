function Convert-PSMDSecureString {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER pass
    Parameter description

    .EXAMPLE
    PS C:\> Convert-PSMDSecureString

    An example

    .NOTES
    General notes
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]$pass
    )

    $ssPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass)
    try {
        return [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ssPtr)
    }
    finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ssPtr)
    }
}