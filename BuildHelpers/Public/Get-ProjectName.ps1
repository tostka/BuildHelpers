function Get-ProjectName
{
    <#
    .SYNOPSIS
        Get the name for this project

    .FUNCTIONALITY
        CI/CD

    .DESCRIPTION
        Get the name for this project

        Evaluates based on the following scenarios:
            * Subfolder with the same name as the current folder
            * Subfolder with a <subfolder-name>.psd1 file in it
            * Current folder with a <currentfolder-name>.psd1 file in it
            + Subfolder called "Source" or "src" (not case-sensitive) with a psd1 file in it

        If no suitable project name is discovered, the function will return
        the name of the root folder as the project name.

    .PARAMETER Path
        Path to project root. Defaults to the current working path

    .NOTES
        We assume you are in the project root, for several of the fallback options

    .EXAMPLE
        Get-ProjectName

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
    param(
        $Path = $PWD.Path,
        [validatescript({
            if(-not (Get-Command $_ -ErrorAction SilentlyContinue))
            {
                throw "Could not find command at GitPath [$_]"
            }
            $true
        })]
        $GitPath = 'git'
    )

    if(!$PSboundParameters.ContainsKey('GitPath')) {
        $GitPath = (Get-Command $GitPath -ErrorAction SilentlyContinue)[0].Path
    }

    $WeCanGit = ( (Test-Path $( Join-Path $Path .git )) -and (Get-Command $GitPath -ErrorAction SilentlyContinue) )

    $Path = ( Resolve-Path $Path ).Path
    $CurrentFolder = Split-Path $Path -Leaf
    $ExpectedPath = Join-Path -Path $Path -ChildPath $CurrentFolder
    if(Test-Path $ExpectedPath)
    {
        $result = $CurrentFolder
    }
    else
    {
        # Look for properly organized modules
        $ProjectPaths = Get-ChildItem $Path -Directory |
            Where-Object {
            Test-Path $(Join-Path $_.FullName "$($_.name).psd1")
        } |
            Select-Object -ExpandProperty Fullname

        if( @($ProjectPaths).Count -gt 1 )
        {
            Write-Warning "Found more than one project path via subfolders with psd1 files"
            $result = Split-Path $ProjectPaths -Leaf
        }
        elseif( @($ProjectPaths).Count -eq 1 )
        {
            $result = Split-Path $ProjectPaths -Leaf
        }
        # PSD1 in Source or Src folder
        elseif( Get-Item "$Path\S*rc*\*.psd1" -OutVariable SourceManifests)
        {
            If ( $SourceManifests.Count -gt 1 )
            {
                Write-Warning "Found more than one project manifest in the Source folder"
            }
            $result = $SourceManifests.BaseName
        }
        #PSD1 in root of project - ick, but happens.
        elseif( Test-Path "$ExpectedPath.psd1" )
        {
            $result = $CurrentFolder
        }
        #PSD1 in root of project but name doesn't match
        #very ick or just an icky time in Azure Pipelines
        elseif ( $PSDs = Get-ChildItem -Path $Path "*.psd1" )
        {
            if ($PSDs.count -gt 1) {
                Write-Warning "Found more than one project manifest in the root folder"
            }
            $result = $PSDs.BaseName
        }
        #Last ditch, are you in Azure Pipelines or another CI that checks into a folder unrelated to the project?
        #let's try some git
        elseif ( $WeCanGit ) {
            $result = (Invoke-Git -Path $Path -GitPath $GitPath -Arguments "remote get-url origin").Split('/')[-1] -replace "\.git",""
        }
        else
        {
            Write-Warning "Could not find a project from $($Path); defaulting to project root for name"
            $result = Split-Path $Path -Leaf
        }
    }

    if ($env:APPVEYOR_PROJECT_NAME -and $env:APPVEYOR_JOB_ID -and ($result -like $env:APPVEYOR_PROJECT_NAME))
    {
        $env:APPVEYOR_PROJECT_NAME
    }
    else
    {
        $result
    }
}

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUJV8/wSKVWXbXDCCQ2vOo71EY
# zD6gggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSjK3fa
# 5S3zEjRBpM0QqwCqd3bfzTANBgkqhkiG9w0BAQEFAASBgC3Ukn/8ho6uWwP0aAyj
# 47aZzU+e9fj8gve87kLnsthR1Gbcbu3fxFEgQY/FbvUR2cpYNy2H1vvQt54PlBkA
# +RdZI/vpgJyAhpWksq8rdowak2zn2VhsvoHmEGKHdKO/wPlJtFaW8bvDUVqlscBJ
# EBCnbpWOCvkev2ikgEdGYgj9
# SIG # End signature block
