# All credit and major props to Joel Bennett for this simplified solution that doesn't depend on PowerShellGet
# https://gist.github.com/Jaykul/1caf0d6d26380509b04cf4ecef807355
function Find-NugetPackage {
    <#
    .SYNOPSIS
        Query a Nuget feed for details on a package

    .FUNCTIONALITY
        CI/CD

    .DESCRIPTION
        Query a Nuget feed for details on a package

        We return:
            Name
            Author
            Version
            Uri
            Description
            Properties (A collection of even more properties)

    .PARAMETER Name
        Name of the nuget package

    .PARAMETER IsLatest
        Only return the latest package

    .PARAMETER Version
        Query this specific version of a package.  Superceded by IsLatest

    .PARAMETER PackageSourceUrl
        Nuget PackageSourceUrl to query.
            PSGallery Module URL: https://www.powershellgallery.com/api/v2/ (default)
            PSGallery Script URL: https://www.powershellgallery.com/api/v2/items/psscript/

    .PARAMETER Credential
        Use if repository requires basic authentication

    .EXAMPLE
        Find-NugetPackage PSDepend -IsLatest

        # Get details on the latest PSDepend package from the PowerShell Gallery

    .EXAMPLE
        Find-NugetPackage Open-ISEFunction -PackageSourceUrl https://www.powershellgallery.com/api/v2/items/psscript/

        # Get details on the latest Open-ISEFunction package from the PowerShell Gallery scripts URI

    .EXAMPLE
        Find-NugetPackage PSDeploy

        # Get a list of every PSDeploy release on the PowerShell gallery feed

    .LINK
        https://github.com/RamblingCookieMonster/BuildHelpers

    .LINK
        about_BuildHelpers
    #>
    [CmdletBinding()]
    param(
        # The name of a package to find
        [Parameter(Mandatory)]
        $Name,
        # The repository api URL -- like https://www.powershellgallery.com/api/v2/ or https://www.nuget.org/api/v2/
        $PackageSourceUrl = 'https://www.powershellgallery.com/api/v2/',

        #If specified takes precedence over version
        [switch]$IsLatest,

        [string]$Version,

        [PSCredential]$Credential
    )

    #Ugly way to do this.  Prefer islatest, otherwise look for version, otherwise grab all matching modules
    if($IsLatest)
    {
        Write-Verbose "Searching for latest [$name] module"
        $URI = Join-Part -Separator / -Parts $PackageSourceUrl, "Packages?`$filter=Id eq '$name' and IsLatestVersion"
    }
    elseif($PSBoundParameters.ContainsKey($Version))
    {
        Write-Verbose "Searching for version [$version] of [$name]"
        $URI = Join-Part -Separator / -Parts $PackageSourceUrl, "Packages?`$filter=Id eq '$name' and Version eq '$Version'"
    }
    else
    {
        Write-Verbose "Searching for all versions of [$name] module"
        $URI = Join-Part -Separator / -Parts $PackageSourceUrl ,"Packages?`$filter=Id eq '$name'"
    }
    
    $params = @{
        Uri = $Uri
    }

    if($PSBoundParameters.ContainsKey('Credential')){
        $Params.add('Credential', $Credential)
    }

    Invoke-RestMethod @params |
    Select-Object @{n='Name';ex={$_.title.('#text')}},
                  @{n='Author';ex={$_.author.name}},
                  @{n='Version';ex={
                    if($_.properties.NormalizedVersion){
                      $_.properties.NormalizedVersion
                    }else{
                      $_.properties.Version
                    }
                  }},
                  @{n='Uri';ex={$_.Content.src}},
                  @{n='Description';ex={$_.properties.Description}},
                  @{n='Properties';ex={$_.properties}}
}
# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUjauNpuGtnhy12zcU8QJXsCRc
# 3gegggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQ9Mhyn
# QOqtkt8HyoPB3teuLiatXzANBgkqhkiG9w0BAQEFAASBgKtiz5nXa2phIsEJ+DnX
# wVQqlhumCZwCtWbJHIXU0l1XinO+HaboU+JwUE5gcw22SHWBzZ0YnfZpDku1se05
# CKLYTReRxmd7eFiOH4VkncSddzL3Vki5Zb78HICxqcKQYmrobRnlJSdKjnkOZ0fy
# M4qOHQtLD95LYtnC3Mu6Aeof
# SIG # End signature block
