function Get-PSModuleManifest {
    <#
    .SYNOPSIS
        Get the PowerShell module manifest for a project

    .FUNCTIONALITY
        CI/CD

    .DESCRIPTION
        Get the PowerShell module manifest for a project

        Evaluates based on the following scenarios:
            * Subfolder with the same name as the current folder with a psd1 file in it
            * Subfolder with a <subfolder-name>.psd1 file in it
            * Current folder with a <currentfolder-name>.psd1 file in it
            + Subfolder called "Source" or "src" (not case-sensitive) with a psd1 file in it

        Note: This does not handle paths in the format Folder\ModuleName\Version\

    .PARAMETER Path
        Path to project root. Defaults to the current working path

    .NOTES
        We assume you are in the project root, for several of the fallback options

    .EXAMPLE
        Get-PSModuleManifest

    .LINK
        https://github.com/RamblingCookieMonster/BuildHelpers

    .LINK
        Get-BuildVariable

    .LINK
        Set-BuildEnvironment

    .LINK
        about_BuildHelpers
    #>
    [cmdletbinding()]
    [OutputType( [String] )]
    param(
        $Path = $PWD.Path
    )

    $Path = ( Resolve-Path $Path ).Path

    $CurrentFolder = Split-Path $Path -Leaf
    $ExpectedPath = Join-Path -Path $Path -ChildPath $CurrentFolder
    $ExpectedManifest = Join-Path -Path $ExpectedPath -ChildPath "$CurrentFolder.psd1"
    if(Test-Path $ExpectedManifest)
    {
        $ExpectedManifest
    }
    else
    {
        # Look for properly organized modules
        $ProjectPaths = Get-ChildItem $Path -Directory |
            ForEach-Object {
                $ThisFolder = $_
                $ExpectedManifest = Join-Path $ThisFolder.FullName "$($ThisFolder.Name).psd1"
                If( Test-Path $ExpectedManifest)
                {
                    $ExpectedManifest
                }
            }

        if( @($ProjectPaths).Count -gt 1 )
        {
            Write-Warning "Found more than one project path via subfolders with psd1 files"
            $ProjectPaths
        }
        elseif( @($ProjectPaths).Count -eq 1 )
        {
            $ProjectPaths
        }
        #PSD1 in root of project - ick, but happens.
        elseif( Test-Path "$ExpectedPath.psd1" )
        {
            "$ExpectedPath.psd1"
        }
        # PSD1 in Source or Src folder
        elseif( Get-Item "$Path\S*rc*\*.psd1" -OutVariable SourceManifests)
        {
            If ( $SourceManifests.Count -gt 1 )
            {
                Write-Warning "Found more than one project manifest in the Source folder"
            }
            $SourceManifests.FullName
        }
        else
        {
            Write-Warning "Could not find a PowerShell module manifest from $($Path)"
        }
    }
}

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUjjuIOiXMxyVGxFGUoRQcart6
# DtCgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSllru5
# JJn9WuNbANOwPXqzg9V2gTANBgkqhkiG9w0BAQEFAASBgDdjhJuSLpfglKmXaD9Q
# lbfym3S776LBBsY517l5uUs2W7SS1Pkx4KpFe7nIFa6tyf5cV4Eo7U2r+ZGKSyhg
# xWbSuMwE11aMvqnlMsS8WX72GmpqVPw9Q6A4hcapN2fIdb9dUJPwmtzdmHEW1vVV
# yj3fCwkPq6lmrXeHCk9cMmZ+
# SIG # End signature block
