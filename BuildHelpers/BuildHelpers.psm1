#Get public and private function definition files.
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )
# $ModuleRoot = $PSScriptRoot

#Dot source the files
Foreach($import in @($Public + $Private))
{
    Try
    {
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Load dependencies. TODO: Move to module dependency once the bug that
# causes this is fixed: https://ci.appveyor.com/project/RamblingCookieMonster/buildhelpers/build/1.0.22
# Thanks to Joel Bennett for this!
$fallbackModule = Get-Module -Name $PSScriptRoot\Private\Modules\Configuration -ListAvailable
if ($configModule = Get-Module $fallbackModule.Name -ListAvailable)
{
    $configModule |
        Where-Object { $_.Version -gt $fallbackModule.Version} |
        Sort-Object -Property Version -Descending |
        Select-Object -First 1 |
        Import-Module -Force
}
if (-not (Get-Module $fallbackModule.Name | Where-Object { $_.Version -gt $fallbackModule.Version}))
{
    $fallbackModule | Import-Module -Force
}

Export-ModuleMember -Function $Public.Basename
Export-ModuleMember -Function Get-Metadata, Update-Metadata, Export-Metadata

# Set aliases (#10)
Set-Alias -Name Set-BuildVariable -Value $PSScriptRoot\Scripts\Set-BuildVariable.ps1
Set-Alias -Name Get-NextPSGalleryVersion -Value Get-NextNugetPackageVersion
# Backwards compatibilty to command names prior to #72
Set-Alias -Name Get-BuildVariables -Value Get-BuildVariable
Set-Alias -Name Get-ModuleAliases -Value Get-ModuleAlias
Set-Alias -Name Get-ModuleFunctions -Value Get-ModuleFunction
Set-Alias -Name Set-ModuleAliases -Value Set-ModuleAlias
Set-Alias -Name Set-ModuleFormats -Value Set-ModuleFormat
Set-Alias -Name Set-ModuleFunctions -Value Set-ModuleFunction
Set-Alias -Name Set-ModuleTypes -Value Set-ModuleType

$exportModuleMemberSplat = @{
    Alias = @(
        'Set-BuildVariable'
        'Get-NextPSGalleryVersion'
        'Get-BuildVariables'
        'Get-ModuleAliases'
        'Get-ModuleFunctions'
        'Set-ModuleAliases'
        'Set-ModuleFormats'
        'Set-ModuleFunctions'
        'Set-ModuleTypes'
    )
}
Export-ModuleMember @exportModuleMemberSplat

# SIG # Begin signature block
# MIIELgYJKoZIhvcNAQcCoIIEHzCCBBsCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUlL+t5aL7hL7RlTVN0JlxnLrI
# mAWgggI4MIICNDCCAaGgAwIBAgIQWsnStFUuSIVNR8uhNSlE6TAJBgUrDgMCHQUA
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
# CisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBR3KcCy
# Rk27cCN1twmu9DzYYMtE6DANBgkqhkiG9w0BAQEFAASBgIRukGTa/2jMq4uUmDdq
# uCTa4vxngufl2ip1MYDSfQitNnp+TJ93kF1g5d1tlnjbthB6/KMphn0e68ky+mG8
# n0XX786j+jTOueOaGM5ZXDCtq8zHA+2a9uNJ8Kjvm6g3MMwsdoicCqRAncZMYZ/8
# 7aGMKF/pgrdZNnBFeOVSNIfz
# SIG # End signature block
