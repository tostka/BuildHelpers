function Get-NextPowerShellGetVersion {
    <#
    .SYNOPSIS
        DEPRECATED: Please use Get-NextNugetPackageVersion

        Get the next version for a module or script in the PowerShell Gallery

    .FUNCTIONALITY
        CI/CD

    .DESCRIPTION
        DEPRECATED: Please use Get-NextNugetPackageVersion

        Get the next version for a module or script in the PowerShell Gallery

        Uses the versioning scheme adopted by the user

        Where possible, users should stick to semver: http://semver.org/ (Major.Minor.Patch, given restrictions .NET Version class)

        This requires the PowerShellGet module

        If no existing module is found, we return 0.0.1

    .PARAMETER Name
        Name of the PowerShell module or script

    .PARAMETER Type
        Module or script.  Defaults to module.

    .EXAMPLE
        Get-NextPowerShellGetVersion PSDeploy

    .EXAMPLE
        Get-NextPowerShellGetVersion Open-ISEFunction -Type Script

    .LINK
        https://github.com/RamblingCookieMonster/BuildHelpers

    .LINK
        about_BuildHelpers
    #>
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName = $True)]
        [string[]]$Name,

        [parameter(ValueFromPipelineByPropertyName = $True)]
        [ValidateSet('Module', 'Script')]
        [string]$Type = 'Module',

        [string]$Repository = 'PSGallery'
    )
    Begin {
        Write-Warning "DEPRECATED: Please use Get-NextNugetPackageVersion"
    }
    Process {
        foreach ($Item in $Name) {
            Try {
                $Existing = $null
                if ($Type -eq 'Module') {
                    $Existing = Find-Module -Name $Item -Repository $Repository -ErrorAction Stop
                }
                else {
                    # Script
                    $Existing = Find-Script -Name $Item -Repository $Repository -ErrorAction Stop
                }
            }
            Catch {
                if ($_ -match "No match was found for the specified search criteria") {
                    New-Object System.Version (0, 0, 1)
                }
                else {
                    Write-Error $_
                }
                continue
            }

            if ($Existing.count -gt 1) {
                Write-Error "Found more than one $Type matching '$Item': Did you use a wildcard?"
                continue
            }
            elseif ($Existing.count -eq 0) {
                Write-Verbose "Found no $Type matching '$Item'"
                New-Object System.Version (0, 0, 1)
                continue
            }
            else {
                $Version = $Existing.Version
            }

            # using revision
            if ($Version.Revision -ge 0) {
                $Build = if ($Version.Build -le 0) { 0 } else { $Version.Build }
                $Revision = if ($Version.Revision -le 0) { 1 } else { $Version.Revision + 1 }
                New-Object System.Version ($Version.Major, $Version.Minor, $Build, $Revision)
            }
            # using build
            elseif ($Version.Build -ge 0) {
                $Build = if ($Version.Build -le 0) { 1 } else { $Version.Build + 1 }
                New-Object System.Version ($Version.Major, $Version.Minor, $Build)
            }
            # using minor. wat?
            elseif ($Version.Minor -ge 0) {
                $Minor = if ($Version.Minor -le 0) { 1 } else { $Version.Minor + 1 }
                New-Object System.Version ($Version.Major, $Minor)
            }
            # using major only. I don't even.
            else {
                New-Object System.Version ($Version.Major + 1, 0)
            }
        }
}
}

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU/+D7ODF7EzntmBiYC/+wLyGO
# rpCgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRUhE4g
# zJs7ZBtPMYLswkCABlsWvzANBgkqhkiG9w0BAQEFAASBgLSnipU1yYrRUJLH43GH
# iKLcQzbq1bx4+c9X5s87OTq18e0BZ9T6i3UdFyXbcOCXKAOysYixD6paQGS2pbjG
# qPxyDNRsxZxYO1vjJRN6zy65mFzWulW4atA1YFZ2dPAsFI3XzxWcUKJKtaGbPLah
# A7hcbn79266TNYBGim6UBOqe
# SIG # End signature block
