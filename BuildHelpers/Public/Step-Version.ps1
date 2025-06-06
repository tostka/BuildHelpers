<#
.SYNOPSIS
    Increment a Semantic Version
.DESCRIPTION
    Parse a string in the format of MAJOR.MINOR.PATCH and increment the
    selected digit.
.EXAMPLE
    C:\PS> Step-Version 1.1.1
    1.1.2

    Will increment the Patch/Build section of the Version
.EXAMPLE
    C:\PS> Step-Version 1.1.1 Minor
    1.2.0

    Will increment the Minor section of the Version
.EXAMPLE
    C:\PS> Step-Version 1.1.1 Major
    2.0.0

    Will increment the Major section of the Version
.EXAMPLE
    C:\PS> $v = [version]"1.1.1"
    C:\PS> $v | Step-Version -Type Minor
    1.2.0
.INPUTS
    String
.OUTPUTS
    String
.NOTES
    This function operates on strings.
#>
function Step-Version {
    [CmdletBinding()]
    [OutputType([String])]
    param(
        # Version as string to increment
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [version]
        $Version,

        # Version section to step
        [Parameter(Position=1)]
        [ValidateSet("Major", "Minor", "Build","Patch")]
        [Alias("Type")]
        [string]
        $By = "Patch"
    )

    Process
    {
        $major = $Version.Major
        $minor = $Version.Minor
        $build = $Version.Build

        switch ($By) {
            "Major" { $major++
                    $minor = 0
                    $build = 0
                    break }
            "Minor" { $minor++
                    $build = 0
                    break }
            Default { $build++
                    break }
        }

        Write-Output (New-Object Version -ArgumentList $major, $minor, $build).ToString()
    }
}


# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUtnW6tczZdNSGdS2KU3IJM7T/
# Tm6gggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xNDEyMjkxNzA3MzNaFw0zOTEyMzEyMzU5NTlaMBUxEzARBgNVBAMTClRvZGRT
# ZWxmSUkwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBALqRVt7uNweTkZZ+16QG
# a+NnFYNRPPa8Bnm071ohGe27jNWKPVUbDfd0OY2sqCBQCEFVb5pqcIECRRnlhN5H
# +EEJmm2x9AU0uS7IHxHeUo8fkW4vm49adkat5gAoOZOwbuNntBOAJy9LCyNs4F1I
# KKphP3TyDwe8XqsEVwB2m9FPAgMBAAGjdjB0MBMGA1UdJQQMMAoGCCsGAQUFBwMD
# MF0GA1UdAQRWMFSAEL95r+Rh65kgqZl+tgchMuKhLjAsMSowKAYDVQQDEyFQb3dl
# clNoZWxsIExvY2FsIENlcnRpZmljYXRlIFJvb3SCEGwiXbeZNci7Rxiz/r43gVsw
# CQYFKw4DAh0FAAOBgQB6ECSnXHUs7/bCr6Z556K6IDJNWsccjcV89fHA/zKMX0w0
# 6NefCtxas/QHUA9mS87HRHLzKjFqweA3BnQ5lr5mPDlho8U90Nvtpj58G9I5SPUg
# CspNr5jEHOL5EdJFBIv3zI2jQ8TPbFGC0Cz72+4oYzSxWpftNX41MmEsZkMaADGC
# AWAwggFcAgEBMEAwLDEqMCgGA1UEAxMhUG93ZXJTaGVsbCBMb2NhbCBDZXJ0aWZp
# Y2F0ZSBSb290AhBaydK0VS5IhU1Hy6E1KUTpMAkGBSsOAwIaBQCgeDAYBgorBgEE
# AYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwG
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQzvH2M
# hb/Vy83iK9AffeMsTon5sTANBgkqhkiG9w0BAQEFAASBgBgCUnTNcCDhENY5CETR
# elNB347Zd2q6j+b3bRE+JNrCyUuRZeCsTjQHlLbFbjBezUhZMfkkD1IC0dG56XKk
# /1J0hF3z0i5+kL2xuTMiWxTtdo4al/pIyDh4rjX3j2NlJmjqB97Vj7/Ev10I+drY
# qRKduOjljR8TomDsr7hMv/kv
# SIG # End signature block
