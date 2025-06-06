    <#
    .SYNOPSIS
        Bootstrap PSDepend

    .DESCRIPTION
        Bootstrap PSDepend

        Why? No reliance on PowerShellGallery

          * Downloads nuget to your ~\ home directory
          * Creates $Path (and full path to it)
          * Downloads module to $Path\PSDepend
          * Moves nuget.exe to $Path\PSDepend (skips nuget bootstrap on initial PSDepend import)

    .PARAMETER Path
        Module path to install PSDepend

        Defaults to Profile\Documents\WindowsPowerShell\Modules

    .EXAMPLE
        .\Install-PSDepend.ps1 -Path C:\Modules

        # Installs to C:\Modules\PSDepend
    #>
    [cmdletbinding()]
    param(
        [string]$Path = $( Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'WindowsPowerShell\Modules')
    )
    $ExistingProgressPreference = "$ProgressPreference"
    $ProgressPreference = 'SilentlyContinue'
    try {
        # Bootstrap nuget if we don't have it
        if(-not ($NugetPath = (Get-Command 'nuget.exe' -ErrorAction SilentlyContinue).Path)) {
            $NugetPath = Join-Path $ENV:USERPROFILE nuget.exe
            if(-not (Test-Path $NugetPath)) {
                Invoke-WebRequest -uri 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe' -OutFile $NugetPath
            }
        }

        # Bootstrap PSDepend, re-use nuget.exe for the module
        if($path) { $null = mkdir $path -Force }
        $NugetParams = 'install', 'PSDepend', '-Source', 'https://www.powershellgallery.com/api/v2/',
                    '-ExcludeVersion', '-NonInteractive', '-OutputDirectory', $Path
        & $NugetPath @NugetParams
        Move-Item -Path $NugetPath -Destination "$(Join-Path $Path PSDepend)\nuget.exe" -Force
    }
    finally {
        $ProgressPreference = $ExistingProgressPreference
    }
# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUaehRVNNbCI7n6GrEtk7AVaOE
# jP6gggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBQomWGs
# UEIFvj+vWnzWBdOBCm6wmTANBgkqhkiG9w0BAQEFAASBgHStC0VRvx41er0Uc1sg
# HdmKRkxxPC1k/uMA7wNy0drz2KenS7yHdNMSW43WXaLsR8sXQZzGShrygbwNEmTB
# 0PNiMS1lBQH+a7UF6MgX7NU+h/zvAfOllkLyEHzIpRT3PynFqa5Gl6WtcxkNEp1b
# NQRSFP9hP0YQZELaK4zfpQ5a
# SIG # End signature block
