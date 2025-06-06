function Get-NextNugetPackageVersion {
    <#
    .SYNOPSIS
        Get the next version for a nuget package, such as a module or script in the PowerShell Gallery

    .FUNCTIONALITY
        CI/CD

    .DESCRIPTION
        Get the next version for a nuget package, such as a module or script in the PowerShell Gallery

        Uses the versioning scheme adopted by the user

        Where possible, users should stick to semver: http://semver.org/ (Major.Minor.Patch, given restrictions .NET Version class)

        If no existing module is found, we return 0.0.1

    .PARAMETER Name
        Name of the nuget package

    .PARAMETER PackageSourceUrl
        Nuget PackageSourceUrl to query.
            PSGallery Module URL: https://www.powershellgallery.com/api/v2/ (default)
            PSGallery Script URL: https://www.powershellgallery.com/api/v2/items/psscript/

    .PARAMETER Credential
        Use if repository requires basic authentication

    .EXAMPLE
        Get-NextNugetPackageVersion PSDeploy

    .EXAMPLE
        Get-NextNugetPackageVersion Open-ISEFunction -PackageSourceUrl https://www.powershellgallery.com/api/v2/items/psscript/

    .LINK
        https://github.com/RamblingCookieMonster/BuildHelpers

    .LINK
        about_BuildHelpers
    #>
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipelineByPropertyName=$True)]
        [string[]]$Name,

        [string]$PackageSourceUrl = 'https://www.powershellgallery.com/api/v2/',

        [PSCredential]$Credential 
    )
    Process
    {
        foreach($Item in $Name)
        {
            Try
            {
                $params = @{
                    Name = $Item
                }
                if($PSBoundParameters.ContainsKey('Credential')){
                    $Params.add('Credential', $Credential)
                }
                $Existing = $null
                $Existing = Find-NugetPackage @params -PackageSourceUrl $PackageSourceUrl -IsLatest -ErrorAction Stop
            }
            Catch
            {
                if($_ -match "No match was found for the specified search criteria")
                {
                    New-Object System.Version (0,0,1)
                }
                else
                {
                    Write-Error $_
                }
                continue
            }

            if($Existing.count -gt 1)
            {
                Write-Error "Found more than one $Type matching '$Item': Did you use a wildcard?"
                continue
            }
            elseif($Existing.count -eq 0)
            {
                Write-Verbose "Found no $Type matching '$Item'"
                New-Object System.Version (0,0,1)
                continue
            }
            else
            {
                $Version = [System.Version]$Existing.Version
            }

            # using revision
            if($Version.Revision -ge 0)
            {
                $Build = if($Version.Build -le 0) { 0 } else { $Version.Build }
                $Revision = if($Version.Revision -le 0) { 1 } else { $Version.Revision + 1 }
                New-Object System.Version ($Version.Major, $Version.Minor, $Build, $Revision)
            }
            # using build
            elseif($Version.Build -ge 0)
            {
                $Build = if($Version.Build -le 0) { 1 } else { $Version.Build + 1 }
                New-Object System.Version ($Version.Major, $Version.Minor, $Build)
            }
            # using minor. wat?
            elseif($Version.Minor -ge 0)
            {
                $Minor = if($Version.Minor -le 0) { 1 } else { $Version.Minor + 1 }
                New-Object System.Version ($Version.Major, $Minor)
            }
            # using major only. I don't even.
            else
            {
                New-Object System.Version ($Version.Major + 1, 0)
            }
        }
    }
}

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUvpHzOtgCIQRwi3/6qJOeqTaX
# 6KmgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRxHxUx
# 4+2yog1sY4bfYDGQjEi5mDANBgkqhkiG9w0BAQEFAASBgFhoHEul38kkDMEotFQM
# zC7lTQd3QtBclO8oFHih6VuEJI6Y6xed9Q0G3y1OTXJaKlPwUoJardbMvXdBzFbD
# +J9KChWlr33ETrmh4eiPWFWndKFpkwzwFByaWGWFAJBSQ/uw9QyzYKHvKwEPr3LK
# z3y4+5jmi13C/sQgkLHpWEf3
# SIG # End signature block
