function Join-Part {
    <#
    .SYNOPSIS
        Join strings with a specified separator.

    .DESCRIPTION
        Join strings with a specified separator.

        This strips out null values and any duplicate separator characters.

        See examples for clarification.

    .PARAMETER Separator
        Separator to join with

    .PARAMETER Parts
        Strings to join

    .EXAMPLE
        Join-Part -Separator "/" this //should $Null /work/ /well

        # Output: this/should/work/well

    .EXAMPLE
        Join-Part -Parts http://this.com, should, /work/, /wel

        # Output: http://this.com/should/work/wel

    .EXAMPLE
        Join-Part -Separator "?" this ?should work ???well

        # Output: this?should?work?well

    .EXAMPLE

        $CouldBeOneOrMore = @( "JustOne" )
        Join-Part -Separator ? -Parts CouldBeOneOrMore

        # Output JustOne

        # If you have an arbitrary count of parts coming in,
        # Unnecessary separators will not be added

    .NOTES
        Credit to Rob C. and Michael S. from this post:
        http://stackoverflow.com/questions/9593535/best-way-to-Join-Part-with-a-separator-in-powershell

    #>
    [cmdletbinding()]
    param
    (
        [string]$Separator = "/",

        [parameter(ValueFromRemainingArguments=$true)]
        [string[]]$Parts = $null
    )

    ( $Parts |
        Where-Object { $_ } |
        Foreach-Object { ( [string]$_ ).trim($Separator) } |
        Where-Object { $_ }
    ) -join $Separator
}

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUufodaij6k1o3JB+E4F8lLqgv
# AzugggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSTaM+X
# JZSCFiLK4r0MREpLrwn56DANBgkqhkiG9w0BAQEFAASBgLYmXnvEXfmvXvJ6v4oI
# 5OBO7L4OsEQ3OY/X7wFAnGl8327K2U8uz+ANa09Xw98h7sTTJegjoFeg1CCHNHjW
# roaG0l5rKg3xbYHK8Bq+ZDtLD+Q7bv6VdTU+5rCsGz/yn0Kc5JPIi1ErUJZS7YmT
# PnIRvGyIO2FvUt2wSpVjSaxW
# SIG # End signature block
