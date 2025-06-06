function Get-BuildEnvironmentDetail {
    <#
    .SYNOPSIS
        Get the details on the build environment

    .FUNCTIONALITY
        CI/CD

    .DESCRIPTION
        Get the details on the build environment.  You might use this to debug a build, particularly in environments not under your control.

    .PARAMETER Detail
        Which build environment details to collect.

        Defaults to *

        Valid choices:
          'OperatingSystem'  Subset of win32_operatingsystem
          'PSVersionTable'   Variable
          'ModulesLoaded'    Get-Module
          'ModulesAvailable' Get-Module -ListAvailable
          'PSModulePath'     ENV:
          'Path'             ENV:
          'Variables'        Get-Variable
          'Software'         Get-InstalledSoftware
          'Hotfixes'         Get-Hotfix
          'Location'         Get-Location
          'PackageProvider'  Get-PackageProvider
          'PackageSource'    Get-PackageSource

    .PARAMETER KillKittens
        If specified, apply formatting to the output (bad) and sent some of it to the host (worse)

    .EXAMPLE
        Get-BuildEnvironmentDetail

    .LINK
        https://github.com/RamblingCookieMonster/BuildHelpers

    .LINK
        about_BuildHelpers
    #>
    [cmdletbinding()]
    [OutputType( [String], [Hashtable])]
    param(
        [validateset('*',
                     'OperatingSystem',
                     'PSVersionTable',
                     'ModulesLoaded',
                     'ModulesAvailable',
                     'PSModulePath',
                     'Path',
                     'Variables',
                     'Software',
                     'Hotfixes',
                     'Location',
                     'PackageProvider',
                     'PackageSource')]
        [string[]]$Detail = '*',
        [switch]$KillKittens
    )

    if($Detail -contains '*')
    {
        $Detail =  'OperatingSystem',
                   'PSVersionTable',
                   'ModulesLoaded',
                   'ModulesAvailable',
                   'PSModulePath',
                   'Path',
                   'Variables',
                   'Software',
                   'Hotfixes',
                   'Location',
                   'PackageProvider',
                   'PackageSource'
    }

    $Details = @{}
    switch ($Detail)
    {
        'PSVersionTable'   { $Details.set_item($_, $PSVersionTable)}
        'PSModulePath'     { $Details.set_item($_, ($ENV:PSModulePath -split ';'))}
        'ModulesLoaded'    { $Details.set_item($_, (
            Get-Module |
                Select-Object Name, Version, Path |
                Sort-Object Name
        )) }
        'ModulesAvailable' { $Details.set_item($_, (
            Get-Module -ListAvailable |
                Select-Object Name, Version, Path |
                Sort-Object Name

        )) }
        'Path'             { $Details.set_item($_, ( $ENV:Path -split ';'))}
        'Variables'        { $Details.set_item($_, ( Get-Variable | Select-Object Name, Value ))}
        'Software'         { $Details.set_item($_, (
            Get-InstalledSoftware |
                Select-Object DisplayName, Publisher, Version, Hive, Arch))}
        'Hotfixes'         { $Details.set_item($_, ( Get-Hotfix ))}
        'OperatingSystem'  { $Details.set_item($_, (
            Get-CimInstance -classname win32_operatingsystem |
                Select-Object Caption, Version
        ))}
        'Location'         { $Details.set_item($_, ( Get-Location ).Path )}
        'PackageProvider'  { $Details.set_item($_, $(
            if(Get-Module PackageManagement -ListAvailable)
            {
                Get-PackageProvider | Select-Object Name, Version
            }
         ))}
        'PackageSource'    { $Details.set_item($_, $(
            if(Get-Module PackageManagement -ListAvailable)
            {
                Get-PackageSource | Select-Object Name, ProviderName, Location
            }
         ))}
    }

    if($KillKittens)
    {
        $lines = '----------------------------------------------------------------------'
        foreach($Key in $Details.Keys)
        {
            "`n$lines`n$Key`n`n"
            $Details.get_item($key) | Out-Host
        }
    }
    else
    {
        $Details
    }
}

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUZzlxF1sQTnjSdTQU63vw4bUe
# oCqgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQxwDCy
# dYirPm54pU3YHCg2CXCIhTANBgkqhkiG9w0BAQEFAASBgKrnmqwBvLTG3tS3katG
# 9z9Nnua6cfKzK8pyyR5GW7vaoS+GGh1mYgRcD/q1GzfCNnE6e3IPiiit0Nv5WjMk
# RNSAnv+PUfSHZJ90pGXwy+4iYAtojDssZEOivzL6/T9lL/NrxnQY1vK3/IZUXEW6
# rtS13dmSU0I8Rgyi+My67a7I
# SIG # End signature block
