<#
.SYNOPSIS
    Increments the ModuleVersion property in a PowerShell Module Manfiest
.DESCRIPTION
    Reads an existing Module Manifest file and increments the ModuleVersion property.
.EXAMPLE
    C:\PS> Step-ModuleVersion -Path .\testmanifest.psd1

    Will increment the Build section of the ModuleVersion
.EXAMPLE
    C:\PS> Step-ModuleVersion -Path .\testmanifest.psd1 -By Minor

    Will increment the Minor section of the ModuleVersion and set the Build section to 0.
.EXAMPLE
    C:\PS> Set-Location C:\source\testmanifest
    C:\PS> Step-ModuleVersion

    Will increment the Build section of the ModuleVersion of the manifest in the current
    working directory.
.INPUTS
    String
.NOTES
    This function should only read the module and call Update-ModuleManifest with
    the new Version, but there appears to be a bug in Update-ModuleManifest dealing
    with Object[] types so this function manually de-serializes the manifest and
    calls New-ModuleManifest to overwrite the manifest at Path.
.LINK
    http://semver.org/
.LINK
    New-ModuleManifest
#>
function Step-ModuleVersion {
    [CmdletBinding()]
    param(
        # Specifies a path a valid Module Manifest file.
        [Parameter(ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage="Path to one or more locations.")]
        [Alias("PSPath")]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string[]]
        $Path = (Get-Item $PWD\*.psd1)[0],

        # Version section to step
        [Parameter()]
        [ValidateSet("Major", "Minor", "Build","Patch")]
        [Alias("Type")]
        [string]
        $By = "Patch"
    )

    Process
    {
        foreach ($file in $Path)
        {
            $version = [Version](Get-Metadata -Path $file)
            Update-MetaData -Path $file -PropertyName ModuleVersion -Value (Step-Version $version $By)
        }
    }
}

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU4VZmW2IhwSeZTU22xd9Vg79f
# DZOgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSJ0OuV
# jWJuLVEQLKKUTlI915IFwDANBgkqhkiG9w0BAQEFAASBgGoUaPJ7SGwjoyaC4TLy
# 2Y4D7vKOX/iVSvJuvOR0hdVVaqQhtGB3Uxx/yhHa98iVAVgYzH/6FkGwiJuwbVzt
# ko1/khcEjSQHi5zwRH20l9/Z8tOrhAsoC5OXdjZTfuGED6lY2rOShtmFmPHGj+H/
# wioS69HRx6XGky7o75L+4D77
# SIG # End signature block
