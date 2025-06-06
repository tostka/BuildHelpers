function Set-ModuleFormat {
    <#
    .SYNOPSIS
        EXPIRIMENTAL: Set FormatsToProcess

        [string]$FormatsPath in a module manifest

    .FUNCTIONALITY
        CI/CD

    .DESCRIPTION
        EXPIRIMENTAL: Set FormatsToProcess

        [string]$FormatsPath in a module manifest

    .PARAMETER Name
        Name or path to module to inspect.  Defaults to ProjectPath\ProjectName via Get-BuildVariable

    .PARAMETER FormatsToProcess
        Array of .ps1xml files

    .PARAMETER FormatsRelativePath
        Path to the ps1xml files relatives to the root of the module (example: ".\Format")

    .NOTES
        Major thanks to Joel Bennett for the code behind working with the psd1
            Source: https://github.com/PoshCode/Configuration

    .EXAMPLE
        Set-ModuleFormat -FormatsRelativePath '.\Format'

        Update module manifiest FormatsToProcess parameters with all the .ps1xml present in the .\Format folder.

    .LINK
        https://github.com/RamblingCookieMonster/BuildHelpers

    .LINK
        about_BuildHelpers
    #>
    [CmdLetBinding( SupportsShouldProcess )]
    param(
        [parameter(ValueFromPipeline = $True)]
        [Alias('Path')]
        [string]$Name,

        [string[]]$FormatsToProcess,

        [string]$FormatsRelativePath
    )
    Process
    {
        if(-not $Name)
        {
            $BuildDetails = Get-BuildVariable
            $Name = Join-Path ($BuildDetails.ProjectPath) (Get-ProjectName)
        }

        $params = @{
            Force = $True
            Passthru = $True
            Name = $Name
        }

        # Create a runspace
        $PowerShell = [Powershell]::Create()

        # Add scriptblock to the runspace
        [void]$PowerShell.AddScript({
            Param ($Force, $Passthru, $Name)
            $module = Import-Module -Name $Name -PassThru:$Passthru -Force:$Force
            $module | Where-Object Path -notin $module.Scripts

        }).AddParameters($Params)

        #Invoke the command
        $Module = $PowerShell.Invoke()

        if(-not $Module)
        {
            Throw "Could not find module '$Name'"
        }

        $Parent = $Module.ModuleBase
        $File = "$($Module.Name).psd1"
        $ModulePSD1Path = Join-Path $Parent $File
        if(-not (Test-Path $ModulePSD1Path))
        {
            Throw "Could not find expected module manifest '$ModulePSD1Path'"
        }

        if(-not $FormatsToProcess)
        {
            $FormatPath = Join-Path -Path $Parent -ChildPath $FormatsRelativePath
            $FormatList = Get-ChildItem -Path (Join-Path $FormatPath "*.ps1xml")

            $FormatsToProcess = @()
            Foreach ($Item in $FormatList) {
                $FormatsToProcess += Join-Path -Path $FormatsRelativePath -ChildPath $Item.Name
            }
        }

        If ($PSCmdlet.ShouldProcess("Updating Module's FormatsToProcess")) {
            Update-MetaData -Path $ModulePSD1Path -PropertyName FormatsToProcess -Value $FormatsToProcess
        }

        # Close down the runspace
        $PowerShell.Dispose()
    }
}

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUtxFBj2mE9bFEpqKLCPwnPyy+
# LqSgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSh+8vH
# 4dHt1zCsNb9oGcTNusE6GDANBgkqhkiG9w0BAQEFAASBgB60R4bKposfFP1on9Jd
# jFAEah885oqc9bFM25CS146neakPfKzeN5FgqnhJGOoQABtmYNuRFJ8f6QeScEUh
# 4GzXRWgLeVWxCKURRraQDED/YX/elU95RO5roieqXPSJ3jvla89tcSR+wrOoOsvu
# 2o7Rw4KsU17rlsrF0S/pqf3w
# SIG # End signature block
