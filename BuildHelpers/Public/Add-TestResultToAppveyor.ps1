function Add-TestResultToAppveyor {
    <#
    .SYNOPSIS
        Upload test results to AppVeyor

    .DESCRIPTION
        Upload test results to AppVeyor

    .EXAMPLE
        Add-TestResultToAppVeyor -TestFile C:\testresults.xml

    .LINK
        https://github.com/RamblingCookieMonster/BuildHelpers

    .LINK
        about_BuildHelpers
    #>
    [CmdletBinding()]
    [OutputType([void])]
    Param (
        # Appveyor Job ID
        [String]
        $APPVEYOR_JOB_ID = $Env:APPVEYOR_JOB_ID,

        [ValidateSet('mstest','xunit','nunit','nunit3','junit')]
        $ResultType = 'nunit',

        # List of files to be uploaded
        [Parameter(Mandatory,
                   Position,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName,
                   ValueFromRemainingArguments
        )]
        [Alias("FullName")]
        [string[]]
        $TestFile
    )

    begin {
            $wc = New-Object 'System.Net.WebClient'
    }

    process {
        foreach ($File in $TestFile) {
            if (Test-Path $File) {
                Write-Verbose "Uploading $File for Job ID: $APPVEYOR_JOB_ID"
                $wc.UploadFile("https://ci.appveyor.com/api/testresults/$ResultType/$($APPVEYOR_JOB_ID)", $File)
            }
        }
    }

    end {
        $wc.Dispose()
    }
}

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQULgljV5FBppbjUKRNTKgjTaln
# Z5agggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBTP927a
# ngpQr1Z+nKVb3QmvSJHHgjANBgkqhkiG9w0BAQEFAASBgBmN8KSecHSzZvVKdY3B
# skiYpVQwzNfCVabt1sBK7ZATwh2pHTbEdKQUb5Zj+ElPAKN2UhE6Y/PlbOHlba5h
# HypkrwbsN0I8jjP85gk5FdTDSWXlqZlYx70g05R+nvQ5TRCq4jwfT23mH9bYzETp
# HrUJ8s2hK7lModq012l1F2ki
# SIG # End signature block
